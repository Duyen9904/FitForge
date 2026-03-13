# Project Rules

## Backend Communication

- **All `DateTime` values sent to the backend MUST use UTC.** Always call `.toUtc()` on `DateTime` instances before they are serialized into request DTOs (e.g., `DateTime.now().toUtc()`). The Java backend deserializes timestamps as `java.time.Instant`, which requires the ISO 8601 `Z` suffix that only UTC-mode `DateTime` objects produce.
