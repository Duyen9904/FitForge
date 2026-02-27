package com.dev.backend.service.impl;

import com.dev.backend.config.CacheNames;
import com.dev.backend.service.RedisCacheService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.Optional;
import java.util.Set;

/**
 * Implementation of RedisCacheService with fail-safe operations.
 * 
 * All operations are wrapped in try-catch to ensure the application
 * continues to function even if Redis is unavailable (fail-open strategy).
 */
@Service
@Slf4j
@RequiredArgsConstructor
public class RedisCacheServiceImpl implements RedisCacheService {
    
    private final RedisTemplate<String, Object> redisTemplate;
    private final CacheManager cacheManager;
    
    // ==================== Basic Operations ====================
    
    @Override
    public <T> void set(String key, T value, Duration ttl) {
        try {
            redisTemplate.opsForValue().set(key, value, ttl);
            log.debug("Cache SET: key={}, ttl={}s", key, ttl.getSeconds());
        } catch (Exception e) {
            log.warn("Failed to set cache key '{}': {}", key, e.getMessage());
        }
    }
    
    @Override
    @SuppressWarnings("unchecked")
    public <T> Optional<T> get(String key, Class<T> type) {
        try {
            Object value = redisTemplate.opsForValue().get(key);
            if (value != null) {
                if (type.isInstance(value)) {
                    log.debug("Cache HIT: key={}", key);
                    return Optional.of((T) value);
                } else {
                    log.warn("Cache type mismatch for key '{}': expected {}, got {}", 
                        key, type.getSimpleName(), value.getClass().getSimpleName());
                }
            } else {
                log.debug("Cache MISS: key={}", key);
            }
        } catch (Exception e) {
            log.warn("Failed to get cache key '{}': {}", key, e.getMessage());
        }
        return Optional.empty();
    }
    
    @Override
    public void delete(String key) {
        try {
            Boolean deleted = redisTemplate.delete(key);
            log.debug("Cache DELETE: key={}, success={}", key, deleted);
        } catch (Exception e) {
            log.warn("Failed to delete cache key '{}': {}", key, e.getMessage());
        }
    }
    
    @Override
    public boolean exists(String key) {
        try {
            Boolean exists = redisTemplate.hasKey(key);
            return Boolean.TRUE.equals(exists);
        } catch (Exception e) {
            log.warn("Failed to check key existence '{}': {}", key, e.getMessage());
            return false;
        }
    }
    
    // ==================== Pattern Operations ====================
    
    @Override
    public void deleteByPattern(String pattern) {
        try {
            Set<String> keys = redisTemplate.keys(pattern);
            if (keys != null && !keys.isEmpty()) {
                Long deletedCount = redisTemplate.delete(keys);
                log.info("Cache EVICT by pattern '{}': deleted {} keys", pattern, deletedCount);
            }
        } catch (Exception e) {
            log.warn("Failed to delete keys by pattern '{}': {}", pattern, e.getMessage());
        }
    }
    
    @Override
    public Set<String> getKeysByPattern(String pattern) {
        try {
            Set<String> keys = redisTemplate.keys(pattern);
            return keys != null ? keys : Set.of();
        } catch (Exception e) {
            log.warn("Failed to get keys by pattern '{}': {}", pattern, e.getMessage());
            return Set.of();
        }
    }
    
    // ==================== Token Management ====================
    
    @Override
    public void blacklistToken(String tokenId, Duration ttl) {
        String key = CacheNames.TOKEN_BLACKLIST + ":" + tokenId;
        set(key, Boolean.TRUE, ttl);
        log.info("Token blacklisted: tokenId={}, ttl={}s", tokenId, ttl.getSeconds());
    }
    
    @Override
    public boolean isTokenBlacklisted(String tokenId) {
        String key = CacheNames.TOKEN_BLACKLIST + ":" + tokenId;
        boolean blacklisted = exists(key);
        if (blacklisted) {
            log.debug("Token is blacklisted: tokenId={}", tokenId);
        }
        return blacklisted;
    }
    
    // ==================== Rate Limiting ====================
    
    @Override
    public boolean isRateLimited(String identifier, int maxRequests, Duration window) {
        String key = CacheNames.RATE_LIMIT + ":" + identifier;
        try {
            Long currentCount = redisTemplate.opsForValue().increment(key);
            
            if (currentCount != null) {
                // Set expiry only on first request in the window
                if (currentCount == 1) {
                    redisTemplate.expire(key, window);
                }
                
                boolean limited = currentCount > maxRequests;
                if (limited) {
                    log.warn("Rate limit exceeded for '{}': count={}, max={}", 
                        identifier, currentCount, maxRequests);
                }
                return limited;
            }
        } catch (Exception e) {
            log.warn("Rate limiting check failed for '{}': {}", identifier, e.getMessage());
        }
        
        // Fail open - allow request if Redis is unavailable
        return false;
    }
    
    // ==================== Cache Eviction ====================
    
    @Override
    public void evictUserCache(Long userId) {
        // Evict all user-related caches
        String[] patterns = {
            "gymplan:user-profile:" + userId,
            "gymplan:user-preferences:" + userId,
            "gymplan:user-achievements:" + userId,
            "gymplan:user-workout-plans:" + userId,
            "gymplan:recovery-dashboard:" + userId,
            "gymplan:compensation-dashboard:" + userId,
            "gymplan:dashboard:" + userId,
            "gymplan:statistics:" + userId
        };
        
        for (String pattern : patterns) {
            deleteByPattern(pattern + "*");
        }
        
        log.info("Evicted all caches for userId={}", userId);
    }
    
    @Override
    public void evictAllCaches() {
        try {
            cacheManager.getCacheNames().forEach(cacheName -> {
                Cache cache = cacheManager.getCache(cacheName);
                if (cache != null) {
                    cache.clear();
                    log.debug("Cleared cache: {}", cacheName);
                }
            });
            log.info("All caches cleared successfully");
        } catch (Exception e) {
            log.error("Failed to clear all caches: {}", e.getMessage());
        }
    }
}
