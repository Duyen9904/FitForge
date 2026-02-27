package com.dev.backend.service;

import java.time.Duration;
import java.util.Optional;
import java.util.Set;

/**
 * Service interface for Redis cache operations.
 * 
 * Provides:
 * - Basic key-value operations with TTL
 * - Pattern-based key operations
 * - Token blacklisting for security
 * - Rate limiting support
 * - Cache eviction utilities
 */
public interface RedisCacheService {
    
    // ==================== Basic Operations ====================
    
    /**
     * Sets a value in the cache with a specified TTL.
     *
     * @param key   the cache key
     * @param value the value to cache
     * @param ttl   time-to-live duration
     * @param <T>   the value type
     */
    <T> void set(String key, T value, Duration ttl);
    
    /**
     * Gets a value from the cache.
     *
     * @param key  the cache key
     * @param type the expected value type
     * @param <T>  the value type
     * @return the cached value, or empty if not found
     */
    <T> Optional<T> get(String key, Class<T> type);
    
    /**
     * Deletes a key from the cache.
     *
     * @param key the cache key to delete
     */
    void delete(String key);
    
    /**
     * Checks if a key exists in the cache.
     *
     * @param key the cache key
     * @return true if the key exists
     */
    boolean exists(String key);
    
    // ==================== Pattern Operations ====================
    
    /**
     * Deletes all keys matching a pattern.
     *
     * @param pattern the key pattern (e.g., "gymplan:user:*")
     */
    void deleteByPattern(String pattern);
    
    /**
     * Gets all keys matching a pattern.
     *
     * @param pattern the key pattern
     * @return set of matching keys
     */
    Set<String> getKeysByPattern(String pattern);
    
    // ==================== Token Management ====================
    
    /**
     * Adds a token to the blacklist.
     *
     * @param tokenId the JWT token ID (jti claim)
     * @param ttl     how long to keep the token blacklisted
     */
    void blacklistToken(String tokenId, Duration ttl);
    
    /**
     * Checks if a token is blacklisted.
     *
     * @param tokenId the JWT token ID
     * @return true if the token is blacklisted
     */
    boolean isTokenBlacklisted(String tokenId);
    
    // ==================== Rate Limiting ====================
    
    /**
     * Checks if an identifier has exceeded the rate limit.
     * Uses a sliding window counter pattern.
     *
     * @param identifier  unique identifier (e.g., IP + endpoint)
     * @param maxRequests maximum requests allowed in the window
     * @param window      the time window duration
     * @return true if rate limited, false if request is allowed
     */
    boolean isRateLimited(String identifier, int maxRequests, Duration window);
    
    // ==================== Cache Eviction ====================
    
    /**
     * Evicts all cached data for a specific user.
     *
     * @param userId the user's ID
     */
    void evictUserCache(Long userId);
    
    /**
     * Evicts all caches managed by the CacheManager.
     */
    void evictAllCaches();
}
