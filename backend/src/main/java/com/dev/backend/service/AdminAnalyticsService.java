package com.dev.backend.service;

import com.dev.backend.model.dto.response.AdminAnalyticsResponse;

/**
 * Service interface for admin analytics (UC-16.3)
 */
public interface AdminAnalyticsService {

    /**
     * Get system-wide analytics for admin dashboard
     */
    AdminAnalyticsResponse getSystemAnalytics();

    /**
     * Export analytics report as CSV
     */
    byte[] exportAnalyticsReport();
}
