package com.phungtriquan.service;

import com.phungtriquan.config.*;
import com.phungtriquan.config.BadRequestException;
import com.phungtriquan.config.TokenRefreshException;
import com.phungtriquan.model.AuthProvider;
import com.phungtriquan.model.RefreshToken;
import com.phungtriquan.model.StaffAccount;
import com.phungtriquan.repository.StaffAccountRepository;
import com.phungtriquan.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.*;
import org.springframework.security.authentication.*;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final StaffAccountRepository staffAccountRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider tokenProvider;
    private final RefreshTokenService refreshTokenService;

    // ── Email/Password Login ──────────────────────────────────────────────────
    public AuthResponse login(LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(), request.getPassword()));
        SecurityContextHolder.getContext().setAuthentication(authentication);

        StaffAccount user = staffAccountRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new BadRequestException("User not found"));
        String accessToken = tokenProvider.generateAccessToken(authentication);
        RefreshToken refreshToken = refreshTokenService.createRefreshToken(user.getId());
        return buildAuthResponse(accessToken, refreshToken.getToken(), user);
    }

    // ── Register ──────────────────────────────────────────────────────────────
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (staffAccountRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException("Email is already in use!");
        }

        String fullName = request.getName();
        String firstName = "Local";
        String lastName = "User";
        if (fullName != null && !fullName.trim().isEmpty()) {
            String[] parts = fullName.trim().split("\\s+", 2);
            if (parts.length > 1) {
                firstName = parts[0];
                lastName = parts[1];
            } else {
                firstName = parts[0];
                lastName = "Account";
            }
        }

        StaffAccount user = StaffAccount.builder()
                .firstName(firstName)
                .lastName(lastName)
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .provider(AuthProvider.LOCAL)
                .emailVerified(false)
                .active(true)
                .build();

        Optional<StaffAccount> firstAccount = staffAccountRepository.findFirstByOrderByCreatedAtAsc();
        if (firstAccount.isPresent()) {
            user.setCreatedBy(firstAccount.get());
            user.setUpdatedBy(firstAccount.get());
            staffAccountRepository.save(user);
        } else {
            staffAccountRepository.save(user);
            user.setCreatedBy(user);
            user.setUpdatedBy(user);
            staffAccountRepository.save(user);
        }

        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(), request.getPassword()));
        SecurityContextHolder.getContext().setAuthentication(authentication);

        String accessToken = tokenProvider.generateAccessToken(authentication);
        RefreshToken refreshToken = refreshTokenService.createRefreshToken(user.getId());
        return buildAuthResponse(accessToken, refreshToken.getToken(), user);
    }

    // ── Refresh Token ─────────────────────────────────────────────────────────
    public AuthResponse refreshToken(RefreshTokenRequest request) {
        RefreshToken refreshToken = refreshTokenService.findByToken(request.getRefreshToken())
                .orElseThrow(() -> new TokenRefreshException(
                        request.getRefreshToken(), "Refresh token not found"));
        refreshTokenService.verifyExpiration(refreshToken);
        StaffAccount user = refreshToken.getUser();
        String accessToken = tokenProvider.generateTokenFromEmail(user.getEmail());
        return buildAuthResponse(accessToken, refreshToken.getToken(), user);
    }

    // ── Logout ────────────────────────────────────────────────────────────────
    @Transactional
    public void logout(UUID userId) {
        refreshTokenService.deleteByUserId(userId);
        SecurityContextHolder.clearContext();
    }

    // ── Google Login ──────────────────────────────────────────────────────────
    @Transactional
    public AuthResponse loginWithGoogle(String idToken, String action) {
        try {
            // ✅ Dùng POST thay vì GET để tránh idToken bị truncate trên URL
            RestTemplate restTemplate = new RestTemplate();
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

            MultiValueMap<String, String> body = new LinkedMultiValueMap<>();
            body.add("id_token", idToken);

            HttpEntity<MultiValueMap<String, String>> requestEntity =
                    new HttpEntity<>(body, headers);

            ResponseEntity<Map> responseEntity = restTemplate.postForEntity(
                    "https://oauth2.googleapis.com/tokeninfo",
                    requestEntity,
                    Map.class
            );

            Map<?, ?> googleInfo = responseEntity.getBody();

            if (googleInfo == null || googleInfo.containsKey("error")) {
                log.error("Google tokeninfo error: {}", googleInfo);
                throw new BadRequestException("Invalid Google token");
            }

            String email   = (String) googleInfo.get("email");
            String name    = (String) googleInfo.get("name");
            String picture = (String) googleInfo.get("picture");
            String sub     = (String) googleInfo.get("sub");

            if (email == null) throw new BadRequestException("Cannot get email from Google");

            boolean isNewUser = !staffAccountRepository.existsByEmail(email);

            if ("login".equals(action) && isNewUser) {
                throw new BadRequestException("Account not found. Please sign up first.");
            }

            StaffAccount user = staffAccountRepository.findByEmail(email).orElseGet(() -> {
                String parsedFirstName = "Google";
                String parsedLastName = "User";
                if (name != null && !name.trim().isEmpty()) {
                    String[] parts = name.trim().split("\\s+", 2);
                    if (parts.length > 1) {
                        parsedFirstName = parts[0];
                        parsedLastName = parts[1];
                    } else {
                        parsedFirstName = parts[0];
                        parsedLastName = "Account";
                    }
                }

                StaffAccount newUser = StaffAccount.builder()
                        .email(email)
                        .firstName(parsedFirstName)
                        .lastName(parsedLastName)
                        .image(picture)
                        .passwordHash("OAUTH_ACCOUNT_NO_PASSWORD")
                        .provider(AuthProvider.GOOGLE)
                        .providerId(sub)
                        .emailVerified(true)
                        .active(true)
                        .build();

                Optional<StaffAccount> firstAccount = staffAccountRepository.findFirstByOrderByCreatedAtAsc();
                if (firstAccount.isPresent()) {
                    newUser.setCreatedBy(firstAccount.get());
                    newUser.setUpdatedBy(firstAccount.get());
                    return staffAccountRepository.save(newUser);
                } else {
                    staffAccountRepository.save(newUser);
                    newUser.setCreatedBy(newUser);
                    newUser.setUpdatedBy(newUser);
                    return staffAccountRepository.save(newUser);
                }
            });

            // Cập nhật avatar nếu user Google đăng nhập lại
            if (!isNewUser && user.getProvider() == AuthProvider.GOOGLE) {
                if (name != null && !name.trim().isEmpty()) {
                    String[] parts = name.trim().split("\\s+", 2);
                    user.setFirstName(parts[0]);
                    user.setLastName(parts.length > 1 ? parts[1] : "Account");
                }
                user.setImage(picture);
                staffAccountRepository.save(user);
            }

            String accessToken = tokenProvider.generateTokenFromEmail(email);
            RefreshToken refresh = refreshTokenService.createRefreshToken(user.getId());
            return buildAuthResponse(accessToken, refresh.getToken(), user, isNewUser);

        } catch (BadRequestException e) {
            throw e;
        } catch (Exception e) {
            log.error("Google login error: {}", e.getMessage());
            throw new BadRequestException("Google login failed: " + e.getMessage());
        }
    }

    // ── Facebook Login ────────────────────────────────────────────────────────
    @Transactional
    public AuthResponse loginWithFacebook(String accessToken, String action) {
        try {
            String url = "https://graph.facebook.com/me?fields=id,name,email,picture" +
                         "&access_token=" + accessToken;
            RestTemplate restTemplate = new RestTemplate();
            Map<?, ?> fbInfo = restTemplate.getForObject(url, Map.class);

            if (fbInfo == null || fbInfo.containsKey("error")) {
                throw new BadRequestException("Invalid Facebook token");
            }

            String email = (String) fbInfo.get("email");
            String name  = (String) fbInfo.get("name");
            String id    = (String) fbInfo.get("id");

            if (email == null) {
                throw new BadRequestException(
                    "Facebook account has no email. Please use email/password login.");
            }

            boolean isNewUser = !staffAccountRepository.existsByEmail(email);

            if ("login".equals(action) && isNewUser) {
                throw new BadRequestException("Account not found. Please sign up first.");
            }
            if ("signup".equals(action) && !isNewUser) {
                throw new BadRequestException("Account already exists. Please login instead.");
            }

            StaffAccount user = staffAccountRepository.findByEmail(email).orElseGet(() -> {
                String parsedFirstName = "Facebook";
                String parsedLastName = "User";
                if (name != null && !name.trim().isEmpty()) {
                    String[] parts = name.trim().split("\\s+", 2);
                    if (parts.length > 1) {
                        parsedFirstName = parts[0];
                        parsedLastName = parts[1];
                    } else {
                        parsedFirstName = parts[0];
                        parsedLastName = "Account";
                    }
                }

                StaffAccount newUser = StaffAccount.builder()
                        .email(email)
                        .firstName(parsedFirstName)
                        .lastName(parsedLastName)
                        .passwordHash("OAUTH_ACCOUNT_NO_PASSWORD")
                        .provider(AuthProvider.FACEBOOK)
                        .providerId(id)
                        .emailVerified(true)
                        .active(true)
                        .build();

                Optional<StaffAccount> firstAccount = staffAccountRepository.findFirstByOrderByCreatedAtAsc();
                if (firstAccount.isPresent()) {
                    newUser.setCreatedBy(firstAccount.get());
                    newUser.setUpdatedBy(firstAccount.get());
                    return staffAccountRepository.save(newUser);
                } else {
                    staffAccountRepository.save(newUser);
                    newUser.setCreatedBy(newUser);
                    newUser.setUpdatedBy(newUser);
                    return staffAccountRepository.save(newUser);
                }
            });

            String token = tokenProvider.generateTokenFromEmail(email);
            RefreshToken rt = refreshTokenService.createRefreshToken(user.getId());
            return buildAuthResponse(token, rt.getToken(), user, isNewUser);

        } catch (BadRequestException e) {
            throw e;
        } catch (Exception e) {
            log.error("Facebook login error: {}", e.getMessage());
            throw new BadRequestException("Facebook login failed: " + e.getMessage());
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────
    private AuthResponse buildAuthResponse(String accessToken, String refreshToken,
                                            StaffAccount user, boolean isNewUser) {
        AuthResponse.UserInfo userInfo = AuthResponse.UserInfo.builder()
                .id(user.getId())
                .name(user.getFirstName() + " " + user.getLastName())
                .email(user.getEmail())
                .imageUrl(user.getImage())
                .provider(user.getProvider().toString())
                .build();
        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .isNewUser(isNewUser)
                .user(userInfo)
                .build();
    }

    private AuthResponse buildAuthResponse(String accessToken, String refreshToken,
                                            StaffAccount user) {
        return buildAuthResponse(accessToken, refreshToken, user, false);
    }
}