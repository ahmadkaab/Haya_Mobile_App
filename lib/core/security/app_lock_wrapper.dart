import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';

class AppLockWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const AppLockWrapper({Key? key, required this.child}) : super(key: key);

  @override
  ConsumerState<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends ConsumerState<AppLockWrapper> with WidgetsBindingObserver {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isLocked = true; // Lock on first startup
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authenticate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (!_isAuthenticating) {
        setState(() => _isLocked = true);
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isLocked && !_isAuthenticating) {
        _authenticate();
      }
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    
    setState(() => _isAuthenticating = true);
    
    try {
      final bool canAuthenticate = await _auth.canCheckBiometrics || 
                                   await _auth.isDeviceSupported();
      
      if (!canAuthenticate) {
        setState(() {
          _isLocked = false;
          _isAuthenticating = false;
        });
        return;
      }

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Unlock Haya to access your sanctuary',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      setState(() {
        _isLocked = !didAuthenticate;
      });
    } catch (e) {
      // In case of error (e.g. user canceled), keep locked.
    } finally {
      setState(() => _isAuthenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLocked) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: HayaColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.lockKeyhole, color: HayaColors.accent, size: 64),
            const SizedBox(height: 24),
            Text(
              'Haya is Locked',
              style: HayaTheme.headingStyle(color: Colors.white, fontSize: 32),
            ),
            const SizedBox(height: 12),
            Text(
              'Your privacy is protected.',
              style: HayaTheme.bodyStyle(color: Colors.white70),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _authenticate,
              style: ElevatedButton.styleFrom(
                backgroundColor: HayaColors.accent,
                foregroundColor: HayaColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Tap to Unlock', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
