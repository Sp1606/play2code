import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/game_card.dart';
import '../../../../core/widgets/game_button.dart';
import '../../../../core/services/firebase_service.dart';
import '../providers/profile_providers.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isSignUp = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_isSignUp) {
        // Sign Up: Seed mock data in database first
        debugPrint('Sign Up: Seeding user data for $email');
        final cleanEmail = email.toLowerCase();
        final uid = 'user_${cleanEmail.hashCode}';
        final username = cleanEmail.split('@').first;
        
        await FirebaseService.instance.updateDocument('users', uid, {
          'uid': uid,
          'username': username,
          'email': email,
          'level': 1,
          'xp': 0,
          'rank': 'Novice Coder',
          'completedWorldsCount': 0,
          'achievements': <String>[],
        });
      }

      await FirebaseService.instance.signIn(email, password);
      // Riverpod profile provider needs to reload profile for the new UID
      ref.invalidate(userProfileProvider);
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Authentication failed. Please verify credentials.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E1B4B),
              Color(0xFF311042),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- GAME TITLE BRAND ---
                  const Icon(Icons.videogame_asset, size: 64, color: GamingColors.primary),
                  const SizedBox(height: 12),
                  const Text(
                    'PLAY 2 CODE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const Text(
                    'ALGORITHMIC RPG ADVENTURE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: GamingColors.secondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- AUTH CONTAINER ---
                  GameCard(
                    borderColor: _isSignUp ? GamingColors.accent : GamingColors.primary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isSignUp ? 'REGISTER WARRIOR' : 'WARRIOR SIGN IN',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: _isSignUp ? GamingColors.accent : GamingColors.primary,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'EMAIL ADDRESS',
                            labelStyle: const TextStyle(color: GamingColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                            prefixIcon: const Icon(Icons.email_outlined, color: GamingColors.textMuted, size: 18),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: GamingColors.primary)),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty || !val.contains('@')) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'ACCESS KEY (PASSWORD)',
                            labelStyle: const TextStyle(color: GamingColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                            prefixIcon: const Icon(Icons.lock_outline, color: GamingColors.textMuted, size: 18),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: GamingColors.primary)),
                          ),
                          validator: (val) {
                            if (val == null || val.length < 6) {
                              return 'Key must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: GamingColors.error, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),

                        const SizedBox(height: 8),

                        // Submit Button
                        _isLoading
                            ? const Center(child: CircularProgressIndicator(color: GamingColors.primary))
                            : GameButton(
                                width: double.infinity,
                                label: _isSignUp ? 'CREATE WARRIOR' : 'ENTER THE ARENA',
                                onPressed: _submit,
                                color: _isSignUp ? GamingColors.accent : GamingColors.primary,
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mode Toggle Button
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isSignUp = !_isSignUp;
                        _errorMessage = null;
                      });
                    },
                    child: Text(
                      _isSignUp ? 'Already registered? Sign In here' : 'New Warrior? Create an Account',
                      style: const TextStyle(color: GamingColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
