package com.phungtriquan.service;

import com.phungtriquan.config.TokenRefreshException;
import com.phungtriquan.model.RefreshToken;
import com.phungtriquan.model.StaffAccount;
import com.phungtriquan.repository.RefreshTokenRepository;
import com.phungtriquan.repository.StaffAccountRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class RefreshTokenService {

    @Value("${app.jwt.refresh-token-expiration}")
    private Long refreshTokenDurationMs;

    private final RefreshTokenRepository refreshTokenRepository;
    private final StaffAccountRepository staffAccountRepository;

    @Transactional
    public RefreshToken createRefreshToken(UUID userId) {
        StaffAccount user = staffAccountRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Xóa token cũ nếu tồn tại
        refreshTokenRepository.findByUser(user)
                .ifPresent(refreshTokenRepository::delete);
        refreshTokenRepository.flush(); // ← flush trước khi insert mới

        RefreshToken refreshToken = RefreshToken.builder()
                .user(user)
                .token(UUID.randomUUID().toString())
                .expiryDate(Instant.now().plusMillis(refreshTokenDurationMs))
                .build();

        return refreshTokenRepository.save(refreshToken);
    }

    public RefreshToken verifyExpiration(RefreshToken token) {
        if (token.getExpiryDate().isBefore(Instant.now())) {
            refreshTokenRepository.delete(token);
            throw new TokenRefreshException(token.getToken(),
                    "Refresh token expired. Please sign in again.");
        }
        return token;
    }

    @Transactional
    public void deleteByUserId(UUID userId) {
        StaffAccount user = staffAccountRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        refreshTokenRepository.deleteByUser(user);
    }

    public java.util.Optional<RefreshToken> findByToken(String token) {
        return refreshTokenRepository.findByToken(token);
    }
}
