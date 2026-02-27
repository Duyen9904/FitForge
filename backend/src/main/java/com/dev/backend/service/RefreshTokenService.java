package com.dev.backend.service;

import com.dev.backend.model.entity.RefreshToken;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.lang.Nullable;

public interface RefreshTokenService {
    
    RefreshToken createRefreshToken(String email);
    
    @Nullable
    RefreshToken findByToken(String token);
    void revokeRefreshTokenByAccountEmail(String email);
    void revokeRefreshTokenBySessionId(String sessionId);
}
