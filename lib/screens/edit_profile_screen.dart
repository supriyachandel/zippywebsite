import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_state.dart';
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _userId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final u = context.read<UserState>();
    developer.log('UserState data: name=${u.userName}, email=${u.userEmail}, phone=${u.userPhone}, id=$_userId', name: 'EditProfile');

    _nameCtrl.text = u.userName ?? '';
    _emailCtrl.text = u.userEmail ?? '';
    _phoneCtrl.text = u.userPhone ?? '';

    try {
      await ApiService.loadToken();
      developer.log('Token loaded: ${ApiService.token != null}', name: 'EditProfile');

      final userData = await ApiService.getUser();
      developer.log('API response: $userData', name: 'EditProfile');

      if (!mounted) return;
      developer.log('Raw keys: ${userData.keys}', name: 'EditProfile');

      Map<String, dynamic> user = userData;
      if (userData['user'] is Map) {
        user = Map<String, dynamic>.from(userData['user']);
      } else if (userData['data'] is Map) {
        user = Map<String, dynamic>.from(userData['data']);
      }

      developer.log('User keys: ${user.keys}', name: 'EditProfile');

      final name = user['name']?.toString() ?? '';
      final email = user['email']?.toString() ?? '';
      final phone = user['phone']?.toString() ?? '';
      final image = user['image']?.toString();
      _userId = user['id']?.toString();

      developer.log('Parsed: name="$name", email="$email", phone="$phone", id=$_userId', name: 'EditProfile');

      _nameCtrl.text = name;
      _emailCtrl.text = email;
      _phoneCtrl.text = phone;

      if (name.isNotEmpty || email.isNotEmpty || phone.isNotEmpty) {
        u.updateProfile(name: name, email: email, phone: phone, image: image);
      }
    } catch (e) {
      developer.log('API load error: $e', name: 'EditProfile');
    }
  }

  Future<void> _save() async {
    if (_userId == null) {
      _showError('User ID not found. Try reloading.');
      return;
    }
    setState(() => _isSaving = true);
    try {
      await ApiService.loadToken();
      final data = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
      };
      if (_phoneCtrl.text.trim().isNotEmpty) {
        data['phone'] = _phoneCtrl.text.trim();
      }
      developer.log('Saving: $data for userId=$_userId', name: 'EditProfile');

      await ApiService.updateProfile(_userId!, data);
      developer.log('Save successful', name: 'EditProfile');

      if (!mounted) return;
      context.read<UserState>().updateProfile(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated"), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } catch (e) {
      developer.log('Save error: $e', name: 'EditProfile');
      if (mounted) _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String msg) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: cs.error, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text("EDIT PROFILE", style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildField("FULL NAME", _nameCtrl, Icons.person_outline_rounded),
            const SizedBox(height: 20),
            _buildField("EMAIL ADDRESS", _emailCtrl, Icons.alternate_email_rounded),
            const SizedBox(height: 20),
            _buildField("PHONE NUMBER", _phoneCtrl, Icons.phone_android_rounded, keyboardType: TextInputType.phone),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("SAVE CHANGES", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, {TextInputType? keyboardType}) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4), fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outline),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType ?? TextInputType.text,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: cs.onSurface),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 22, color: cs.onSurface.withValues(alpha: 0.4)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
