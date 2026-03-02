package com.dev.backend.client;

import com.dev.backend.model.dto.external.ExerciseDBResponse;
import io.netty.channel.ChannelOption;
import io.netty.handler.timeout.ReadTimeoutHandler;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.client.reactive.ReactorClientHttpConnector;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;
import reactor.netty.http.client.HttpClient;
import reactor.util.retry.Retry;

import java.time.Duration;
import java.util.List;
import java.util.concurrent.TimeUnit;

/**
 * Client for ExerciseDB API (RapidAPI)
 * Handles authentication, retry logic, and error handling for exercise data
 */
@Component
@Slf4j
public class ExerciseAPIClient {

    private final WebClient webClient;
    private final String apiKey;
    private final String apiHost;

    public ExerciseAPIClient(
            @Value("${exercisedb.api.base-url:https://exercisedb.p.rapidapi.com}") String baseUrl,
            @Value("${exercisedb.api.key:#{null}}") String apiKey,
            @Value("${exercisedb.api.host:exercisedb.p.rapidapi.com}") String apiHost) {
        this.apiKey = apiKey;
        this.apiHost = apiHost;

        HttpClient httpClient = HttpClient.create()
                .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, 5000)
                .doOnConnected(conn -> conn.addHandlerLast(
                        new ReadTimeoutHandler(15, TimeUnit.SECONDS)));

