class ServerBusyException implements Exception {
  final String message;

  ServerBusyException(
      [this.message =
          'Servers are busy updating jobs. Please wait a moment for jobs to appear...']);

  @override
  String toString() => message;
}
