import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/user_state.dart';
import '../utils/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  bool _showEmailLogin = false;
  bool _showRegister = false;
  bool _isLoading = false;
  String _selectedGender = 'male';
  bool _obscurePassword = true;

  late final AnimationController _fadeController;

  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  String? _latitude;
  String? _longitude;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: 400.ms);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      _latitude = position.latitude.toString();
      _longitude = position.longitude.toString();
    } catch (_) {}
  }

  Gender _genderFromString(String g) {
    switch (g) {
      case 'male': return Gender.male;
      case 'female': return Gender.female;
      default: return Gender.other;
    }
  }

  String _parseError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('Personal access client not found')) return 'Server auth setup incomplete.';
    if (msg.contains('SocketException') || msg.contains('timeout')) return 'No internet connection.';
    if (msg.contains('422')) {
      final cleaned = msg.replaceAll('Exception: ', '').replaceAll('Failed to register: ', '').replaceAll('Failed to login: ', '');
      return cleaned.length > 100 ? '${cleaned.substring(0, 100)}...' : cleaned;
    }
    if (msg.contains('401')) return 'Invalid email or password.';
    if (msg.contains('google_sign_in')) return 'Google Play Services not available. Please update Google services on your device.';
    if (msg.contains('Network is unreachable') || msg.contains('Connection refused')) return 'Backend server not running. Start your server and try again.';
    return 'An unexpected error occurred.';
  }

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please fill all fields');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      final rawToken = response['token'] ?? response['data']?['token'] ?? response['access_token'] ?? '';
      final token = (rawToken is String && rawToken.isNotEmpty) ? rawToken : null;
      final userData = response['user'] ?? response['data'] ?? {};
      if (token == null) throw Exception('No token in response');

      await ApiService.setToken(token);
      final userState = Provider.of<UserState>(context, listen: false);
      userState.login(token, name: userData['name']?.toString(), email: userData['email']?.toString(), phone: userData['phone']?.toString(), image: userData['image']?.toString());
      if (userData['gender'] != null) {
        userState.setGender(_genderFromString(userData['gender'].toString()));
      }
      await _authService.saveUserData(name: userData['name']?.toString() ?? _emailController.text, email: userData['email']?.toString() ?? _emailController.text, phone: userData['phone']?.toString(), image: userData['image']?.toString());

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (mounted) _showError(_parseError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleRegister() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty || _phoneController.text.isEmpty) {
      _showError('Please fill all fields');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _getCurrentLocation();
      final response = await _authService.register(
        name: _nameController.text, email: _emailController.text, password: _passwordController.text, phone: _phoneController.text,
        gender: _selectedGender, latitude: _latitude, longitude: _longitude,
      );
      if (!mounted) return;
      final rawToken = response['token'] ?? response['data']?['token'] ?? response['access_token'] ?? '';
      final token = (rawToken is String && rawToken.isNotEmpty) ? rawToken : null;
      final userData = response['user'] ?? response['data'] ?? {};
      if (token == null) throw Exception('No token in response');

      await ApiService.setToken(token);
      final userState = Provider.of<UserState>(context, listen: false);
      userState.login(token, name: userData['name']?.toString() ?? _nameController.text, email: userData['email']?.toString() ?? _emailController.text, phone: userData['phone']?.toString() ?? _phoneController.text, image: userData['image']?.toString());
      userState.setGender(_genderFromString(_selectedGender));
      await _authService.saveUserData(name: _nameController.text, email: _emailController.text, phone: _phoneController.text);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (mounted) _showError(_parseError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final response = await _authService.signInWithGoogle();
      if (!mounted) return;
      final rawToken = response['token'] ?? response['data']?['token'] ?? response['access_token'] ?? '';
      final token = (rawToken is String && rawToken.isNotEmpty) ? rawToken : null;
      final userData = response['user'] ?? response['data'] ?? {};
      if (token == null) throw Exception('No token in response');

      await ApiService.setToken(token);
      final userState = Provider.of<UserState>(context, listen: false);
      userState.login(token, name: userData['name']?.toString(), email: userData['email']?.toString(), phone: userData['phone']?.toString(), image: userData['image']?.toString());
      if (userData['gender'] != null) {
        userState.setGender(_genderFromString(userData['gender'].toString()));
      }
      await _authService.saveUserData(name: userData['name']?.toString() ?? 'Google User', email: userData['email']?.toString() ?? '');

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (mounted) _showError(_parseError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: theme.colorScheme.error, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    );
  }

  void _navigateTo(String screen) {
    _fadeController.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _showEmailLogin = screen == 'login';
        _showRegister = screen == 'register';
      });
      _fadeController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_showEmailLogin || _showRegister) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: _buildLoginFormContent(cs),
      );
    }

    return Scaffold(
      backgroundColor: cs.surface,
      body: _buildLandingContent(cs),
    );
  }

  Widget _buildLoginFormContent(ColorScheme cs) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => _navigateTo('landing'),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: cs.onSurface),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _showRegister ? "Create Account" : "Welcome Back",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _showRegister
                  ? "Sign up to start shopping"
                  : "Sign in to continue shopping",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 36),
            FadeTransition(
              opacity: _fadeController,
              child: _showRegister ? _buildRegisterForm(cs) : _buildLoginForm(cs),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLandingContent(ColorScheme cs) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            child: Image.asset(
              'assets/onboard.png',
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.62,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                height: MediaQuery.of(context).size.height * 0.65,
                color: cs.primary.withValues(alpha: 0.1),
                child: Icon(Icons.shopping_bag, size: 80, color: cs.primary),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Text(
                  "Your Style,\nYour Statement",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                    letterSpacing: -1,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Discover the latest trends in fashion.\nShop from the best brands near you.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: const Text(
                      "Continue with Google",
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 0.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.surface,
                      foregroundColor: cs.onSurface,
                      elevation: 0,
                      side: BorderSide(color: cs.outlineVariant),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _navigateTo('login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text(
                            "Get Started",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => _navigateTo('register'),
                  child: Text(
                    "New here? Create Account",
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Image.asset('assets/logo.png', width: 50, height: 50, errorBuilder: (c, e, s) => Icon(Icons.shopping_bag, size: 40, color: cs.primary)),
        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 24),
        Text(
          _showRegister ? "Create Account" : _showEmailLogin ? "Welcome Back" : "Fashion at\nHigh Speed",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -1, color: cs.onSurface),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildLanding() {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        _buildSocialButton("Continue with Email", Icons.email_rounded, () => _navigateTo('login'), isPrimary: true, cs: cs),
        const SizedBox(height: 12),
        _buildSocialButton("New here? Register", Icons.person_add_rounded, () => _navigateTo('register'), isPrimary: false, cs: cs),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: Divider(color: cs.outline)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text("SECURE AUTH", style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
          Expanded(child: Divider(color: cs.outline)),
        ]),
      ],
    );
  }

  Widget _buildLoginForm(ColorScheme cs) {
    return Column(
      children: [
        _buildModernField("Email Address", _emailController, _emailFocus, Icons.alternate_email_rounded, textInputAction: TextInputAction.next, cs: cs),
        const SizedBox(height: 16),
        _buildModernField("Password", _passwordController, _passwordFocus, Icons.lock_outline_rounded, isPassword: true, onSubmitted: _handleLogin, cs: cs),
        const SizedBox(height: 28),
        _buildGradientButton("SIGN IN", _handleLogin, cs),
        const SizedBox(height: 16),
        _buildBackLink(cs),
      ],
    ).animate().fadeIn();
  }

  Widget _buildRegisterForm(ColorScheme cs) {
    return Column(
      children: [
        _buildModernField("Full Name", _nameController, _nameFocus, Icons.person_outline_rounded, textInputAction: TextInputAction.next, cs: cs),
        const SizedBox(height: 16),
        _buildModernField("Email Address", _emailController, _emailFocus, Icons.alternate_email_rounded, textInputAction: TextInputAction.next, cs: cs),
        const SizedBox(height: 16),
        _buildModernField("Phone Number", _phoneController, _phoneFocus, Icons.phone_android_rounded, keyboardType: TextInputType.phone, textInputAction: TextInputAction.next, cs: cs),
        const SizedBox(height: 20),
        _buildModernGenderPicker(cs),
        const SizedBox(height: 20),
        _buildModernField("Password", _passwordController, _passwordFocus, Icons.lock_outline_rounded, isPassword: true, onSubmitted: _handleRegister, cs: cs),
        const SizedBox(height: 28),
        _buildGradientButton("GET STARTED", _handleRegister, cs),
        const SizedBox(height: 16),
        _buildBackLink(cs),
      ],
    ).animate().fadeIn();
  }

  Widget _buildModernField(String hint, TextEditingController ctrl, FocusNode focus, IconData icon, {bool isPassword = false, TextInputType? keyboardType, TextInputAction? textInputAction, VoidCallback? onSubmitted, required ColorScheme cs}) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: focus.hasFocus ? cs.primary.withValues(alpha: 0.4) : Colors.transparent, width: 1),
      ),
      child: TextField(
        controller: ctrl,
        focusNode: focus,
        obscureText: isPassword ? _obscurePassword : false,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted: (_) => onSubmitted?.call(),
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: cs.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.4), fontSize: 14, fontWeight: FontWeight.w400),
          prefixIcon: Icon(icon, size: 20, color: focus.hasFocus ? cs.primary : cs.onSurface.withValues(alpha: 0.4)),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20, color: cs.onSurface.withValues(alpha: 0.4)),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildModernGenderPicker(ColorScheme cs) {
    return Row(
      children: ['male', 'female', 'other'].map((g) {
        bool isSelected = _selectedGender == g;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedGender = g);
              context.read<UserState>().setGender(_genderFromString(g));
            },
            child: AnimatedContainer(
              duration: 200.ms,
              margin: EdgeInsets.only(right: g == 'other' ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? cs.primary : cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? cs.primary : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  g[0].toUpperCase() + g.substring(1),
                  style: TextStyle(
                    color: isSelected ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGradientButton(String label, VoidCallback onPressed, ColorScheme cs) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: [cs.primary, cs.secondary]),
        boxShadow: [
          BoxShadow(color: cs.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: _isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildSocialButton(String label, IconData icon, VoidCallback onTap, {required bool isPrimary, required ColorScheme cs}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isPrimary ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? null : Border.all(color: cs.outline, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isPrimary ? cs.onPrimary : cs.onSurface, size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: isPrimary ? cs.onPrimary : cs.onSurface, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildBackLink(ColorScheme cs) {
    return TextButton(
      onPressed: () => _navigateTo('landing'),
      child: Text("Go Back", style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4), fontWeight: FontWeight.w600)),
    );
  }
}
