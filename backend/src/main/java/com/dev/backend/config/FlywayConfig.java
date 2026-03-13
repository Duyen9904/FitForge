package com.dev.backend.config;

import org.flywaydb.core.Flyway;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.boot.autoconfigure.flyway.FlywayMigrationStrategy;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.DependsOn;

/**
 * Defers Flyway migration to run AFTER Hibernate has initialized the schema.
 *
 * Default Spring Boot order: Flyway → Hibernate (ddl-auto).
 * This causes failures on a fresh database because tables don't exist yet
 * when Flyway tries to INSERT seed data.
 *
 * This config reverses the order:
 *   1. Flyway bean created → migration is a no-op
 *   2. EntityManagerFactory created → Hibernate ddl-auto:update creates/updates tables
 *   3. DeferredFlywayMigration → actually runs flyway.migrate()
 */
@Configuration
public class FlywayConfig {

    /**
     * No-op strategy: prevents Flyway from migrating during its default init phase.
     */
    @Bean
    public FlywayMigrationStrategy flywayMigrationStrategy() {
        return flyway -> { /* deferred */ };
    }

    /**
     * Runs Flyway migration after EntityManagerFactory (Hibernate) is ready.
     */
    @Bean
    @DependsOn("entityManagerFactory")
    public InitializingBean deferredFlywayMigration(Flyway flyway) {
        return () -> {
            flyway.repair();  // clean up any failed migration entries
            flyway.migrate();
        };
    }
}
