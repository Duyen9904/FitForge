package com.dev.backend.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.data.redis.connection.RedisConnection;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.stereotype.Component;

/**
 * Custom health indicator for Redis connection.
 * 
 * Exposed via Spring Boot Actuator at /actuator/health
 * Reports Redis connectivity status with details.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class RedisHealthIndicator implements HealthIndicator {
    
    private final RedisConnectionFactory connectionFactory;
    
    @Override
    public Health health() {
        try {
            RedisConnection connection = connectionFactory.getConnection();
            String response = connection.ping();
            connection.close();
            
            if ("PONG".equals(response)) {
                return Health.up()
                    .withDetail("ping", response)
                    .withDetail("status", "Connected")
                    .build();
            } else {
                return Health.down()
                    .withDetail("ping", response)
                    .withDetail("status", "Unexpected response")
                    .build();
            }
        } catch (Exception e) {
            log.warn("Redis health check failed: {}", e.getMessage());
            return Health.down()
                .withDetail("error", e.getMessage())
                .withDetail("status", "Disconnected")
                .build();
        }
    }
}
