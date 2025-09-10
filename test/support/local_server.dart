import 'dart:async';
import 'dart:io';

class LocalPythonHttpServer {
  Process? _process;
  final int port;
  final String rootDir;

  LocalPythonHttpServer({required this.rootDir, this.port = 8000});

  Uri get uri => Uri.parse('http://127.0.0.1:$port/');

  Future<Process> start() async {
    if (_process != null) {
      throw StateError('Server is already running');
    }

    final pythonExecutable = await _detectPythonExecutable();

    _process = await Process.start(
      pythonExecutable,
      ['-m', 'http.server', port.toString(), '--directory', rootDir],
      workingDirectory: rootDir,
      mode: ProcessStartMode.inheritStdio,
    );

    // Wait a short delay to ensure server is ready
    await Future.delayed(Duration(seconds: 1));

    return _process!;
  }

  Future<void> stop() async {
    if (_process == null) {
      return;
    }

    final process = _process!;
    _process = null;

    try {
      // Try graceful shutdown first
      process.kill(ProcessSignal.sigint);
      final exitCode = await process.exitCode
          .timeout(Duration(seconds: 3), onTimeout: () => -1);

      if (exitCode == -1) {
        // Force kill if graceful shutdown failed
        process.kill(ProcessSignal.sigterm);
        await process.exitCode
            .timeout(Duration(seconds: 2), onTimeout: () => -1);
      }
    } catch (_) {
      // Ignore errors during stopping
    }
  }

  Future<String> _detectPythonExecutable() async {
    // Try python3 first
    try {
      final result = await Process.run('python3', ['--version']);
      if (result.exitCode == 0) {
        return 'python3';
      }
    } catch (_) {}

    // Fallback to python
    try {
      final result = await Process.run('python', ['--version']);
      if (result.exitCode == 0) {
        return 'python';
      }
    } catch (_) {}

    throw StateError('Python interpreter not found on system.');
  }
}
