import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_state.dart';
import '../services/api_service.dart';
import 'address_list_screen.dart';
import 'order_history_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _orderCount = 0;
  int _addressCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      await ApiService.loadToken();
      final results = await Future.wait([
        ApiService.getPurchases(),
        ApiService.getAddresses(),
      ]);
      if (mounted) {
        setState(() {
          _orderCount = results[0].length;
          _addressCount = results[1].length;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final userState = Provider.of<UserState>(context);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Profile", style: TextStyle(color: cs.onSurface, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  IconButton(
                    icon: Icon(Icons.refresh_rounded, color: cs.onSurface),
                    onPressed: _loadStats,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildProfileCard(cs, userState),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard(Icons.shopping_bag_outlined, _orderCount.toString(), "ORDERS", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryScreen())), cs)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(Icons.location_on_outlined, _addressCount.toString(), "ADDRESSES", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressListScreen())), cs),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(Icons.local_offer_outlined, "5", "COUPONS", () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Coupons coming soon!"), behavior: SnackBarBehavior.floating)), cs)),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionHeader(cs, "ORDERS"),
              const SizedBox(height: 12),
              _buildMenuItem(Icons.receipt_long_outlined, "My Orders", "View order history", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryScreen())), cs),
              const SizedBox(height: 24),
              _buildSectionHeader(cs, "ACCOUNT SETTINGS"),
              const SizedBox(height: 12),
              _buildMenuItem(Icons.location_on_outlined, "Saved Addresses", "${_addressCount} address(es) saved", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressListScreen())), cs),
              _buildMenuItem(Icons.person_outline, "Edit Profile", "Name, Email, Phone", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())).then((_) => _loadStats()), cs),
              const SizedBox(height: 24),
              _buildSectionHeader(cs, "SUPPORT"),
              const SizedBox(height: 12),
              _buildMenuItem(Icons.help_outline, "Help Center", "FAQs, Customer Support", () => showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text("Help Center", style: TextStyle(fontWeight: FontWeight.bold)),
                  content: const Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("📞 +91 1800-123-4567", style: TextStyle(fontSize: 14)),
                    SizedBox(height: 8),
                    Text("✉️ support@zippystyle.in", style: TextStyle(fontSize: 14)),
                    SizedBox(height: 8),
                    Text("💬 Live chat: 9 AM - 9 PM", style: TextStyle(fontSize: 14)),
                  ]),
                  actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("GOT IT"))],
                ),
              ), cs),
              _buildMenuItem(Icons.policy_outlined, "Privacy Policy", "Data usage, Terms", () => showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text("Privacy Policy", style: TextStyle(fontWeight: FontWeight.bold)),
                  content: const Text(
                    "ZippyStyle values your privacy. We collect only necessary data (name, email, address) to process your orders. "
                    "Your data is encrypted and never shared with third parties without consent. "
                    "You can request data deletion anytime by contacting support.",
                    style: TextStyle(fontSize: 13, height: 1.5),
                  ),
                  actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("GOT IT"))],
                ),
              ), cs),
              const SizedBox(height: 32),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: const Text("LOG OUT", style: TextStyle(fontWeight: FontWeight.bold)),
                        content: const Text("Are you sure you want to log out?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL", style: TextStyle(color: Colors.grey))),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await userState.logout();
                              if (context.mounted) Navigator.pushReplacementNamed(context, '/auth');
                            },
                            child: const Text("LOG OUT", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                  label: const Text("LOG OUT", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(ColorScheme cs, UserState userState) {
    final displayName = userState.userName ?? 'Guest User';
    final displayEmail = userState.userEmail ?? 'Not logged in';
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(2),
          child: CircleAvatar(
            radius: 35,
            backgroundColor: cs.surfaceContainerHighest,
            child: Icon(Icons.person, color: cs.onSurface, size: 35),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(displayName, style: TextStyle(color: cs.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(displayEmail, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 13)),
                ])),
        InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())).then((_) => _loadStats()),
          child: Icon(Icons.edit_outlined, color: cs.onSurface.withValues(alpha: 0.3), size: 20),
        ),
      ]),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, VoidCallback onTap, ColorScheme cs) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(children: [
          Icon(icon, color: cs.onSurface, size: 20),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: cs.onSurface, fontSize: 18, fontWeight: FontWeight.w900)),
          Text(label, style: TextStyle(color: cs.onSurface.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ]),
      ),
    );
  }

  Widget _buildSectionHeader(ColorScheme cs, String title) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(title, style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
  );

  Widget _buildMenuItem(IconData icon, String title, String subtitle, VoidCallback onTap, ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: cs.onSurface, size: 20),
        ),
        title: Text(title, style: TextStyle(color: cs.onSurface, fontSize: 15, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 12)),
        trailing: Icon(Icons.chevron_right, color: cs.onSurface.withOpacity(0.3), size: 20),
      ),
    );
  }
}
