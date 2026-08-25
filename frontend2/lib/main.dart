import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const Frontend2App());
}

// ─────────────────────────────────────────────────────────────────────────────
// OIDC Configuration — ชี้ไปที่ backend2
// ─────────────────────────────────────────────────────────────────────────────
class OidcConfig {
  static const String issuer = 'http://localhost:8001';
  static const String clientId = 'flutter-frontend2';
  static const String clientSecret = 'flutter-frontend2-secret';
  // Fixed port 4200 — run: flutter run -d chrome --web-port 4200
  static const String redirectUri = 'http://localhost:4200';
  static const List<String> scopes = ['openid', 'email', 'profile'];

  static String buildAuthorizationUrl() {
    final params = {
      'client_id': clientId,
      'response_type': 'code',
      'scope': scopes.join(' '),
      'redirect_uri': redirectUri,
    };
    return '$issuer/openid/authorize?${Uri(queryParameters: params).query}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App
// ─────────────────────────────────────────────────────────────────────────────
class Frontend2App extends StatelessWidget {
  const Frontend2App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frontend2 — OIDC Auth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00897B),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const OidcCallbackHandler(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OIDC Callback Handler — ตรวจสอบ URL ว่ามี ?code= กลับมาหรือไม่
// ─────────────────────────────────────────────────────────────────────────────
class OidcCallbackHandler extends StatefulWidget {
  const OidcCallbackHandler({super.key});

  @override
  State<OidcCallbackHandler> createState() => _OidcCallbackHandlerState();
}

class _OidcCallbackHandlerState extends State<OidcCallbackHandler> {
  bool _loading = true;
  String? _idToken;
  String? _accessToken;
  String? _error;

  @override
  void initState() {
    super.initState();
    _handleStartup();
  }

  Future<void> _handleStartup() async {
    // ตรวจสอบว่า URL มี ?code= (callback จาก backend2) หรือไม่
    final uri = Uri.parse(html.window.location.href);
    final code = uri.queryParameters['code'];

    if (code != null && code.isNotEmpty) {
      // ล้าง code ออกจาก URL
      html.window.history.replaceState(null, '', OidcConfig.redirectUri);
      await _exchangeCode(code);
    } else {
      // ตรวจสอบว่า login ไว้แล้วหรือยัง
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('id_token');
      setState(() {
        _idToken = saved;
        _accessToken = prefs.getString('access_token');
        _loading = false;
      });
    }
  }

  Future<void> _exchangeCode(String code) async {
    try {
      final response = await http
          .post(
            Uri.parse('${OidcConfig.issuer}/openid/token'),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {
              'grant_type': 'authorization_code',
              'code': code,
              'redirect_uri': OidcConfig.redirectUri,
              'client_id': OidcConfig.clientId,
              'client_secret': OidcConfig.clientSecret,
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final idToken = (data['id_token'] as String?) ?? '';
        final accessToken = (data['access_token'] as String?) ?? '';
        final refreshToken = (data['refresh_token'] as String?) ?? '';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('id_token', idToken);
        await prefs.setString('access_token', accessToken);
        await prefs.setString('refresh_token', refreshToken);

        setState(() {
          _idToken = idToken;
          _accessToken = accessToken;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Token exchange failed (${response.statusCode}):\n${response.body}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error exchanging code: $e\n\nMake sure backend2 is running at ${OidcConfig.issuer}';
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id_token');
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    setState(() {
      _idToken = null;
      _accessToken = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_idToken != null && _idToken!.isNotEmpty) {
      return OidcHomePage(
        idToken: _idToken!,
        accessToken: _accessToken ?? '',
        onLogout: _logout,
      );
    }
    return OidcLoginPage(error: _error);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOGIN PAGE
// ─────────────────────────────────────────────────────────────────────────────
class OidcLoginPage extends StatelessWidget {
  final String? error;
  const OidcLoginPage({super.key, this.error});

  void _startOidcLogin() {
    // Redirect browser ไปยัง backend2 authorization endpoint
    html.window.location.assign(OidcConfig.buildAuthorizationUrl());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.security_rounded,
                        size: 64, color: theme.colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(
                      'Frontend2',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'OpenID Connect Authentication',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Info card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('OIDC Server (backend2)',
                              style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(OidcConfig.issuer,
                              style: const TextStyle(
                                  fontFamily: 'monospace', fontSize: 12)),
                          Text('Client ID: ${OidcConfig.clientId}',
                              style: const TextStyle(fontSize: 12)),
                          Text('Redirect URI: ${OidcConfig.redirectUri}',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),

                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(error!,
                            style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                                fontSize: 12)),
                      ),
                    ],
                    const SizedBox(height: 20),

                    FilledButton.icon(
                      onPressed: _startOidcLogin,
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Login with OIDC'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'คลิก Login เพื่อไปหน้า login ของ backend2\n'
                      'กรอก admin / admin123',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME PAGE (หลัง OIDC login สำเร็จ)
// ─────────────────────────────────────────────────────────────────────────────
class OidcHomePage extends StatelessWidget {
  final String idToken;
  final String accessToken;
  final VoidCallback onLogout;

  const OidcHomePage({
    super.key,
    required this.idToken,
    required this.accessToken,
    required this.onLogout,
  });

  String _preview(String t) =>
      t.length > 50 ? '${t.substring(0, 50)}...' : t;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frontend2 — OIDC Home'),
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: onLogout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.verified_user,
                          color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('OIDC Login Successful!',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 16),
                    _tokenRow(context, 'ID Token', idToken),
                    const SizedBox(height: 12),
                    _tokenRow(context, 'Access Token', accessToken),
                  ],
                ),
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tokenRow(BuildContext context, String label, String token) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label:', style: theme.textTheme.labelMedium),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(_preview(token),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
        ),
      ],
    );
  }
}
