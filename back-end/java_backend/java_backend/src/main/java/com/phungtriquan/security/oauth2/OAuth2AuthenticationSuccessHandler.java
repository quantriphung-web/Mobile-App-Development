package com.phungtriquan.security.oauth2;

import com.phungtriquan.model.StaffAccount;
import com.phungtriquan.repository.StaffAccountRepository;
import com.phungtriquan.security.JwtTokenProvider;
import com.phungtriquan.service.RefreshTokenService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;
import org.springframework.web.util.UriComponentsBuilder;
import java.io.IOException;

@Component
@RequiredArgsConstructor
@Slf4j
public class OAuth2AuthenticationSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {

    private final JwtTokenProvider tokenProvider;
    private final RefreshTokenService refreshTokenService;
    private final StaffAccountRepository staffAccountRepository;

    @Value("${app.oauth2.authorized-redirect-uris}")
    private String authorizedRedirectUri;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request,
                                        HttpServletResponse response,
                                        Authentication authentication) throws IOException {
        OAuth2User oAuth2User = (OAuth2User) authentication.getPrincipal();
        String email = (String) oAuth2User.getAttribute("userEmail");

        StaffAccount user = staffAccountRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        String accessToken = tokenProvider.generateTokenFromEmail(email);
        String refreshToken = refreshTokenService.createRefreshToken(user.getId()).getToken();

        // For mobile: redirect to app deep link with tokens
        String targetUrl = UriComponentsBuilder
                .fromUriString("myapp://oauth2/redirect")
                .queryParam("access_token", accessToken)
                .queryParam("refresh_token", refreshToken)
                .build().toUriString();

        log.info("OAuth2 login success for: {}", email);
        getRedirectStrategy().sendRedirect(request, response, targetUrl);
    }
}
