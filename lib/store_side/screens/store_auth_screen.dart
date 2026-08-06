import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import '../services/store_auth_service.dart';
import '../services/store_api_service.dart';

class StoreAuthScreen extends StatefulWidget {
  const StoreAuthScreen({super.key});

  @override
  State<StoreAuthScreen> createState() => _StoreAuthScreenState();
}

class _StoreAuthScreenState extends State<StoreAuthScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  bool _showShopForm = false;
  String _selectedGender = 'male';

  final _authService = StoreAuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _shopPhoneController = TextEditingController();
  final _shopDescriptionController = TextEditingController();
  final _shopGstController = TextEditingController();
  final _shopAddressController = TextEditingController();
  final _shopCityController = TextEditingController();
  final _shopStateController = TextEditingController();
  final _shopZipController = TextEditingController();
  final _shopCountryController = TextEditingController(text: 'India');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _shopNameController.dispose();
    _shopPhoneController.dispose();
    _shopDescriptionController.dispose();
    _shopGstController.dispose();
    _shopAddressController.dispose();
    _shopCityController.dispose();
    _shopStateController.dispose();
    _shopZipController.dispose();
    _shopCountryController.dispose();
    super.dispose();
  }

  String _parseError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('Connection terminated')) {
      return 'No internet connection. Check server.';
    }
    if (msg.contains('422')) {
      final cleaned = msg.replaceAll('Exception: ', '');
      if (cleaned.length > 200) return '${cleaned.substring(0, 200)}...';
      return cleaned;
    }
    if (msg.contains('401')) {
      return 'Invalid email or password.';
    }
    if (msg.contains('500')) {
      return 'Server error. Please try again later.';
    }
    final cleaned = msg.replaceAll('Exception: ', '');
    if (cleaned.length > 200) return '${cleaned.substring(0, 200)}...';
    return cleaned;
  }

  void _handleAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please fill all fields');
      return;
    }
    if (!_isLogin && _nameController.text.isEmpty) {
      _showError('Please enter your name');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await _authService.login(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await _authService.register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          phone: _phoneController.text,
          gender: _selectedGender,
        );
      }
      await _authService.saveUserData(
        name: _nameController.text.isNotEmpty ? _nameController.text : _emailController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      );

      if (!mounted) return;

      // Check if user already has a shop (local prefs or API)
      var shopId = await StoreApiService.loadShopId();
      if (shopId == null || shopId == 0) {
        // Not in local prefs — try fetching from API
        final existingShop = await StoreApiService.getUserShop();
        if (existingShop != null) {
          shopId = StoreApiService.shopId;
        }
      }
      if (shopId == null || shopId == 0) {
        setState(() {
          _showShopForm = true;
          _isLoading = false;
          _shopNameController.text = _nameController.text.isNotEmpty ? '${_nameController.text}\'s Shop' : '';
          _shopPhoneController.text = _phoneController.text;
          _shopCountryController.text = 'India';
        });
      } else {
        await _authService.loadUserData();
        Navigator.pushReplacementNamed(context, '/store_home');
      }
    } catch (e) {
      if (mounted) _showError(_parseError(e));
    } finally {
      if (mounted && !_showShopForm) setState(() => _isLoading = false);
    }
  }

  void _handleCreateShop() async {
    if (_shopNameController.text.isEmpty) {
      _showError('Please enter your shop name');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.createShop(
        name: _shopNameController.text,
        phone: _shopPhoneController.text,
        description: _shopDescriptionController.text,
        gstNumber: _shopGstController.text,
        address: _shopAddressController.text,
        city: _shopCityController.text,
        state: _shopStateController.text,
        zip: _shopZipController.text,
        country: _shopCountryController.text,
        email: _emailController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/store_home');
    } catch (e) {
      if (mounted) _showError(_parseError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _toggleAuth() {
    setState(() {
      _isLogin = !_isLogin;
      _showShopForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/logo.png', width: 70, height: 70).animate().fadeIn().scale(),
              const SizedBox(height: 32),
              Text(
                _showShopForm
                    ? "CREATE\nYOUR SHOP"
                    : _isLogin
                        ? "SELLER\nLOGIN"
                        : "SELLER\nREGISTRATION",
                style: GoogleFonts.inter(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  color: AppColors.primaryDark,
                  letterSpacing: -1,
                ),
              ).animate().slideX(begin: -0.2, end: 0),
              const SizedBox(height: 12),
              Text(
                _showShopForm
                    ? "Set up your store on thStyle."
                    : _isLogin
                        ? "Access your dashboard and manage orders."
                        : "Start your digital journey with thStyle.",
                style: GoogleFonts.inter(
                  color: AppColors.primaryDark.withOpacity(0.5),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 48),

              if (_showShopForm) ..._buildShopForm()
              else ...[
                if (!_isLogin) ...[
                  _buildFieldLabel("FULL NAME"),
                  _buildTextField(_nameController, "Enter your name", Icons.person_outline),
                  const SizedBox(height: 20),
                  _buildFieldLabel("PHONE NUMBER"),
                  _buildTextField(_phoneController, "Enter contact number", Icons.phone_android_outlined),
                  const SizedBox(height: 16),
                  _buildGenderChips(),
                  const SizedBox(height: 20),
                ],
                _buildFieldLabel("EMAIL ADDRESS"),
                _buildTextField(_emailController, "Enter your email", Icons.email_outlined),
                const SizedBox(height: 20),
                _buildFieldLabel("PASSWORD"),
                _buildTextField(_passwordController, "Enter your password", Icons.lock_outline, isPassword: true),

                const SizedBox(height: 40),

                _buildAuthButton(
                  _isLogin ? "LOGIN TO DASHBOARD" : "REGISTER AS SELLER",
                  _handleAuth,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: _toggleAuth,
                    child: Text(
                      _isLogin ? "Don't have a shop? Register now" : "Already a seller? Login here",
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildShopForm() {
    return [
      _buildFieldLabel("SHOP NAME"),
      _buildTextField(_shopNameController, "Your business name", Icons.store_outlined),
      const SizedBox(height: 20),
      _buildFieldLabel("SHOP PHONE"),
      _buildTextField(_shopPhoneController, "Contact number", Icons.phone_android_outlined),
      const SizedBox(height: 20),
      _buildFieldLabel("DESCRIPTION (Optional)"),
      _buildTextField(_shopDescriptionController, "Describe your shop", Icons.description_outlined),
      const SizedBox(height: 20),
      _buildFieldLabel("GST NUMBER (Optional)"),
      _buildTextField(_shopGstController, "GSTIN", Icons.receipt_long_outlined),
      const SizedBox(height: 20),
      _buildFieldLabel("ADDRESS (Optional)"),
      _buildTextField(_shopAddressController, "Street address", Icons.location_on_outlined),
      const SizedBox(height: 20),
      _buildFieldLabel("CITY (Optional)"),
      _buildTextField(_shopCityController, "City", Icons.location_city_outlined),
      const SizedBox(height: 20),
      _buildFieldLabel("STATE (Optional)"),
      _buildTextField(_shopStateController, "State", Icons.map_outlined),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildFieldLabel("ZIP CODE (Optional)"),
            _buildTextField(_shopZipController, "ZIP", Icons.markunread_mailbox_outlined),
          ])),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildFieldLabel("COUNTRY (Optional)"),
            _buildTextField(_shopCountryController, "Country", Icons.public_outlined),
          ])),
        ],
      ),
      const SizedBox(height: 40),
      _buildAuthButton("CREATE MY SHOP", _handleCreateShop).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
    ];
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryDark.withOpacity(0.4),
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softGrey),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
          prefixIcon: Icon(icon, color: AppColors.primaryDark.withOpacity(0.3), size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }

  Widget _buildGenderChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("GENDER", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryDark.withOpacity(0.4), letterSpacing: 1)),
        const SizedBox(height: 10),
        Row(
          children: ['male', 'female', 'other'].map((g) => Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(g[0].toUpperCase() + g.substring(1)),
              selected: _selectedGender == g,
              onSelected: (_) => setState(() => _selectedGender = g),
              selectedColor: AppColors.primaryDark,
              labelStyle: TextStyle(color: _selectedGender == g ? Colors.white : AppColors.primaryDark, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildAuthButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
