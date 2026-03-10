package com.dev.backend.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.cloud.storage.Storage;
import com.google.cloud.storage.StorageOptions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

import java.io.IOException;
import java.io.InputStream;

/**
 * Configuration for Google Cloud Storage media uploads.
 */
@Configuration
public class GcsConfig {

    private static final Logger logger = LoggerFactory.getLogger(GcsConfig.class);

    @Value("${gcs.credentials.path:firebase-service-account.json}")
    private String credentialsPath;

    @Value("${gcs.enabled:false}")
    private boolean gcsEnabled;

    @Bean
    public Storage gcsStorage() {
        if (!gcsEnabled) {
            logger.info("GCS is disabled. Media upload will not be available.");
            return null;
        }

        try {
            ClassPathResource resource = new ClassPathResource(credentialsPath);

            if (!resource.exists()) {
                logger.warn("GCS credentials file not found at: {}. Media upload will be disabled.", credentialsPath);
                return null;
            }

            try (InputStream serviceAccount = resource.getInputStream()) {
                GoogleCredentials credentials = GoogleCredentials.fromStream(serviceAccount);
                Storage storage = StorageOptions.newBuilder()
                        .setCredentials(credentials)
                        .build()
                        .getService();
                logger.info("GCS Storage client initialized successfully");
                return storage;
            }
        } catch (IOException e) {
            logger.error("Failed to initialize GCS Storage client: {}", e.getMessage());
            return null;
        }
    }
}
