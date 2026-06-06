import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/theme_service.dart';
import '../../utils/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String _passwordStrength = '';

  // Focus and hover states
  bool _isNameFocused = false;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  bool _isConfirmPasswordFocused = false;
  bool _isNameHovered = false;
  bool _isEmailHovered = false;
  bool _isPasswordHovered = false;
  bool _isConfirmPasswordHovered = false;
  bool _isCreateAccountHovered = false;

  // Animation controllers
  late AnimationController _nameAnimationController;
  late AnimationController _emailAnimationController;
  late AnimationController _passwordAnimationController;
  late AnimationController _confirmPasswordAnimationController;
  late AnimationController _createAccountAnimationController;
  late Animation<double> _nameBorderAnimation;
  late Animation<double> _emailBorderAnimation;
  late Animation<double> _passwordBorderAnimation;
  late Animation<double> _confirmPasswordBorderAnimation;
  late Animation<double> _nameShadowAnimation;
  late Animation<double> _emailShadowAnimation;
  late Animation<double> _passwordShadowAnimation;
  late Animation<double> _confirmPasswordShadowAnimation;
  late Animation<double> _createAccountColorAnimation;

  @override
  void initState() {
    super.initState();
    
    // Name animations
    _nameAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _nameBorderAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _nameAnimationController,
      curve: Curves.easeInOut,
    ));
    _nameShadowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _nameAnimationController,
      curve: Curves.easeInOut,
    ));

    // Email animations
    _emailAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _emailBorderAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _emailAnimationController,
      curve: Curves.easeInOut,
    ));
    _emailShadowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _emailAnimationController,
      curve: Curves.easeInOut,
    ));

    // Password animations
    _passwordAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _passwordBorderAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _passwordAnimationController,
      curve: Curves.easeInOut,
    ));
    _passwordShadowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _passwordAnimationController,
      curve: Curves.easeInOut,
    ));

    // Confirm Password animations
    _confirmPasswordAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _confirmPasswordBorderAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confirmPasswordAnimationController,
      curve: Curves.easeInOut,
    ));
    _confirmPasswordShadowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confirmPasswordAnimationController,
      curve: Curves.easeInOut,
    ));

    // Create Account button animations
    _createAccountAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _createAccountColorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _createAccountAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameAnimationController.dispose();
    _emailAnimationController.dispose();
    _passwordAnimationController.dispose();
    _confirmPasswordAnimationController.dispose();
    _createAccountAnimationController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    setState(() {
      switch (score) {
        case 0:
        case 1:
          _passwordStrength = 'Very Weak';
          break;
        case 2:
          _passwordStrength = 'Weak';
          break;
        case 3:
          _passwordStrength = 'Medium';
          break;
        case 4:
          _passwordStrength = 'Strong';
          break;
        case 5:
          _passwordStrength = 'Very Strong';
          break;
      }
    });
  }

  Color _getPasswordStrengthColor() {
    switch (_passwordStrength) {
      case 'Very Weak':
        return AppTheme.dangerColor;
      case 'Weak':
        return AppTheme.warningColor;
      case 'Medium':
        return AppTheme.infoColor;
      case 'Strong':
      case 'Very Strong':
        return AppTheme.successColor;
      default:
        return AppTheme.textLight;
    }
  }

  double _getPasswordStrengthWidth() {
    switch (_passwordStrength) {
      case 'Very Weak':
        return 0.25;
      case 'Weak':
        return 0.5;
      case 'Medium':
        return 0.75;
      case 'Strong':
      case 'Very Strong':
        return 1.0;
      default:
        return 0.0;
    }
  }

  Color _getBorderColor(bool isFocused, bool isHovered) {
    if (isFocused) {
      return const Color(0xFF00FF00); // Green on focus
    } else if (isHovered) {
      return const Color(0xFF00FF00); // Green on hover
    }
    return AppTheme.borderColor; // Default border color
  }

  Color _getCreateAccountButtonColor() {
    if (_isCreateAccountHovered) {
      return Color.lerp(AppTheme.primaryColor, AppTheme.primaryLight, _createAccountColorAnimation.value)!;
    }
    return AppTheme.primaryColor; // Default green color
  }

  void _handleNameHover(bool isHovered) {
    setState(() => _isNameHovered = isHovered);
    if (isHovered) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_isNameHovered) {
          _nameAnimationController.forward();
        }
      });
    } else {
      _nameAnimationController.reverse();
    }
  }

  void _handleEmailHover(bool isHovered) {
    setState(() => _isEmailHovered = isHovered);
    if (isHovered) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_isEmailHovered) {
          _emailAnimationController.forward();
        }
      });
    } else {
      _emailAnimationController.reverse();
    }
  }

  void _handlePasswordHover(bool isHovered) {
    setState(() => _isPasswordHovered = isHovered);
    if (isHovered) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_isPasswordHovered) {
          _passwordAnimationController.forward();
        }
      });
    } else {
      _passwordAnimationController.reverse();
    }
  }

  void _handleConfirmPasswordHover(bool isHovered) {
    setState(() => _isConfirmPasswordHovered = isHovered);
    if (isHovered) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_isConfirmPasswordHovered) {
          _confirmPasswordAnimationController.forward();
        }
      });
    } else {
      _confirmPasswordAnimationController.reverse();
    }
  }

  void _handleNameFocus(bool hasFocus) {
    setState(() => _isNameFocused = hasFocus);
    if (hasFocus) {
      _nameAnimationController.forward();
    } else if (!_isNameHovered) {
      _nameAnimationController.reverse();
    }
  }

  void _handleEmailFocus(bool hasFocus) {
    setState(() => _isEmailFocused = hasFocus);
    if (hasFocus) {
      _emailAnimationController.forward();
    } else if (!_isEmailHovered) {
      _emailAnimationController.reverse();
    }
  }

  void _handlePasswordFocus(bool hasFocus) {
    setState(() => _isPasswordFocused = hasFocus);
    if (hasFocus) {
      _passwordAnimationController.forward();
    } else if (!_isPasswordHovered) {
      _passwordAnimationController.reverse();
    }
  }

  void _handleConfirmPasswordFocus(bool hasFocus) {
    setState(() => _isConfirmPasswordFocused = hasFocus);
    if (hasFocus) {
      _confirmPasswordAnimationController.forward();
    } else if (!_isConfirmPasswordHovered) {
      _confirmPasswordAnimationController.reverse();
    }
  }

  void _handleCreateAccountHover(bool isHovered) {
    setState(() => _isCreateAccountHovered = isHovered);
    if (isHovered) {
      _createAccountAnimationController.forward();
    } else {
      _createAccountAnimationController.reverse();
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = context.read<AuthService>();
      await authService.createUserWithEmailAndPassword(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up failed: ${e.toString()}'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
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
    final themeService = context.watch<ThemeService>();
    final isDarkMode = themeService.isDarkMode;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;
    
    // Responsive button height
    final buttonHeight = isMobile ? 48.0 : 36.0;
    final buttonFontSize = isMobile ? 14.0 : 16.0;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryColor, AppTheme.primaryLight],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Card(
                  elevation: 20,
                  shadowColor: Colors.black.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusLg),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.bgPrimary, AppTheme.bgSecondary],
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusLg),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Auth Header
                          Column(
                            children: [
                              // Brand
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.drag_indicator,
                                    size: 44,
                                    color: AppTheme.primaryColor,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'ScaleSyncPro',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              
                              // Title
                              Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Join ScaleSyncPro to manage your reptiles and cohabitat',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),

                          // Name Field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Full Name',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              MouseRegion(
                                onEnter: (_) => _handleNameHover(true),
                                onExit: (_) => _handleNameHover(false),
                                child: Focus(
                                  onFocusChange: _handleNameFocus,
                                  child: AnimatedBuilder(
                                    animation: _nameAnimationController,
                                    builder: (context, child) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: _getBorderColor(_isNameFocused, _isNameHovered),
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                                          color: AppTheme.bgPrimary,
                                        ),
                                        child: TextFormField(
                                          controller: _nameController,
                                          style: TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontSize: 16,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Enter your full name',
                                            hintStyle: TextStyle(
                                              color: AppTheme.textLight,
                                              fontSize: 16,
                                            ),
                                            prefixIcon: Icon(
                                              Icons.person_outlined,
                                              color: AppTheme.textLight,
                                              size: 18,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 10,
                                            ),
                                            filled: true,
                                            fillColor: Colors.transparent,
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter your name';
                                            }
                                            return null;
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Email Field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              MouseRegion(
                                onEnter: (_) => _handleEmailHover(true),
                                onExit: (_) => _handleEmailHover(false),
                                child: Focus(
                                  onFocusChange: _handleEmailFocus,
                                  child: AnimatedBuilder(
                                    animation: _emailAnimationController,
                                    builder: (context, child) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: _getBorderColor(_isEmailFocused, _isEmailHovered),
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                                          color: AppTheme.bgPrimary,
                                        ),
                                        child: TextFormField(
                                          controller: _emailController,
                                          keyboardType: TextInputType.emailAddress,
                                          style: TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontSize: 16,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Enter your email',
                                            hintStyle: TextStyle(
                                              color: AppTheme.textLight,
                                              fontSize: 16,
                                            ),
                                            prefixIcon: Icon(
                                              Icons.email_outlined,
                                              color: AppTheme.textLight,
                                              size: 18,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 10,
                                            ),
                                            filled: true,
                                            fillColor: Colors.transparent,
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter your email';
                                            }
                                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                              return 'Please enter a valid email';
                                            }
                                            return null;
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Password',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              MouseRegion(
                                onEnter: (_) => _handlePasswordHover(true),
                                onExit: (_) => _handlePasswordHover(false),
                                child: Focus(
                                  onFocusChange: _handlePasswordFocus,
                                  child: AnimatedBuilder(
                                    animation: _passwordAnimationController,
                                    builder: (context, child) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: _getBorderColor(_isPasswordFocused, _isPasswordHovered),
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                                          color: AppTheme.bgPrimary,
                                        ),
                                        child: TextFormField(
                                          controller: _passwordController,
                                          obscureText: !_isPasswordVisible,
                                          onChanged: _checkPasswordStrength,
                                          style: TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontSize: 16,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Enter your password',
                                            hintStyle: TextStyle(
                                              color: AppTheme.textLight,
                                              fontSize: 16,
                                            ),
                                            prefixIcon: Icon(
                                              Icons.lock_outlined,
                                              color: AppTheme.textLight,
                                              size: 18,
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _isPasswordVisible 
                                                  ? Icons.visibility_off 
                                                  : Icons.visibility,
                                                color: AppTheme.textLight,
                                                size: 18,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _isPasswordVisible = !_isPasswordVisible;
                                                });
                                              },
                                              style: IconButton.styleFrom(
                                                padding: const EdgeInsets.all(8),
                                                minimumSize: const Size(32, 32),
                                              ),
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 10,
                                            ),
                                            filled: true,
                                            fillColor: Colors.transparent,
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter a password';
                                            }
                                            if (value.length < 6) {
                                              return 'Password must be at least 6 characters';
                                            }
                                            return null;
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              if (_passwordStrength.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: AppTheme.bgTertiary,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: _getPasswordStrengthWidth(),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: _getPasswordStrengthColor(),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Strength: $_passwordStrength',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Confirm Password Field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Confirm Password',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              MouseRegion(
                                onEnter: (_) => _handleConfirmPasswordHover(true),
                                onExit: (_) => _handleConfirmPasswordHover(false),
                                child: Focus(
                                  onFocusChange: _handleConfirmPasswordFocus,
                                  child: AnimatedBuilder(
                                    animation: _confirmPasswordAnimationController,
                                    builder: (context, child) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: _getBorderColor(_isConfirmPasswordFocused, _isConfirmPasswordHovered),
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                                          color: AppTheme.bgPrimary,
                                        ),
                                        child: TextFormField(
                                          controller: _confirmPasswordController,
                                          obscureText: !_isConfirmPasswordVisible,
                                          style: TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontSize: 16,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Confirm your password',
                                            hintStyle: TextStyle(
                                              color: AppTheme.textLight,
                                              fontSize: 16,
                                            ),
                                            prefixIcon: Icon(
                                              Icons.lock_outlined,
                                              color: AppTheme.textLight,
                                              size: 18,
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _isConfirmPasswordVisible 
                                                  ? Icons.visibility_off 
                                                  : Icons.visibility,
                                                color: AppTheme.textLight,
                                                size: 18,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                                });
                                              },
                                              style: IconButton.styleFrom(
                                                padding: const EdgeInsets.all(8),
                                                minimumSize: const Size(32, 32),
                                              ),
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 10,
                                            ),
                                            filled: true,
                                            fillColor: Colors.transparent,
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please confirm your password';
                                            }
                                            if (value != _passwordController.text) {
                                              return 'Passwords do not match';
                                            }
                                            return null;
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),

                          // Sign Up Button
                          MouseRegion(
                            onEnter: (_) => _handleCreateAccountHover(true),
                            onExit: (_) => _handleCreateAccountHover(false),
                            child: AnimatedBuilder(
                              animation: _createAccountAnimationController,
                              builder: (context, child) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: buttonHeight,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _signUp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _getCreateAccountButtonColor(),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.person_add, size: 18, color: Colors.white),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Create Account',
                                                style: TextStyle(
                                                  fontSize: buttonFontSize,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Sign In Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 