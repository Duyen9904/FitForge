package com.dev.backend.model.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DataExportRequest {

    private List<ExportDataType> dataTypes;
    private ExportFormat format;
    private LocalDate startDate;
    private LocalDate endDate;

    public enum ExportDataType {
        WORKOUT_HISTORY,
        EXERCISE_LOGS,
        NUTRITION_LOGS,
        MEASUREMENTS,
        PROGRESS_PHOTOS
    }

    public enum ExportFormat {
        CSV,
        JSON,
        PDF
    }
}
