package com.dev.backend.repository;

import com.dev.backend.model.entity.DeviceToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository for FCM device tokens (UC-15)
 */
@Repository
public interface DeviceTokenRepository extends JpaRepository<DeviceToken, Long> {

    /**
     * Find all active device tokens for a user
     */
    List<DeviceToken> findByUserUserIdAndIsActiveTrue(Long userId);

    /**
     * Find a specific device token
     */
    Optional<DeviceToken> findByToken(String token);

    /**
     * Check if token exists
     */
    boolean existsByToken(String token);

    /**
     * Deactivate a device token
     */
    @Modifying
    @Query("UPDATE DeviceToken dt SET dt.isActive = false WHERE dt.token = :token")
    int deactivateToken(@Param("token") String token);

    /**
     * Delete inactive tokens older than specified time
     */
    @Modifying
    @Query("DELETE FROM DeviceToken dt WHERE dt.isActive = false AND dt.lastUsedAt < :olderThan")
    int deleteInactiveTokens(@Param("olderThan") java.time.Instant olderThan);

    /**
     * Update last used time for a token
     */
    @Modifying
    @Query("UPDATE DeviceToken dt SET dt.lastUsedAt = :lastUsedAt WHERE dt.token = :token")
    int updateLastUsedAt(@Param("token") String token, @Param("lastUsedAt") java.time.Instant lastUsedAt);
}
