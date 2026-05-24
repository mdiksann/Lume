import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lume/core/constants/app_colors.dart';
import 'package:lume/domain/repositories/book_repository.dart';
import 'package:lume/services/supabase_service.dart';

/// A beautifully crafted, premium Authentication Screen.
///
/// Evokes the Lume brand design language of warm ivory tones,
/// deep navy ink text, amber accents, and micro-interactions.
class AuthScreen extends StatefulWidget {
  final BookRepository bookRepository;

  const AuthScreen({
    super.key,
    required this.bookRepository,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _success = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = SupabaseService();
      if (_isSignUp) {
        await supabase.signUp(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await supabase.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }

      // Sync local Hive library to Supabase Cloud on successful authentication
      await widget.bookRepository.syncWithCloud();

      setState(() {
        _isLoading = false;
        _success = true;
      });

      // Show beautiful success visual, then close
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final textCol = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: textCol, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Branding / Candlelight Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: accentColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),

                // Dynamic Header
                Text(
                  _isSignUp ? 'Create Lume Account' : 'Welcome to Lume',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isSignUp
                      ? 'Secure your reading list in the cloud today.'
                      : 'Sign in to synchronize your books across devices.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                // Success or Form Block
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _success
                      ? _buildSuccessWidget(theme, textCol, accentColor)
                      : _buildFormWidget(theme, cardColor, textCol, accentColor, isDark),
                ),
                const SizedBox(height: 24),

                // Switch Sign In / Sign Up Mode
                if (!_success)
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                              _errorMessage = null;
                              _formKey.currentState?.reset();
                            });
                          },
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: _isSignUp
                                ? 'Already have an account? '
                                : "Don't have an account? ",
                          ),
                          TextSpan(
                            text: _isSignUp ? 'Sign In' : 'Sign Up',
                            style: GoogleFonts.inter(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormWidget(
    ThemeData theme,
    Color cardColor,
    Color textColor,
    Color accentColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x144A5260), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Error Message Banner
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.lightError.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightError.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.lightError, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.lightError,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],

            // Email Address Input
            Text(
              'Email Address',
              style: theme.textTheme.titleSmall?.copyWith(fontSize: 13, color: textColor.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
              style: theme.textTheme.bodyMedium?.copyWith(color: textColor, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'name@example.com',
                prefixIcon: Icon(Icons.email_outlined, color: textColor.withValues(alpha: 0.4), size: 20),
              ).applyDefaults(theme.inputDecorationTheme),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Please enter your email';
                final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                if (!regex.hasMatch(val.trim())) return 'Please enter a valid email address';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Password Input
            Text(
              'Password',
              style: theme.textTheme.titleSmall?.copyWith(fontSize: 13, color: textColor.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              enabled: !_isLoading,
              style: theme.textTheme.bodyMedium?.copyWith(color: textColor, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Enter your password',
                prefixIcon: Icon(Icons.lock_outlined, color: textColor.withValues(alpha: 0.4), size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: textColor.withValues(alpha: 0.4),
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ).applyDefaults(theme.inputDecorationTheme),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Please enter your password';
                if (val.length < 6) return 'Password must be at least 6 characters long';
                return null;
              },
            ),

            // Confirm Password Input (Only for Sign Up)
            if (_isSignUp) ...[
              const SizedBox(height: 20),
              Text(
                'Confirm Password',
                style: theme.textTheme.titleSmall?.copyWith(fontSize: 13, color: textColor.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscurePassword,
                enabled: !_isLoading,
                style: theme.textTheme.bodyMedium?.copyWith(color: textColor, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Repeat your password',
                  prefixIcon: Icon(Icons.lock_outline, color: textColor.withValues(alpha: 0.4), size: 20),
                ).applyDefaults(theme.inputDecorationTheme),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please confirm your password';
                  if (val != _passwordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
            ],

            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: theme.elevatedButtonTheme.style?.copyWith(
                backgroundColor: WidgetStateProperty.all(accentColor),
                foregroundColor: WidgetStateProperty.all(Colors.white),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _isSignUp ? 'Create Account' : 'Sign In',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessWidget(ThemeData theme, Color textColor, Color accentColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x144A5260), width: 0.8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Authentication Successful',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFamily: GoogleFonts.playfairDisplay().fontFamily,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your library is now syncing with the cloud.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
