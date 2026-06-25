/// Exception classes for the data layer.
///
/// These are thrown by datasources and caught by repository implementations
/// to be converted into Failure types.

class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'Cache error occurred'});

  @override
  String toString() => 'CacheException: $message';
}

class DatabaseException implements Exception {
  final String message;
  const DatabaseException({this.message = 'Database error occurred'});

  @override
  String toString() => 'DatabaseException: $message';
}

class ValidationException implements Exception {
  final String message;
  const ValidationException({this.message = 'Validation error occurred'});

  @override
  String toString() => 'ValidationException: $message';
}

class ImageException implements Exception {
  final String message;
  const ImageException({this.message = 'Image processing error occurred'});

  @override
  String toString() => 'ImageException: $message';
}
