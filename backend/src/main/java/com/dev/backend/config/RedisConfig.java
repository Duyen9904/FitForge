package com.dev.backend.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.jsontype.BasicPolymorphicTypeValidator;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializationContext;
import org.springframework.data.redis.serializer.StringRedisSerializer;

import java.time.Duration;
import java.util.HashMap;
import java.util.Map;

/**
 * Redis configuration for caching with best practices.
 * 
 * Features:
 * - JSON serialization with Java 8 time support
 * - Cache-specific TTL configurations
 * - String key serialization for readability
 * - Fail-safe operations with graceful degradation
 */
@Configuration
@EnableCaching
public class RedisConfig {

    /**
     * Creates a customized RedisTemplate for manual Redis operations.
     * Uses JSON serialization for values and String serialization for keys.
     */
    @Bean
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory connectionFactory) {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(connectionFactory);
        
        // String serializer for keys (readable in Redis CLI)
        StringRedisSerializer stringSerializer = new StringRedisSerializer();
        template.setKeySerializer(stringSerializer);
        template.setHashKeySerializer(stringSerializer);
        
        // JSON serializer for values
        GenericJackson2JsonRedisSerializer jsonSerializer = createJsonSerializer();
        template.setValueSerializer(jsonSerializer);
        template.setHashValueSerializer(jsonSerializer);
        
        template.afterPropertiesSet();
        return template;
    }

    /**
     * Creates a CacheManager with cache-specific TTL configurations.
     * 
     * TTL Strategy:
     * - Static data (exercises, equipment): 24 hours
     * - User data (profile, preferences): 1 hour
     * - Dynamic data (dashboards): 15 minutes
     * - Session data (tokens): 7 days
     */
    @Bean
    public CacheManager cacheManager(RedisConnectionFactory connectionFactory) {
        // Default configuration
        RedisCacheConfiguration defaultConfig = RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofHours(1))
            .serializeKeysWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new StringRedisSerializer()))
            .serializeValuesWith(RedisSerializationContext.SerializationPair
                .fromSerializer(createJsonSerializer()))
            .disableCachingNullValues()
            .prefixCacheNameWith("gymplan:");
        
        // Cache-specific configurations
        Map<String, RedisCacheConfiguration> cacheConfigs = new HashMap<>();
        
        // Static data - long TTL (24 hours)
        RedisCacheConfiguration staticDataConfig = defaultConfig.entryTtl(Duration.ofHours(24));
        cacheConfigs.put(CacheNames.EXERCISES, staticDataConfig);
        cacheConfigs.put(CacheNames.EXERCISE_BY_ID, staticDataConfig);
        cacheConfigs.put(CacheNames.MUSCLE_GROUPS, staticDataConfig);
        cacheConfigs.put(CacheNames.EQUIPMENT, staticDataConfig);
        cacheConfigs.put(CacheNames.ACHIEVEMENTS, staticDataConfig);
        cacheConfigs.put(CacheNames.GOALS, staticDataConfig);
        
        // User-specific data - medium TTL (1 hour)
        RedisCacheConfiguration userDataConfig = defaultConfig.entryTtl(Duration.ofHours(1));
        cacheConfigs.put(CacheNames.USER_PROFILE, userDataConfig);
        cacheConfigs.put(CacheNames.USER_PREFERENCES, userDataConfig);
        cacheConfigs.put(CacheNames.USER_ACHIEVEMENTS, userDataConfig);
        cacheConfigs.put(CacheNames.USER_WORKOUT_PLANS, userDataConfig);
        
        // Dynamic data - short TTL (15 minutes)
        RedisCacheConfiguration dynamicDataConfig = defaultConfig.entryTtl(Duration.ofMinutes(15));
        cacheConfigs.put(CacheNames.DASHBOARD, dynamicDataConfig);
        cacheConfigs.put(CacheNames.STATISTICS, dynamicDataConfig);
        cacheConfigs.put(CacheNames.REPORTS, dynamicDataConfig);
        
        // Session data - long TTL (7 days for refresh tokens)
        cacheConfigs.put(CacheNames.REFRESH_TOKENS, defaultConfig.entryTtl(Duration.ofDays(7)));
        cacheConfigs.put(CacheNames.TOKEN_BLACKLIST, defaultConfig.entryTtl(Duration.ofHours(24)));
        
        // Rate limiting - very short TTL (1 minute)
        cacheConfigs.put(CacheNames.RATE_LIMIT, defaultConfig.entryTtl(Duration.ofMinutes(1)));
        
        return RedisCacheManager.builder(connectionFactory)
            .cacheDefaults(defaultConfig)
            .withInitialCacheConfigurations(cacheConfigs)
            .transactionAware()
            .build();
    }

    /**
     * Creates a JSON serializer with Java 8 time support and type information.
     */
    private GenericJackson2JsonRedisSerializer createJsonSerializer() {
        ObjectMapper mapper = new ObjectMapper();
        
        // Support for Java 8 date/time types
        mapper.registerModule(new JavaTimeModule());
        
        // Enable polymorphic type handling for proper deserialization
        BasicPolymorphicTypeValidator typeValidator = BasicPolymorphicTypeValidator.builder()
            .allowIfBaseType(Object.class)
            .build();
        
        mapper.activateDefaultTyping(typeValidator, ObjectMapper.DefaultTyping.NON_FINAL);
        
        return new GenericJackson2JsonRedisSerializer(mapper);
    }
}