        this.webClient = WebClient.builder()
                .baseUrl(baseUrl)
                .clientConnector(new ReactorClientHttpConnector(httpClient))
                .build();
    }

    /**
     * Search exercises by target muscle group
     * @param target muscle group (e.g., "chest", "biceps", "quads")
     * @param limit number of results to return
     * @return list of exercises
     */
    public List<ExerciseDBResponse> searchByTarget(String target, int limit) {
        if (apiKey == null || apiKey.isBlank()) {
            log.warn("ExerciseDB API key not configured, returning empty list");
            return List.of();
        }

        try {
            log.info("Searching ExerciseDB for target: {}, limit: {}", target, limit);
            
            return webClient.get()
                    .uri(uriBuilder -> uriBuilder
                            .path("/exercises/target/{target}")
                            .build(target))
                    .header("X-RapidAPI-Key", apiKey)
                    .header("X-RapidAPI-Host", apiHost)
                    .retrieve()
                    .onStatus(HttpStatusCode::is4xxClientError, response -> {
                        log.error("ExerciseDB API client error: {}", response.statusCode());
                        return Mono.error(new RuntimeException("ExerciseDB API client error"));
                    })
                    .onStatus(HttpStatusCode::is5xxServerError, response -> {
                        log.error("ExerciseDB API server error: {}", response.statusCode());
                        return Mono.error(new RuntimeException("ExerciseDB API server error"));
                    })
                    .bodyToFlux(ExerciseDBResponse.class)
                    .take(limit)
                    .collectList()
                    .retryWhen(Retry.backoff(3, Duration.ofSeconds(2))
                            .maxBackoff(Duration.ofSeconds(10))
                            .doBeforeRetry(signal -> 
                                log.warn("Retrying ExerciseDB API call, attempt: {}", signal.totalRetries() + 1)))
                    .block(Duration.ofSeconds(30));
        } catch (Exception e) {
            log.error("Failed to fetch exercises from ExerciseDB for target: {}", target, e);
            return List.of();
        }
    }

    /**
     * Search exercises by equipment
     * @param equipment equipment type (e.g., "barbell", "dumbbell", "body weight")
     * @param limit number of results to return
     * @return list of exercises
     */
    public List<ExerciseDBResponse> searchByEquipment(String equipment, int limit) {
        if (apiKey == null || apiKey.isBlank()) {
            log.warn("ExerciseDB API key not configured, returning empty list");
            return List.of();
        }

        try {
            log.info("Searching ExerciseDB for equipment: {}, limit: {}", equipment, limit);
            
            return webClient.get()
                    .uri(uriBuilder -> uriBuilder
                            .path("/exercises/equipment/{equipment}")
                            .build(equipment))
                    .header("X-RapidAPI-Key", apiKey)
                    .header("X-RapidAPI-Host", apiHost)
                    .retrieve()
                    .onStatus(HttpStatusCode::is4xxClientError, response -> {
                        log.error("ExerciseDB API client error: {}", response.statusCode());
                        return Mono.error(new RuntimeException("ExerciseDB API client error"));
                    })
                    .onStatus(HttpStatusCode::is5xxServerError, response -> {
                        log.error("ExerciseDB API server error: {}", response.statusCode());
                        return Mono.error(new RuntimeException("ExerciseDB API server error"));
                    })
                    .bodyToFlux(ExerciseDBResponse.class)
                    .take(limit)
                    .collectList()
                    .retryWhen(Retry.backoff(3, Duration.ofSeconds(2))
                            .maxBackoff(Duration.ofSeconds(10))
                            .doBeforeRetry(signal -> 
                                log.warn("Retrying ExerciseDB API call, attempt: {}", signal.totalRetries() + 1)))
                    .block(Duration.ofSeconds(30));
        } catch (Exception e) {
            log.error("Failed to fetch exercises from ExerciseDB for equipment: {}", equipment, e);
            return List.of();
        }
    }

    /**
     * Search exercises by body part
     * @param bodyPart body part (e.g., "back", "chest", "legs")
     * @param limit number of results to return
     * @return list of exercises
     */
    public List<ExerciseDBResponse> searchByBodyPart(String bodyPart, int limit) {
        if (apiKey == null || apiKey.isBlank()) {
            log.warn("ExerciseDB API key not configured, returning empty list");
            return List.of();
        }

        try {
            log.info("Searching ExerciseDB for bodyPart: {}, limit: {}", bodyPart, limit);
            
            return webClient.get()
                    .uri(uriBuilder -> uriBuilder
                            .path("/exercises/bodyPart/{bodyPart}")
                            .build(bodyPart))
                    .header("X-RapidAPI-Key", apiKey)
                    .header("X-RapidAPI-Host", apiHost)
                    .retrieve()
                    .onStatus(HttpStatusCode::is4xxClientError, response -> {
                        log.error("ExerciseDB API client error: {}", response.statusCode());
                        return Mono.error(new RuntimeException("ExerciseDB API client error"));
                    })
                    .onStatus(HttpStatusCode::is5xxServerError, response -> {
                        log.error("ExerciseDB API server error: {}", response.statusCode());
                        return Mono.error(new RuntimeException("ExerciseDB API server error"));
                    })
                    .bodyToFlux(ExerciseDBResponse.class)
                    .take(limit)
                    .collectList()
                    .retryWhen(Retry.backoff(3, Duration.ofSeconds(2))
                            .maxBackoff(Duration.ofSeconds(10))
                            .doBeforeRetry(signal -> 
                                log.warn("Retrying ExerciseDB API call, attempt: {}", signal.totalRetries() + 1)))
                    .block(Duration.ofSeconds(30));
        } catch (Exception e) {
            log.error("Failed to fetch exercises from ExerciseDB for bodyPart: {}", bodyPart, e);
            return List.of();
        }
    }

    /**
     * Get exercise by ID
     * @param exerciseId exercise ID
     * @return exercise details
     */
    public ExerciseDBResponse getExerciseById(String exerciseId) {
        if (apiKey == null || apiKey.isBlank()) {
            log.warn("ExerciseDB API key not configured, returning null");
            return null;
        }

        try {
            log.info("Fetching ExerciseDB exercise by ID: {}", exerciseId);
            
            return webClient.get()
                    .uri(uriBuilder -> uriBuilder
                            .path("/exercises/exercise/{id}")
                            .build(exerciseId))
                    .header("X-RapidAPI-Key", apiKey)
                    .header("X-RapidAPI-Host", apiHost)
                    .retrieve()
                    .onStatus(HttpStatusCode::is4xxClientError, response -> {
                        log.error("ExerciseDB API client error: {}", response.statusCode());
                        return Mono.error(new RuntimeException("ExerciseDB API client error"));
                    })
                    .onStatus(HttpStatusCode::is5xxServerError, response -> {
                        log.error("ExerciseDB API server error: {}", response.statusCode());
                        return Mono.error(new RuntimeException("ExerciseDB API server error"));
                    })
                    .bodyToMono(ExerciseDBResponse.class)
                    .retryWhen(Retry.backoff(3, Duration.ofSeconds(2))
                            .maxBackoff(Duration.ofSeconds(10))
                            .doBeforeRetry(signal -> 
                                log.warn("Retrying ExerciseDB API call, attempt: {}", signal.totalRetries() + 1)))
                    .block(Duration.ofSeconds(30));
        } catch (Exception e) {
            log.error("Failed to fetch exercise from ExerciseDB with ID: {}", exerciseId, e);
            return null;
        }
    }
}
