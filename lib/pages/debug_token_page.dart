import 'package:circlo_app/core/network/api_client.dart';
import 'package:circlo_app/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Temporary debug screen — remove before production.
/// Access it by temporarily making it the home in your router,
/// or navigating to it from any screen.
class DebugTokenPage extends StatefulWidget {
  const DebugTokenPage({super.key});

  @override
  State<DebugTokenPage> createState() => _DebugTokenPageState();
}

class _DebugTokenPageState extends State<DebugTokenPage> {
  final _storage = SecureStorageService();
  String? _token;
  String _apiResult = 'Not tested yet';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await _storage.getToken();
    setState(() => _token = token);
  }

  Future<void> _testGetPosts() async {
    setState(() {
      _loading = true;
      _apiResult = 'Testing...';
    });
    try {
      final dio = DioClient().dio;
      final response = await dio.get('/api/post/get-all-posts');
      setState(() {
        _apiResult =
            '✅ Success! Status: ${response.statusCode}\n'
            'Posts count: ${(response.data['posts'] as List?)?.length ?? 0}';
      });
    } on DioException catch (e) {
      setState(() {
        _apiResult =
            '❌ DioException\n'
            'Status: ${e.response?.statusCode}\n'
            'Type: ${e.type}\n'
            'Server message: ${e.response?.data}\n'
            'Error: ${e.message}';
      });
    } catch (e) {
      setState(() => _apiResult = '❌ Unknown error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _clearToken() async {
    await _storage.deleteToken();
    await _loadToken();
    setState(() => _apiResult = 'Token cleared');
  }

  @override
  Widget build(BuildContext context) {
    final hasToken = _token != null && _token!.isNotEmpty;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          '🛠 Debug: Token & API',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Token status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: hasToken
                    ? Colors.green.withOpacity(0.15)
                    : Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: hasToken ? Colors.green : Colors.red),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasToken
                        ? '🔑 Token is SAVED in storage'
                        : '🚫 Token is NULL — not logged in!',
                    style: TextStyle(
                      color: hasToken ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (hasToken) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: _token!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Token copied!')),
                        );
                      },
                      child: Text(
                        _token!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '(tap to copy full token)',
                      style: TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _testGetPosts,
                    icon: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_download_rounded),
                    label: const Text('Test GET /posts'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _loadToken,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            TextButton(
              onPressed: _clearToken,
              child: const Text(
                'Clear token (force logout)',
                style: TextStyle(color: Colors.red),
              ),
            ),

            const SizedBox(height: 16),

            // API result
            const Text(
              'API Result:',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _apiResult,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
