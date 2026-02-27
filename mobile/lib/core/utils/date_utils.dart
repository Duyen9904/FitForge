/// Date utilities for handling Java Instant and other date formats

/// Parses a date value that could be:
/// - ISO 8601 string from Java Instant (e.g., "2024-01-27T14:55:30Z")
/// - Epoch milliseconds as int
/// - Epoch milliseconds as String
/// - null
DateTime? parseDateTime(dynamic value) {
  if (value == null) return null;
  
  if (value is DateTime) return value;
  
  if (value is int) {
    // Epoch milliseconds
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  
  if (value is String) {
    // Try parsing as ISO 8601 string (Java Instant format)
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed;
    
    // Try parsing as epoch milliseconds string
    final epochMs = int.tryParse(value);
    if (epochMs != null) {
      return DateTime.fromMillisecondsSinceEpoch(epochMs);
    }
  }
  
  return null;
}

/// Converts DateTime to epoch milliseconds for API requests
int? dateTimeToEpochMs(DateTime? dateTime) {
  return dateTime?.millisecondsSinceEpoch;
}

/// Converts DateTime to ISO 8601 string for API requests
String? dateTimeToIso8601(DateTime? dateTime) {
  return dateTime?.toUtc().toIso8601String();
}

/// Converts DateTime to ISO date string (yyyy-MM-dd) for request bodies (e.g. LocalDate)
String? dateToIsoDateString(DateTime? dateTime) {
  if (dateTime == null) return null;
  final y = dateTime.year;
  final m = dateTime.month.toString().padLeft(2, '0');
  final d = dateTime.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
