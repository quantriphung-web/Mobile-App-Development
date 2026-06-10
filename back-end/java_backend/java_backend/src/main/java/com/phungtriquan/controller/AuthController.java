package com.phungtriquan.controller;

import com.phungtriquan.config.*;
import com.phungtriquan.model.StaffAccount;
import com.phungtriquan.repository.StaffAccountRepository;
import com.phungtriquan.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AuthController {

    private final AuthService authService;
    private final StaffAccountRepository staffAccountRepository;

    // ── POST /api/auth/login ─────────────────────────────────────────────────
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    // ── POST /api/auth/register ──────────────────────────────────────────────
    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.ok(authService.register(request));
    }

    // ── POST /api/auth/refresh ───────────────────────────────────────────────
    @PostMapping("/refresh")
    public ResponseEntity<AuthResponse> refreshToken(@Valid @RequestBody RefreshTokenRequest request) {
        return ResponseEntity.ok(authService.refreshToken(request));
    }

    // ── POST /api/auth/logout ────────────────────────────────────────────────
    @PostMapping("/logout")
    public ResponseEntity<ApiResponse> logout(@AuthenticationPrincipal UserDetails userDetails) {
        StaffAccount user = staffAccountRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));
        authService.logout(user.getId());
        return ResponseEntity.ok(new ApiResponse(true, "Logged out successfully"));
    }

    // ── POST /api/auth/google ────────────────────────────────────────────────
    @PostMapping("/google")
    public ResponseEntity<AuthResponse> loginWithGoogle(@RequestBody Map<String, String> body) {
        String idToken = body.get("idToken");
        String action = body.get("action");
        return ResponseEntity.ok(authService.loginWithGoogle(idToken, action));
    }

    // ── POST /api/auth/facebook ──────────────────────────────────────────────
    @PostMapping("/facebook")
    public ResponseEntity<AuthResponse> loginWithFacebook(@RequestBody Map<String, String> body) {
        String accessToken = body.get("accessToken");
        String action = body.get("action");
        return ResponseEntity.ok(authService.loginWithFacebook(accessToken, action));
    }

    // ── GET /api/auth/me ─────────────────────────────────────────────────────
    @GetMapping("/me")
    public ResponseEntity<?> getCurrentUser(@AuthenticationPrincipal UserDetails userDetails) {
        StaffAccount user = staffAccountRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));
        AuthResponse.UserInfo userInfo = AuthResponse.UserInfo.builder()
                .id(user.getId())
                .name(user.getFirstName() + " " + user.getLastName())
                .email(user.getEmail())
                .imageUrl(user.getImage())
                .provider(user.getProvider().toString())
                .build();
        return ResponseEntity.ok(userInfo);
    }

    // ── GET /api/auth/health ─────────────────────────────────────────────────
    @GetMapping("/health")
    public ResponseEntity<ApiResponse> health() {
        return ResponseEntity.ok(new ApiResponse(true, "Server is running!"));
    }
}
