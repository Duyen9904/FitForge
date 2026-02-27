package com.dev.backend.service;

import com.dev.backend.model.entity.User;
import jakarta.validation.constraints.NotNull;
import org.springframework.security.oauth2.jwt.Jwt;

public interface JwtService {
    @NotNull
    Jwt generateJwt(long accountId, String email, User.Role role);

    String createJwtFromRefreshToken(String token);

    @NotNull
    String generateToken(long accountId, String email, User.Role role);

    @NotNull
    Jwt parseJwt(String token);
}
