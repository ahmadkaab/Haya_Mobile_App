import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/data/auth_repository.dart';
import '../../core/data/journal_repository.dart';
import '../../core/theme/app_colors.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);
    
    try {
      final repo = ref.read(authRepositoryProvider);
      if (_isLogin) {
        await repo.signInWithEmail(email, password);
      } else {
        await repo.signUpWithEmail(email, password);
      }
      
      if (mounted) {
        // Auto-sync cloud journal entries into local Hive after sign-in
        await ref.read(journalRepositoryProvider.notifier).syncFromCloud();
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: HayaColors.danger));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('An unexpected error occurred'), backgroundColor: HayaColors.danger));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HayaColors.surfaceCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: HayaColors.textDark),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isLogin ? 'Welcome back.' : 'Secure your data.',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: HayaColors.textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isLogin 
                  ? 'Sign in to sync your offline metrics.' 
                  : 'Create an account to infinitely backup your Journal offline streaks to the Supabase cloud.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: HayaColors.textLight,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // Form fields
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: HayaColors.primaryTeal))
              else
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HayaColors.primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _isLogin ? 'Sign In' : 'Create Account',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                style: TextButton.styleFrom(foregroundColor: HayaColors.primaryTeal),
                child: Text(
                  _isLogin 
                    ? "Don't have an account? Sign Up" 
                    : "Already have an account? Sign In",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
