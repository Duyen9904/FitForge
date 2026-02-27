package com.dev.backend.repository;

import com.dev.backend.model.entity.RefreshToken;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.Optional;

@Repository
public interface RefreshTokenRepository extends JpaRepository<RefreshToken, Long> {
    
    Optional<RefreshToken> findByToken(String token);
    
    Page<RefreshToken> findByUserUserId(Long userId, Pageable pageable);
    
    void deleteByToken(String token);
    
    void deleteByUserUserId(Long userId);
    
    void deleteBySessionId(String sessionId);
    
    void deleteByExpiresAtBefore(Instant now);
}
