package com.dev.backend.config;

/**
 * Centralized cache name constants for Redis caching.
 * Use these constants with @Cacheable, @CacheEvict, and @CachePut annotations.
 */
public final class CacheNames {
    
    private CacheNames() {
        // Prevent instantiation
    }
    
    // ==================== Static Reference Data ====================
    /** All exercises - TTL: 24 hours */
    public static final String EXERCISES = "exercises";
    
    /** Single exercise by ID - TTL: 24 hours */
    public static final String EXERCISE_BY_ID = "exercise-by-id";
    
    /** All muscle groups - TTL: 24 hours */
    public static final String MUSCLE_GROUPS = "muscle-groups";
    
    /** All equipment - TTL: 24 hours */
    public static final String EQUIPMENT = "equipment";
    
    /** Achievement definitions - TTL: 24 hours */
    public static final String ACHIEVEMENTS = "achievements";
    
    /** Goal definitions - TTL: 24 hours */
    public static final String GOALS = "goals";
    
    // ==================== User-Specific Data ====================
    /** User profile data - TTL: 1 hour */
    public static final String USER_PROFILE = "user-profile";
    
    /** User preferences - TTL: 1 hour */
    public static final String USER_PREFERENCES = "user-preferences";
    
    /** User achievements - TTL: 1 hour */
    public static final String USER_ACHIEVEMENTS = "user-achievements";
    
    /** User workout plans - TTL: 1 hour */
    public static final String USER_WORKOUT_PLANS = "user-workout-plans";
    
    /** User exercise recommendations - TTL: 15 minutes */
    public static final String USER_RECOMMENDATIONS = "user-recommendations";
    
    /** AI-generated plan structures (workout/nutrition) - TTL: 24 hours */
    public static final String AI_PLANS = "ai-plans";
    
    // ==================== Dashboard & Analytics ====================
    /** Generic dashboard data - TTL: 15 minutes */
    public static final String DASHBOARD = "dashboard";
    
    /** Statistics data - TTL: 15 minutes */
    public static final String STATISTICS = "statistics";
    
    /** Report data - TTL: 15 minutes */
    public static final String REPORTS = "reports";
    
    // ==================== Session & Security ====================
    /** Refresh tokens - TTL: 7 days */
    public static final String REFRESH_TOKENS = "refresh-tokens";
    
    /** Blacklisted tokens - TTL: 24 hours */
    public static final String TOKEN_BLACKLIST = "token-blacklist";
    
    /** Rate limiting counters - TTL: 1 minute */
    public static final String RATE_LIMIT = "rate-limit";
}
