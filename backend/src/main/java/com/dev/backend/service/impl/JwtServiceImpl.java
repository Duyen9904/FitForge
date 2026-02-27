package com.dev.backend.service.impl;

import com.dev.backend.model.entity.RefreshToken;
import com.dev.backend.model.entity.User;
import com.dev.backend.service.JwtService;
import com.dev.backend.service.RefreshTokenService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.oauth2.jwt.*;
import org.springframework.stereotype.Service;

import java.time.Instant;

@Service
public class JwtServiceImpl implements JwtService {
    
    private final JwtEncoder encoder;
    private final JwtDecoder decoder;
    private final RefreshTokenService refreshTokenService;

    @Value("${jwt.access-token.expiration:900}")
    private long accessTokenExpiration;

    public JwtServiceImpl(JwtEncoder encoder, JwtDecoder decoder, RefreshTokenService refreshTokenService) {
        this.encoder = encoder;
        this.decoder = decoder;
        this.refreshTokenService = refreshTokenService;
    }

    @Override
    public Jwt generateJwt(long accountId, String email, User.Role role) {
        Instant now = Instant.now();
        JwtClaimsSet claims = JwtClaimsSet.builder()
                .issuer("dev-backend")
                .issuedAt(now)
                .claim("accountId", accountId)
                .subject(String.valueOf(accountId))
                .claim("email", email)
                .claim("role", role.name())
                .expiresAt(now.plusSeconds(accessTokenExpiration))
                .build();
        return this.encoder.encode(JwtEncoderParameters.from(claims));
    }

    @Override
    public String createJwtFromRefreshToken(String token) {
        RefreshToken refreshToken = refreshTokenService.findByToken(token);
        
        if (refreshToken == null) {
            throw new RuntimeException("Invalid refresh token");
        }
        
        if (refreshToken.getExpiresAt().isBefore(Instant.now())) {
            throw new RuntimeException("Refresh token expired");
        }
        
        User user = refreshToken.getUser();
        return generateToken(user.getUserId(), user.getEmail(), user.getRole());
    }

    @Override
    public String generateToken(long accountId, String email, User.Role role) {
        return generateJwt(accountId, email, role).getTokenValue();
    }

    @Override
    public Jwt parseJwt(String token) {
        return decoder.decode(token);
    }
}
