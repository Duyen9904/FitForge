package com.dev.backend.service.impl;

import com.dev.backend.client.ExerciseAPIClient;
import com.dev.backend.model.dto.external.ExerciseDBResponse;
import com.dev.backend.model.dto.external.ExerciseDBV2ListResponse;
import com.dev.backend.model.entity.Exercise;
import com.dev.backend.service.ExerciseAPIService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Background sync worker that periodically pulls exercises from the ExerciseDB API
 * into the local database. This decouples the app from real-time API calls:
 * <ul>
 *   <li>Eliminates external API latency from the critical path</li>
 *   <li>Prevents rate limit issues with ExerciseDB</li>
 *   <li>Provides a complete local exercise catalog for offline operation</li>
 * </ul>
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class ExerciseSyncScheduler {

    private final ExerciseAPIClient exerciseAPIClient;
    private final ExerciseAPIService exerciseAPIService;

    @Value("${exercise.sync.enabled:true}")
    private boolean syncEnabled;

    @Value("${exercise.sync.on-startup:false}")
    private boolean syncOnStartup;

    /**
     * Run on application startup if configured.
     * Useful for populating a fresh database.
     */
    @EventListener(ApplicationReadyEvent.class)
    public void onStartup() {
        if (syncEnabled && syncOnStartup) {
            log.info("[SYNC] Startup sync enabled, triggering initial exercise sync...");
            syncExercisesFromAPI();
        }
    }

    /**
     * Scheduled weekly sync. Default: Sunday at 3:00 AM.
     * Configurable via exercise.sync.cron property.
     */
    @Scheduled(cron = "${exercise.sync.cron:0 0 3 * * SUN}")
    public void scheduledSync() {
        if (!syncEnabled) {
            log.info("[SYNC] Exercise sync is disabled, skipping scheduled sync");
            return;
        }
        syncExercisesFromAPI();
    }

    /**
     * Core sync logic: fetches all muscles from the API, then fetches exercises
     * for each muscle and persists them locally via ExerciseAPIService.
     */
    public void syncExercisesFromAPI() {
        log.info("[SYNC] ========== Starting ExerciseDB sync ==========");
        long start = System.currentTimeMillis();
        int syncedCount = 0;
        int errorCount = 0;

        try {
            // Fetch all known muscle groups from the API
            List<ExerciseDBV2ListResponse.Item> muscles = exerciseAPIClient.fetchMuscles();
            log.info("[SYNC] Found {} muscle groups to sync", muscles.size());

            for (ExerciseDBV2ListResponse.Item muscle : muscles) {
                try {
                    List<ExerciseDBResponse> exercises =
                            exerciseAPIClient.searchByTarget(muscle.getName(), 25);

                    for (ExerciseDBResponse resp : exercises) {
                        try {
                            Exercise saved = exerciseAPIService.getOrCreateFromResponse(resp);
                            if (saved != null) syncedCount++;
                        } catch (Exception e) {
                            errorCount++;
                            log.debug("[SYNC] Error saving exercise '{}': {}",
                                    resp.getName(), e.getMessage());
                        }
                    }

                    log.debug("[SYNC] Synced {} exercises for muscle: {}",
                            exercises.size(), muscle.getName());

                } catch (Exception e) {
                    errorCount++;
                    log.warn("[SYNC] Error fetching exercises for muscle '{}': {}",
                            muscle.getName(), e.getMessage());
                }
            }

            // Also sync by equipment types for broader coverage
            List<ExerciseDBV2ListResponse.Item> equipments = exerciseAPIClient.fetchEquipments();
            log.info("[SYNC] Found {} equipment types to sync", equipments.size());

            for (ExerciseDBV2ListResponse.Item equipment : equipments) {
                try {
                    List<ExerciseDBResponse> exercises =
                            exerciseAPIClient.searchByEquipment(equipment.getName(), 25);

                    for (ExerciseDBResponse resp : exercises) {
                        try {
                            Exercise saved = exerciseAPIService.getOrCreateFromResponse(resp);
                            if (saved != null) syncedCount++;
                        } catch (Exception e) {
                            // Likely duplicate — already synced via muscle group
                            log.trace("[SYNC] Skipping exercise '{}': {}", resp.getName(), e.getMessage());
                        }
                    }
                } catch (Exception e) {
                    log.warn("[SYNC] Error fetching exercises for equipment '{}': {}",
                            equipment.getName(), e.getMessage());
                }
            }

        } catch (Exception e) {
            log.error("[SYNC] Fatal error during exercise sync", e);
        }

        long elapsed = System.currentTimeMillis() - start;
        log.info("[SYNC] ========== Sync complete: {} exercises synced, {} errors, {} seconds ==========",
                syncedCount, errorCount, elapsed / 1000);
    }
}
