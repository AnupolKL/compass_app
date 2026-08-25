import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const Frontend2App());
}

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
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OIDC Configuration
// ─────────────────────────────────────────────────────────────────────────────

/// OIDC server settings — pointing to backend2
class OidcConfig {
  // Change to your backend2 address when testing on a physical device
  static const String issuer = 'http://10.0.2.2:8001';
  static const String clientId = 'flutter-frontend2';
  static const String clientSecret = 'flutter-frontend2-secret';
  static const String redirectUri = 'com.example.frontend2://callback';
  static const List<String> scopes = ['openid', 'email', 'profile'];

  static const String discoveryUrl =
      '$issuer/openid/.well-known/openid-configuration';
}

// ─────────────────────────────────────────────────────────────────────────────
// AUTH GATE
// ─────────────────────────────────────────────────────────────────────────────

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  String? _idToken;
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _idToken = prefs.getString('id_token');
      _accessToken = prefs.getString('access_token');
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_idToken != null) {
      return OidcHomePage(
        idToken: _idToken!,
        accessToken: _accessToken ?? '',
        onLogout: _logout,
      );
    }
    return OidcLoginPage(onLoginSuccess: _onLoginSuccess);
  }

  void _onLoginSuccess(String idToken, String accessToken) {
    setState(() {
      _idToken = idToken;
      _accessToken = accessToken;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id_token');
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    setState(() {
      _idToken = null;
      _accessToken = null;
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOGIN PAGE
// ─────────────────────────────────────────────────────────────────────────────

class OidcLoginPage extends StatefulWidget {
  final void Function(String idToken, String accessToken) onLoginSuccess;
  const OidcLoginPage({super.key, required this.onLoginSuccess});

  @override
  State<OidcLoginPage> createState() => _OidcLoginPageState();
}

class _OidcLoginPageState extends State<OidcLoginPage> {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  bool _loading = false;
  String? _errorMessage;

  Future<void> _loginWithOidc() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          OidcConfig.clientId,
          OidcConfig.redirectUri,
          clientSecret: OidcConfig.clientSecret,
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: '${OidcConfig.issuer}/openid/authorize',
            tokenEndpoint: '${OidcConfig.issuer}/openid/token',
          ),
          scopes: OidcConfig.scopes,
        ),
      );

      if (result != null) {
        final idToken = result.idToken ?? '';
        final accessToken = result.accessToken ?? '';
        final refreshToken = result.refreshToken ?? '';

        // Persist session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('id_token', idToken);
        await prefs.setString('access_token', accessToken);
        await prefs.setString('refresh_token', refreshToken);

        widget.onLoginSuccess(idToken, accessToken);
      } else {
        setState(() => _errorMessage = 'Authorization cancelled or failed.');
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'OIDC Error: ${e.toString()}\n\nMake sure backend2 is running at ${OidcConfig.issuer}';
      });
    } finally {
      setState(() => _loading = false);
    }
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
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
                    const SizedBox(height: 28),

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
                                fontWeight: FontWeight.bold,
                              )),
                          const SizedBox(height: 4),
                          Text(OidcConfig.issuer,
                              style: const TextStyle(
                                  fontFamily: 'monospace', fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('Client ID: ${OidcConfig.clientId}',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Error message
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                              color: theme.colorScheme.onErrorContainer,
                              fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Login button
                    FilledButton.icon(
                      onPressed: _loading ? null : _loginWithOidc,
                      icon: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.open_in_browser),
                      label: Text(
                          _loading ? 'Opening browser...' : 'Login with OIDC'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'คลิก Login เพื่อเปิดหน้า login ของ backend2\n'
                      'กรอก username: admin / password: admin123',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
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
// HOME PAGE (after OIDC login)
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

  String _preview(String token) =>
      token.length > 40 ? '${token.substring(0, 40)}...' : token;

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
                    Row(
                      children: [
                        Icon(Icons.verified_user,
                            color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('OIDC Login Successful',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
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
          child: Text(
            _preview(token),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
        ),
      ],
    );
  }
}
