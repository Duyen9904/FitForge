package com.dev.backend.client;

import com.dev.backend.model.dto.external.ExerciseDBResponse;
import com.dev.backend.model.dto.external.ExerciseDBV2ListResponse;
import com.dev.backend.model.dto.external.ExerciseDBV2PageResponse;
import com.dev.backend.model.dto.external.ExerciseDBV2SingleResponse;
import com.dev.backend.model.dto.request.ExerciseSearchRequest;
import io.netty.channel.ChannelOption;
import io.netty.handler.timeout.ReadTimeoutHandler;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.client.reactive.ReactorClientHttpConnector;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.ExchangeFilterFunction;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;
import reactor.netty.http.client.HttpClient;
import reactor.util.retry.Retry;

import java.time.Duration;
import java.util.List;
import java.util.concurrent.TimeUnit;

/**
 * Client for ExerciseDB v2 API
 * Free API at https://exercisedbv2.ascendapi.com — no authentication required.
 * Handles timeouts, retry logic with backoff, and error handling.
 */
@Component
@Slf4j
public class ExerciseAPIClient {

    private final WebClient webClient;

    public ExerciseAPIClient(
            @Value("${exercisedb.api.base-url:https://exercisedbv2.ascendapi.com}") String baseUrl,
            @Value("${exercisedb.api.key:#{null}}") String apiKey,
            @Value("${exercisedb.api.host:#{null}}") String apiHost) {

        HttpClient httpClient = HttpClient.create()
                .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, 5000)
                .doOnConnected(conn -> conn.addHandlerLast(
                        new ReadTimeoutHandler(15, TimeUnit.SECONDS)));

        WebClient.Builder builder = WebClient.builder()
                .baseUrl(baseUrl)
                .clientConnector(new ReactorClientHttpConnector(httpClient))
                .defaultHeader("Content-Type", "application/json")
                .filter(logRequest());

        // Add RapidAPI headers if configured
        if (apiKey != null && !apiKey.isBlank()) {
            builder.defaultHeader("x-rapidapi-key", apiKey);
        }
        if (apiHost != null && !apiHost.isBlank()) {
            builder.defaultHeader("x-rapidapi-host", apiHost);
        }

        this.webClient = builder.build();

