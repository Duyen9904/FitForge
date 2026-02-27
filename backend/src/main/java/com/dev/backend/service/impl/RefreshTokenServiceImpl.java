package com.dev.backend.service.impl;

import com.dev.backend.model.entity.RefreshToken;
import com.dev.backend.model.entity.User;
import com.dev.backend.repository.RefreshTokenRepository;
import com.dev.backend.repository.UserRepository;
import com.dev.backend.service.RefreshTokenService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.lang.Nullable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@Slf4j
public class RefreshTokenServiceImpl implements RefreshTokenService {

    private final RefreshTokenRepository refreshTokenRepository;
    private final UserRepository userRepository;

    @Value("${jwt.refresh-token.expiration:604800}")
    private long refreshTokenExpiration;

    public RefreshTokenServiceImpl(RefreshTokenRepository refreshTokenRepository,
                                   UserRepository userRepository) {
        this.refreshTokenRepository = refreshTokenRepository;
        this.userRepository = userRepository;
    }

    @Override
    @Transactional
    public RefreshToken createRefreshToken(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found: " + email));

        RefreshToken refreshToken = new RefreshToken();
        refreshToken.setToken(UUID.randomUUID().toString());
        refreshToken.setUser(user);
        refreshToken.setExpiresAt(Instant.now().plusSeconds(refreshTokenExpiration));
        refreshToken.setCreatedAt(Instant.now());

        RefreshToken saved = refreshTokenRepository.save(refreshToken);
        log.info("Created refresh token for user: {}", email);
        
        return saved;
    }

    @Override
    @Nullable
    public RefreshToken findByToken(String token) {
        return refreshTokenRepository.findByToken(token).orElse(null);
    }

    @Override
    @Transactional
    public void revokeRefreshTokenByAccountEmail(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found: " + email));
        
        refreshTokenRepository.deleteByUserUserId(user.getUserId());
        log.info("Revoked all refresh tokens for user: {}", email);
    }

    @Override
    @Transactional
    public void revokeRefreshTokenBySessionId(String sessionId) {
        refreshTokenRepository.deleteBySessionId(sessionId);
        log.info("Revoked refresh token for session: {}", sessionId);
    }
}
