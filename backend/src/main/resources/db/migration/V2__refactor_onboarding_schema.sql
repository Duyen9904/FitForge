-- =====================================================
-- V2 REFACTOR ONBOARDING SCHEMA
-- =====================================================
-- Refactors the onboarding schema into:
-- 1. onboarding_flows
-- 2. onboarding_steps
-- 3. user_onboardings
-- 4. user_onboarding_steps
-- Drops legacy tables: user_onboarding_progress, onboarding_option, onboarding_step
-- =====================================================

DROP TABLE IF EXISTS user_onboarding_progress;
DROP TABLE IF EXISTS onboarding_option;
DROP TABLE IF EXISTS onboarding_step;

CREATE TABLE IF NOT EXISTS onboarding_flows (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    flow_key VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    version INT NOT NULL DEFAULT 1,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uk_onboarding_flow_key_version UNIQUE (flow_key, version)
);

CREATE TABLE IF NOT EXISTS onboarding_steps (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    flow_id BIGINT NOT NULL,
    step_key VARCHAR(50) NOT NULL,
    title VARCHAR(100) NOT NULL,
    sequence INT NOT NULL,
    is_required BOOLEAN NOT NULL DEFAULT TRUE,
    config JSON,
    CONSTRAINT uk_onboarding_step_flow_key UNIQUE (flow_id, step_key),
    CONSTRAINT fk_onboarding_steps_flow FOREIGN KEY (flow_id) REFERENCES onboarding_flows (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS user_onboardings (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    flow_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'IN_PROGRESS',
    current_step_id BIGINT NULL,
    started_at DATETIME(6) NOT NULL,
    completed_at DATETIME(6) NULL,
    CONSTRAINT fk_user_onboardings_user FOREIGN KEY (user_id) REFERENCES user (user_id) ON DELETE CASCADE,
    CONSTRAINT fk_user_onboardings_flow FOREIGN KEY (flow_id) REFERENCES onboarding_flows (id) ON DELETE CASCADE,
    CONSTRAINT fk_user_onboardings_current_step FOREIGN KEY (current_step_id) REFERENCES onboarding_steps (id) ON DELETE SET NULL,
    INDEX idx_user_onboardings_user (user_id),
    INDEX idx_user_onboardings_flow (flow_id)
);

CREATE TABLE IF NOT EXISTS user_onboarding_steps (
    onboarding_id BIGINT NOT NULL,
    step_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    answer_data JSON NULL,
    started_at DATETIME(6) NULL,
    completed_at DATETIME(6) NULL,
    updated_at DATETIME(6) NOT NULL,
    PRIMARY KEY (onboarding_id, step_id),
    CONSTRAINT fk_user_onboarding_steps_onboarding FOREIGN KEY (onboarding_id) REFERENCES user_onboardings (id) ON DELETE CASCADE,
    CONSTRAINT fk_user_onboarding_steps_step FOREIGN KEY (step_id) REFERENCES onboarding_steps (id) ON DELETE CASCADE,
    INDEX idx_user_onboarding_steps_step (step_id)
);