        log.info("ExerciseAPIClient initialized with base URL: {}", baseUrl);
    }

    /**
     * Search exercises with filters.
     * Maps to GET /api/v1/exercises with all supported query params.
     *
     * @param request search request containing all optional filters
     * @return list of exercises
     */
    public List<ExerciseDBResponse> searchExercises(ExerciseSearchRequest request) {
        try {
            long startTime = System.currentTimeMillis();
            log.info("Searching ExerciseDB v2: {}", request);

            ExerciseDBV2PageResponse response = webClient.get()
                    .uri(uriBuilder -> {
                        uriBuilder.path("/api/v1/exercises");
                        addIfPresent(uriBuilder, "name", request.getName());
                        addIfPresent(uriBuilder, "keywords", request.getKeywords());
                        addIfPresent(uriBuilder, "targetMuscles", request.getTargetMuscles());
                        addIfPresent(uriBuilder, "secondaryMuscles", request.getSecondaryMuscles());
                        addIfPresent(uriBuilder, "exerciseType", request.getExerciseType());
                        addIfPresent(uriBuilder, "bodyParts", request.getBodyParts());
                        addIfPresent(uriBuilder, "equipments", request.getEquipments());
                        addIfPresent(uriBuilder, "after", request.getAfter());
                        addIfPresent(uriBuilder, "before", request.getBefore());
                        uriBuilder.queryParam("limit",
                                request.getLimit() != null ? Math.min(Math.max(request.getLimit(), 1), 25) : 10);
                        return uriBuilder.build();
                    })
                    .retrieve()
                    .onStatus(HttpStatusCode::is4xxClientError, resp -> {
                        log.error("ExerciseDB v2 API client error: {}", resp.statusCode());
                        return Mono.error(new RuntimeException("ExerciseDB v2 API client error: " + resp.statusCode()));
                    })
                    .onStatus(HttpStatusCode::is5xxServerError, resp -> {
                        log.error("ExerciseDB v2 API server error: {}", resp.statusCode());
                        return Mono.error(new RuntimeException("ExerciseDB v2 API server error: " + resp.statusCode()));
                    })
                    .bodyToMono(ExerciseDBV2PageResponse.class)
                    .retryWhen(Retry.backoff(3, Duration.ofSeconds(2))
                            .maxBackoff(Duration.ofSeconds(10))
                            .doBeforeRetry(signal ->
                                log.warn("Retrying ExerciseDB v2 API call, attempt: {}", signal.totalRetries() + 1)))
                    .block(Duration.ofSeconds(30));

            long elapsed = System.currentTimeMillis() - startTime;
            log.info("ExerciseDB v2 API response received in {}ms", elapsed);
            log.debug("ExerciseDB v2 searchExercises response data: {}", response);

            return response != null && response.getData() != null ? response.getData() : List.of();
        } catch (Exception e) {
            log.error("Failed to search exercises from ExerciseDB v2: {}", request, e);
            return List.of();
        }
    }

    /** Adds a query param only if the value is non-null and non-blank. */
    private void addIfPresent(org.springframework.web.util.UriBuilder uriBuilder,
                              String paramName, String value) {
        if (value != null && !value.isBlank()) {
            uriBuilder.queryParam(paramName, value);
        }
    }

    /**
     * Search exercises by name/keyword.
     * Maps to GET /api/v1/exercises/search
     *
     * @param query  search term
     * @param limit  max results
     * @return matching exercises
     */
    public List<ExerciseDBResponse> searchByName(String query, int limit) {
        try {
            long startTime = System.currentTimeMillis();
            log.info("Searching ExerciseDB v2 by name: query={}, limit={}", query, limit);

            ExerciseDBV2PageResponse response = webClient.get()
                    .uri(uriBuilder -> uriBuilder
                            .path("/api/v1/exercises/search")
                            .queryParam("search", query)
                            .queryParam("limit", limit)
                            .build())
                    .retrieve()
                    .onStatus(HttpStatusCode::is4xxClientError, resp -> {
                        log.error("ExerciseDB v2 API client error: {}", resp.statusCode());
                        return Mono.error(new RuntimeException("ExerciseDB v2 API client error: " + resp.statusCode()));
                    })
                    .onStatus(HttpStatusCode::is5xxServerError, resp -> {
                        log.error("ExerciseDB v2 API server error: {}", resp.statusCode());
                        return Mono.error(new RuntimeException("ExerciseDB v2 API server error: " + resp.statusCode()));
                    })
                    .bodyToMono(ExerciseDBV2PageResponse.class)
                    .retryWhen(Retry.backoff(3, Duration.ofSeconds(2))
                            .maxBackoff(Duration.ofSeconds(10))
                            .doBeforeRetry(signal ->
                                log.warn("Retrying ExerciseDB v2 search, attempt: {}", signal.totalRetries() + 1)))
                    .block(Duration.ofSeconds(30));

            long elapsed = System.currentTimeMillis() - startTime;
            log.info("ExerciseDB v2 search response in {}ms", elapsed);
            log.debug("ExerciseDB v2 searchByName response data: {}", response);

            return response != null && response.getData() != null ? response.getData() : List.of();
        } catch (Exception e) {
            log.error("Failed to search ExerciseDB v2 by name: {}", query, e);
            return List.of();
        }
    }

    /**
     * Get a single exercise by its ID.
     * Maps to GET /api/v1/exercises/{exerciseId}
     *
     * @param exerciseId exercise ID
     * @return exercise details or null if not found
     */
    public ExerciseDBResponse getExerciseById(String exerciseId) {
        try {
            long startTime = System.currentTimeMillis();
            log.info("Fetching ExerciseDB v2 exercise by ID: {}", exerciseId);

            // Single-exercise endpoint returns { "success": true, "data": { ... } }
            // where "data" is a single object, NOT an array
            ExerciseDBV2SingleResponse response = webClient.get()
                    .uri(uriBuilder -> uriBuilder
                            .path("/api/v1/exercises/{exerciseId}")
                            .build(exerciseId))
                    .retrieve()
                    .onStatus(HttpStatusCode::is4xxClientError, resp -> {
                        log.error("ExerciseDB v2 API client error: {}", resp.statusCode());
                        return Mono.error(new RuntimeException("ExerciseDB v2 API client error: " + resp.statusCode()));
                    })
                    .onStatus(HttpStatusCode::is5xxServerError, resp -> {
                        log.error("ExerciseDB v2 API server error: {}", resp.statusCode());
                        return Mono.error(new RuntimeException("ExerciseDB v2 API server error: " + resp.statusCode()));
                    })
                    .bodyToMono(ExerciseDBV2SingleResponse.class)
                    .retryWhen(Retry.backoff(3, Duration.ofSeconds(2))
                            .maxBackoff(Duration.ofSeconds(10))
                            .doBeforeRetry(signal ->
                                log.warn("Retrying ExerciseDB v2 API call, attempt: {}", signal.totalRetries() + 1)))
                    .block(Duration.ofSeconds(30));

            long elapsed = System.currentTimeMillis() - startTime;
            log.info("ExerciseDB v2 exercise fetch completed in {}ms", elapsed);

            if (response != null && response.getData() != null) {
                log.debug("ExerciseDB v2 getExerciseById result: id={}, name={}",
                        response.getData().getExerciseId(), response.getData().getName());
                return response.getData();
            }

            log.warn("ExerciseDB v2 returned null data for exercise ID: {}", exerciseId);
            return null;
        } catch (Exception e) {
            log.error("Failed to fetch exercise from ExerciseDB v2 with ID: {}", exerciseId, e);
            return null;
        }
    }

    // ============= Convenience methods wrapping the old interface =============

    /**
     * Search exercises by target muscle group.
     */
    public List<ExerciseDBResponse> searchByTarget(String target, int limit) {
        return searchExercises(ExerciseSearchRequest.builder()
                .targetMuscles(target).limit(limit).build());
    }

    /**
     * Search exercises by equipment.
     */
    public List<ExerciseDBResponse> searchByEquipment(String equipment, int limit) {
        return searchExercises(ExerciseSearchRequest.builder()
                .equipments(equipment).limit(limit).build());
    }

    /**
     * Search exercises by body part.
     */
    public List<ExerciseDBResponse> searchByBodyPart(String bodyPart, int limit) {
        return searchExercises(ExerciseSearchRequest.builder()
                .bodyParts(bodyPart).limit(limit).build());
    }

    /**
     * Fetch all available equipments from the API.
     * Maps to GET /api/v1/equipments
     */
    public List<ExerciseDBV2ListResponse.Item> fetchEquipments() {
        return fetchReferenceList("/api/v1/equipments", "equipments");
    }

    /**
     * Fetch all available muscles from the API.
     * Maps to GET /api/v1/muscles
     */
    public List<ExerciseDBV2ListResponse.Item> fetchMuscles() {
        return fetchReferenceList("/api/v1/muscles", "muscles");
    }

    /**
     * Fetch all available exercise types from the API.
     * Maps to GET /api/v1/exercisetypes
     */
    public List<ExerciseDBV2ListResponse.Item> fetchExerciseTypes() {
        return fetchReferenceList("/api/v1/exercisetypes", "exercisetypes");
    }

    /**
     * Generic helper for fetching simple reference-data lists from the v2 API.
     */
    private List<ExerciseDBV2ListResponse.Item> fetchReferenceList(String path, String label) {
        try {
            long startTime = System.currentTimeMillis();
            log.info("Fetching {} from ExerciseDB v2", label);

            ExerciseDBV2ListResponse response = webClient.get()
                    .uri(path)
                    .retrieve()
                    .onStatus(HttpStatusCode::is4xxClientError, resp -> {
                        log.error("ExerciseDB v2 {} client error: {}", label, resp.statusCode());
                        return Mono.error(new RuntimeException("ExerciseDB v2 " + label + " error: " + resp.statusCode()));
                    })
                    .onStatus(HttpStatusCode::is5xxServerError, resp -> {
                        log.error("ExerciseDB v2 {} server error: {}", label, resp.statusCode());
                        return Mono.error(new RuntimeException("ExerciseDB v2 " + label + " error: " + resp.statusCode()));
                    })
                    .bodyToMono(ExerciseDBV2ListResponse.class)
                    .retryWhen(Retry.backoff(3, Duration.ofSeconds(2))
                            .maxBackoff(Duration.ofSeconds(10))
                            .doBeforeRetry(signal ->
                                log.warn("Retrying {} fetch, attempt: {}", label, signal.totalRetries() + 1)))
                    .block(Duration.ofSeconds(30));

            long elapsed = System.currentTimeMillis() - startTime;
            log.info("ExerciseDB v2 {} fetched in {}ms", label, elapsed);

            return response != null && response.getData() != null ? response.getData() : List.of();
        } catch (Exception e) {
            log.error("Failed to fetch {} from ExerciseDB v2", label, e);
            return List.of();
        }
    }

    /**
     * Logs outgoing HTTP requests as full curl commands for debugging.
     */
    private ExchangeFilterFunction logRequest() {
        return ExchangeFilterFunction.ofRequestProcessor(clientRequest -> {
            StringBuilder curl = new StringBuilder("curl -X ")
                    .append(clientRequest.method().name())
                    .append(" '").append(clientRequest.url()).append("'");
            clientRequest.headers().forEach((name, values) ->
                    values.forEach(value -> curl.append(" -H '").append(name).append(": ").append(value).append("'")));
            log.info("External API request: {}", curl);
            return Mono.just(clientRequest);
        });
    }
}
