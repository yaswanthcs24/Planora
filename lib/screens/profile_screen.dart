import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ProfileScreen — shows user info, stats, and logout
// Receives tasks from MainScreen to calculate real stats
// ─────────────────────────────────────────────────────────────────────────────
class ProfileScreen extends StatelessWidget {
  final List<Task> tasks;

  const ProfileScreen({super.key, required this.tasks});

  // ── Get the currently logged-in user from Firebase ───────────────────────
  User? get _user => FirebaseAuth.instance.currentUser;

  // ── Calculate real stats from tasks ──────────────────────────────────────
  int    get _totalTasks     => tasks.length;
  int    get _completedTasks => tasks.where((t) => t.isDone).length;
  double get _totalHours     => tasks.fold(0.0, (sum, t) => sum + t.hours);
  double get _hoursLogged    =>
      tasks.where((t) => t.isDone).fold(0.0, (sum, t) => sum + t.hours);
  int    get _subjectCount   =>
      tasks.map((t) => t.subject).toSet().length;

  // ── Get initials from email ───────────────────────────────────────────────
  String get _initials {
    final email = _user?.email ?? '';
    if (email.isEmpty) return 'U';
    return email[0].toUpperCase();
  }

  // ── Handle logout ─────────────────────────────────────────────────────────
  Future<void> _logout(BuildContext context) async {
    // Show confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Sign out?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        content: const Text(
          'You will be taken back to the login screen.',
          style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false, // clear entire navigation stack
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Header ───────────────────────────────────────────────────
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 24),

              // ── User avatar + email card ──────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.borderColor, width: 0.5),
                ),
                child: Column(
                  children: [
                    // Avatar circle with initials
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppTheme.primaryLight,
                      child: Text(
                        _initials,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Email
                    Text(
                      _user?.email ?? 'No email',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Firebase verified badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _user?.emailVerified == true
                              ? Icons.verified_rounded
                              : Icons.info_outline_rounded,
                          size: 13,
                          color: _user?.emailVerified == true
                              ? AppTheme.success
                              : AppTheme.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _user?.emailVerified == true
                              ? 'Verified account'
                              : 'Email not verified',
                          style: TextStyle(
                            fontSize: 12,
                            color: _user?.emailVerified == true
                                ? AppTheme.success
                                : AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Stats section ─────────────────────────────────────────────
              const Text(
                'Your stats',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),

              // Stats grid — 2 columns
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.2,
                children: [
                  _StatTile(
                    icon: Icons.task_alt_rounded,
                    label: 'Tasks completed',
                    value: '$_completedTasks / $_totalTasks',
                    color: AppTheme.primary,
                  ),
                  _StatTile(
                    icon: Icons.access_time_rounded,
                    label: 'Hours logged',
                    value: '${_hoursLogged.toStringAsFixed(1)}h',
                    color: AppTheme.accent,
                  ),
                  _StatTile(
                    icon: Icons.menu_book_rounded,
                    label: 'Subjects',
                    value: '$_subjectCount',
                    color: AppTheme.warning,
                  ),
                  _StatTile(
                    icon: Icons.schedule_rounded,
                    label: 'Total planned',
                    value: '${_totalHours.toStringAsFixed(1)}h',
                    color: AppTheme.success,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Account section ───────────────────────────────────────────
              const Text(
                'Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),

              // Account info rows
              _InfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: _user?.email ?? 'Not logged in',
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.fingerprint_rounded,
                label: 'User ID',
                value: _user?.uid.substring(0, 12) ?? '—',
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.cloud_done_rounded,
                label: 'Storage',
                value: 'Firebase Firestore',
              ),
              const SizedBox(height: 28),

              // ── Sign out button ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(
                    Icons.logout_rounded,
                    size: 18,
                    color: AppTheme.accent,
                  ),
                  label: const Text(
                    'Sign out',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accent,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppTheme.accent, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat tile widget
// ─────────────────────────────────────────────────────────────────────────────
class _StatTile extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final Color    color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info row widget
// ─────────────────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textMuted),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textMuted,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
