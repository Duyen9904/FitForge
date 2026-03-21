package com.dev.backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;
import java.util.concurrent.ThreadPoolExecutor;

/**
 * Async configuration for AI task execution.
 * <p>
 * Provides a dedicated thread pool for AI/LLM calls so they don't
 * block Tomcat request threads (which are limited to ~200 by default).
 */
@Configuration
@EnableAsync
public class AsyncConfig {

    /**
     * Thread pool for AI operations (OpenRouter LLM calls).
     * <ul>
     *   <li>Core: 3 threads — handles typical concurrent AI requests</li>
     *   <li>Max: 5 threads — burst capacity</li>
     *   <li>Queue: 10 — backpressure before rejection</li>
     *   <li>CallerRunsPolicy — if pool + queue full, caller thread executes (graceful degradation)</li>
     * </ul>
     */
    @Bean("aiTaskExecutor")
    public Executor aiTaskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(3);
        executor.setMaxPoolSize(5);
        executor.setQueueCapacity(10);
        executor.setThreadNamePrefix("ai-");
        executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
        executor.initialize();
        return executor;
    }
}
