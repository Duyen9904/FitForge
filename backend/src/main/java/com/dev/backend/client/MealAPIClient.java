package com.dev.backend.client;

import com.dev.backend.model.dto.external.EdamamRecipeResponse;
import io.netty.channel.ChannelOption;
import io.netty.handler.timeout.ReadTimeoutHandler;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.client.reactive.ReactorClientHttpConnector;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.util.UriComponentsBuilder;
import reactor.core.publisher.Mono;
import reactor.netty.http.client.HttpClient;
import reactor.util.retry.Retry;

import java.time.Duration;
import java.util.List;
import java.util.concurrent.TimeUnit;

/**
 * Client for Edamam Recipe Search API
 * Handles authentication, retry logic, and error handling for meal/recipe data
 */
@Component
@Slf4j
public class MealAPIClient {

    private final WebClient webClient;
    private final String appId;
    private final String appKey;

    public MealAPIClient(
            @Value("${edamam.api.base-url:https://api.edamam.com}") String baseUrl,
            @Value("${edamam.api.app-id:#{null}}") String appId,
            @Value("${edamam.api.app-key:#{null}}") String appKey) {
        this.appId = appId;
        this.appKey = appKey;

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
     * Search recipes by meal type and calorie range
     * @param mealType meal type (breakfast, lunch, dinner, snack)
     * @param minCalories minimum calories per serving
     * @param maxCalories maximum calories per serving
     * @param limit number of results to return
     * @return recipe search response
     */
    public EdamamRecipeResponse searchRecipes(String mealType, int minCalories, int maxCalories, int limit) {
        if (appId == null || appId.isBlank() || appKey == null || appKey.isBlank()) {
            log.warn("Edamam API credentials not configured, returning empty response");
            return new EdamamRecipeResponse(0, 0, 0, List.of());
        }

        try {
            log.info("Searching Edamam recipes for mealType: {}, calories: {}-{}, limit: {}", 
                    mealType, minCalories, maxCalories, limit);
            
            String uri = UriComponentsBuilder.fromPath("/api/recipes/v2")
                    .queryParam("type", "public")
                    .queryParam("app_id", appId)
                    .queryParam("app_key", appKey)
                    .queryParam("mealType", mealType)
                    .queryParam("calories", minCalories + "-" + maxCalories)
                    .queryParam("to", limit)
                    .build()
                    .toUriString();

            return webClient.get()
                    .uri(uri)
                    .retrieve()
                    .onStatus(HttpStatusCode::is4xxClientError, response -> {
                        log.error("Edamam API client error: {}", response.statusCode());
                        return Mono.error(new RuntimeException("Edamam API client error"));
                    })
                    .onStatus(HttpStatusCode::is5xxServerError, response -> {
                        log.error("Edamam API server error: {}", response.statusCode());
                        return Mono.error(new RuntimeException("Edamam API server error"));
                    })
                    .bodyToMono(EdamamRecipeResponse.class)
                    .retryWhen(Retry.backoff(3, Duration.ofSeconds(2))
                            .maxBackoff(Duration.ofSeconds(10))
                            .doBeforeRetry(signal -> 
                                log.warn("Retrying Edamam API call, attempt: {}", signal.totalRetries() + 1)))
                    .block(Duration.ofSeconds(30));
        } catch (Exception e) {
            log.error("Failed to fetch recipes from Edamam for mealType: {}", mealType, e);
            return new EdamamRecipeResponse(0, 0, 0, List.of());
        }
    }

    /**
     * Search recipes with dietary restrictions
     * @param mealType meal type (breakfast, lunch, dinner, snack)
     * @param minCalories minimum calories per serving
     * @param maxCalories maximum calories per serving
     * @param diet dietary restriction (e.g., high-protein, low-carb, balanced)
     * @param limit number of results to return
     * @return recipe search response
     */
    public EdamamRecipeResponse searchRecipesWithDiet(String mealType, int minCalories, int maxCalories, 
                                                       String diet, int limit) {
        if (appId == null || appId.isBlank() || appKey == null || appKey.isBlank()) {
            log.warn("Edamam API credentials not configured, returning empty response");
            return new EdamamRecipeResponse(0, 0, 0, List.of());
        }

        try {
            log.info("Searching Edamam recipes for mealType: {}, calories: {}-{}, diet: {}, limit: {}", 
                    mealType, minCalories, maxCalories, diet, limit);
            
            UriComponentsBuilder builder = UriComponentsBuilder.fromPath("/api/recipes/v2")
                    .queryParam("type", "public")
                    .queryParam("app_id", appId)
                    .queryParam("app_key", appKey)
                    .queryParam("mealType", mealType)
                    .queryParam("calories", minCalories + "-" + maxCalories)
                    .queryParam("to", limit);

            // Add diet parameter if specified
            if (diet != null && !diet.isBlank()) {
                builder.queryParam("diet", diet.toLowerCase());
            }

            String uri = builder.build().toUriString();

            return webClient.get()
                    .uri(uri)
                    .retrieve()
                    .onStatus(HttpStatusCode::is4xxClientError, response -> {
                        log.error("Edamam API client error: {}", response.statusCode());
                        return Mono.error(new RuntimeException("Edamam API client error"));
                    })
                    .onStatus(HttpStatusCode::is5xxServerError, response -> {
                        log.error("Edamam API server error: {}", response.statusCode());
                        return Mono.error(new RuntimeException("Edamam API server error"));
                    })
                    .bodyToMono(EdamamRecipeResponse.class)
                    .retryWhen(Retry.backoff(3, Duration.ofSeconds(2))
                            .maxBackoff(Duration.ofSeconds(10))
                            .doBeforeRetry(signal -> 
                                log.warn("Retrying Edamam API call, attempt: {}", signal.totalRetries() + 1)))
                    .block(Duration.ofSeconds(30));
        } catch (Exception e) {
            log.error("Failed to fetch recipes from Edamam for mealType: {} with diet: {}", mealType, diet, e);
            return new EdamamRecipeResponse(0, 0, 0, List.of());
        }
    }

    /**
     * Search recipes by query and calorie range
     * @param query search query (e.g., "chicken", "salad", "pasta")
     * @param minCalories minimum calories per serving
     * @param maxCalories maximum calories per serving
     * @param limit number of results to return
     * @return recipe search response
     */
    public EdamamRecipeResponse searchByQuery(String query, int minCalories, int maxCalories, int limit) {
        if (appId == null || appId.isBlank() || appKey == null || appKey.isBlank()) {
            log.warn("Edamam API credentials not configured, returning empty response");
            return new EdamamRecipeResponse(0, 0, 0, List.of());
        }

        try {
            log.info("Searching Edamam recipes for query: {}, calories: {}-{}, limit: {}", 
                    query, minCalories, maxCalories, limit);
            
            String uri = UriComponentsBuilder.fromPath("/api/recipes/v2")
                    .queryParam("type", "public")
                    .queryParam("app_id", appId)
                    .queryParam("app_key", appKey)
                    .queryParam("q", query)
                    .queryParam("calories", minCalories + "-" + maxCalories)
                    .queryParam("to", limit)
                    .build()
                    .toUriString();

            return webClient.get()
                    .uri(uri)
                    .retrieve()
                    .onStatus(HttpStatusCode::is4xxClientError, response -> {
                        log.error("Edamam API client error: {}", response.statusCode());
                        return Mono.error(new RuntimeException("Edamam API client error"));
                    })
                    .onStatus(HttpStatusCode::is5xxServerError, response -> {
                        log.error("Edamam API server error: {}", response.statusCode());
                        return Mono.error(new RuntimeException("Edamam API server error"));
                    })
                    .bodyToMono(EdamamRecipeResponse.class)
                    .retryWhen(Retry.backoff(3, Duration.ofSeconds(2))
                            .maxBackoff(Duration.ofSeconds(10))
                            .doBeforeRetry(signal -> 
                                log.warn("Retrying Edamam API call, attempt: {}", signal.totalRetries() + 1)))
                    .block(Duration.ofSeconds(30));
        } catch (Exception e) {
            log.error("Failed to fetch recipes from Edamam for query: {}", query, e);
            return new EdamamRecipeResponse(0, 0, 0, List.of());
        }
    }
}
