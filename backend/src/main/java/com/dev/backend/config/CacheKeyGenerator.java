package com.dev.backend.config;

import org.springframework.cache.interceptor.KeyGenerator;
import org.springframework.stereotype.Component;

import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.stream.Collectors;

/**
 * Custom cache key generator for consistent and readable cache keys.
 * 
 * Key format: ClassName:methodName:param1:param2:...
 * Example: ExerciseServiceImpl:getExerciseById:123
 */
@Component("customKeyGenerator")
public class CacheKeyGenerator implements KeyGenerator {
    
    private static final String SEPARATOR = ":";
    
    @Override
    public Object generate(Object target, Method method, Object... params) {
        StringBuilder keyBuilder = new StringBuilder();
        
        // Add class name (simple name, not fully qualified)
        keyBuilder.append(target.getClass().getSimpleName())
                  .append(SEPARATOR)
                  .append(method.getName());
        
        // Add parameters
        if (params != null && params.length > 0) {
            String paramsKey = Arrays.stream(params)
                .map(this::toKeyPart)
                .collect(Collectors.joining(SEPARATOR));
            
            keyBuilder.append(SEPARATOR).append(paramsKey);
        }
        
        return keyBuilder.toString();
    }
    
    /**
     * Converts a parameter to a string suitable for use in a cache key.
     */
    private String toKeyPart(Object param) {
        if (param == null) {
            return "null";
        }
        
        // For collections and arrays, use their hash code
        if (param instanceof Iterable || param.getClass().isArray()) {
            return String.valueOf(param.hashCode());
        }
        
        return param.toString();
    }
}
