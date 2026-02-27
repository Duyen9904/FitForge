package com.dev.backend.security;

import com.dev.backend.service.RedisCacheService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.Duration;

/**
 * Rate limiting filter using Redis for distributed rate limiting.
 * 
 * Rate limits:
 * - Authentication endpoints (/api/v1/auth/**): 10 requests per minute
 * - General API endpoints: 100 requests per minute
 * 
 * Uses client IP + endpoint as the rate limit key.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class RateLimitingFilter extends OncePerRequestFilter {
    
    private final RedisCacheService redisCacheService;
    
    // Rate limit configurations
    private static final int AUTH_MAX_REQUESTS = 10;
    private static final int API_MAX_REQUESTS = 100;
    private static final Duration RATE_LIMIT_WINDOW = Duration.ofMinutes(1);
    
    // Paths to apply stricter rate limiting
    private static final String AUTH_PATH = "/api/v1/auth/";
    
    // Paths to exclude from rate limiting
    private static final String[] EXCLUDED_PATHS = {
        "/actuator/",
        "/swagger-ui/",
        "/v3/api-docs",
        "/health"
    };
    
    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                     HttpServletResponse response,
                                     FilterChain filterChain) throws ServletException, IOException {
        
        String requestUri = request.getRequestURI();
        
        // Skip rate limiting for excluded paths
        if (isExcludedPath(requestUri)) {
            filterChain.doFilter(request, response);
            return;
        }
        
        String clientIdentifier = buildRateLimitKey(request);
        int maxRequests = isAuthEndpoint(requestUri) ? AUTH_MAX_REQUESTS : API_MAX_REQUESTS;
        
        try {
            if (redisCacheService.isRateLimited(clientIdentifier, maxRequests, RATE_LIMIT_WINDOW)) {
                log.warn("Rate limit exceeded for client: {} on endpoint: {}", 
                    getClientIp(request), requestUri);
                
                sendRateLimitResponse(response, maxRequests);
                return;
            }
        } catch (Exception e) {
            // Fail open - if Redis is unavailable, allow the request
            log.warn("Rate limiting check failed, allowing request: {}", e.getMessage());
        }
        
        filterChain.doFilter(request, response);
    }
    
    /**
     * Builds a unique key for rate limiting based on client IP and endpoint.
     */
    private String buildRateLimitKey(HttpServletRequest request) {
        String clientIp = getClientIp(request);
        String endpoint = normalizeEndpoint(request.getRequestURI());
        return clientIp + ":" + endpoint;
    }
    
    /**
     * Extracts the client IP address, handling X-Forwarded-For headers.
     */
    private String getClientIp(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            // Take the first IP in the chain (original client)
            return xForwardedFor.split(",")[0].trim();
        }
        
        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isEmpty()) {
            return xRealIp.trim();
        }
        
        return request.getRemoteAddr();
    }
    
    /**
     * Normalizes the endpoint for grouping similar requests.
     * Removes path variables (numeric IDs) to group similar endpoints together.
     */
    private String normalizeEndpoint(String uri) {
        // Replace numeric path segments with placeholder
        // e.g., /api/v1/exercises/123 -> /api/v1/exercises/{id}
        return uri.replaceAll("/\\d+", "/{id}");
    }
    
    /**
     * Checks if the request path should be excluded from rate limiting.
     */
    private boolean isExcludedPath(String uri) {
        for (String excluded : EXCLUDED_PATHS) {
            if (uri.startsWith(excluded) || uri.contains(excluded)) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Checks if the endpoint is an authentication endpoint.
     */
    private boolean isAuthEndpoint(String uri) {
        return uri.contains(AUTH_PATH);
    }
    
    /**
     * Sends a 429 Too Many Requests response.
     */
    private void sendRateLimitResponse(HttpServletResponse response, int maxRequests) throws IOException {
        response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setHeader("Retry-After", "60");
        response.setHeader("X-RateLimit-Limit", String.valueOf(maxRequests));
        response.setHeader("X-RateLimit-Remaining", "0");
        
        String jsonResponse = String.format(
            "{\"success\":false,\"message\":\"Rate limit exceeded. Please try again in 60 seconds.\",\"error\":\"TOO_MANY_REQUESTS\",\"limit\":%d}",
            maxRequests
        );
        
        response.getWriter().write(jsonResponse);
        response.getWriter().flush();
    }
}
