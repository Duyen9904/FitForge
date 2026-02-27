package com.dev.backend.model.enums;

/**
 * Source of body measurement data.
 */
public enum MeasurementSource {
    /** Manually entered by user */
    MANUAL,
    
    /** Imported from InBody device report via OCR */
    INBODY_IMPORT
}
