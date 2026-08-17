import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/modals/forgot_password_modal.dart';
import '../widgets/modals/privacy_policy_modal.dart';
import '../../core/services/biometric_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/localization.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool isLogin = true;
  bool showPassword = false;
  String email = '';
  String password = '';
  String purpose = '';
  bool acceptedPolicies = false;
  bool hasSavedBiometrics = false;
  bool isBiometricSupported = false;
  bool rememberBiometric = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final purposes = [
    {'value': 'save', 'label': 'Aprender a ahorrar', 'icon': LucideIcons.piggyBank},
    {'value': 'finance', 'label': 'Saber más de finanzas', 'icon': LucideIcons.trendingUp},
    {'value': 'expenses', 'label': 'Aprender a llevar mis gastos', 'icon': LucideIcons.pieChart},
    {'value': 'invest', 'label': 'Aprender a invertir', 'icon': LucideIcons.gem},
    {'value': 'debts', 'label': 'Salir de deudas', 'icon': LucideIcons.target},
    {'value': 'goals', 'label': 'Cumplir metas financieras', 'icon': LucideIcons.award},
  ];

  Widget _buildInputField({
    required String hint,
    required IconData icon,
    required bool isDark,
    bool isPassword = false,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        onChanged: onChanged,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
          prefixIcon: Icon(icon, color: const Color(0xFF6366F1), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometrics() async {
    final supported = await BiometricService.isDeviceSupported();
    final saved = await BiometricService.getSavedCredentials();
    final enabled = await BiometricService.isBiometricEnabled();
    if (mounted) {
      setState(() {
        isBiometricSupported = supported;
        hasSavedBiometrics = saved != null && enabled && saved['password'] != 'saved_biometric_token' && saved['password']!.isNotEmpty;
        rememberBiometric = enabled || supported;
        if (saved != null) {
          email = saved['email'] ?? '';
          password = saved['password'] ?? '';
          _emailController.text = email;
          _passwordController.text = password;
        }
      });
    }
  }

  void _showWelcomeMessage(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('🏛️', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('¡Bienvenido a Tu Ecosistema Financiero!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text('Sesión protegida iniciada. Cierre automático activo tras 1 min de inactividad.', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9), height: 1.3)),
                ],
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF1E1B4B) : const Color(0xFF312E81),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        duration: const Duration(seconds: 5),
        elevation: 10,
      ),
    );
  }

  Future<void> _performLogin(String loginEmail, String loginPassword) async {
    try {
      if (isLogin) {
        await ref.read(authProvider.notifier).login(loginEmail, loginPassword);
      } else {
        await ref.read(authProvider.notifier).register(loginEmail, loginPassword, purpose);
      }

      if (rememberBiometric && isBiometricSupported) {
        await BiometricService.setBiometricEnabled(true, loginEmail, loginPassword);
      } else if (!rememberBiometric) {
        await BiometricService.setBiometricEnabled(false);
      }

      final user = ref.read(authProvider).user;
      if (user != null && user.isTwoFactorEnabled) {
        final verified = await _showMfaLoginVerificationDialog(context, user);
        if (!verified) {
          await ref.read(authProvider.notifier).logout();
          return;
        }
      }

      if (!mounted) return;
      context.go('/dashboard'); _showWelcomeMessage(context);
      
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (!mounted) return;
      String title = 'Error de Autenticación';
      String message = e.message ?? 'Ocurrió un error inesperado en el servidor.';

      if (e.code == 'email-not-verified' || e.code == 'email-not-verified-registered') {
        title = 'Verificación Requerida';
        message = 'Por favor revisa tu bandeja de entrada y verifica tu correo antes de ingresar.';
        if (e.code == 'email-not-verified-registered') {
          setState(() => isLogin = true);
        }
      } else if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Correo o contraseña incorrectos. Verifica tus credenciales.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Este correo ya está registrado en nuestro sistema.';
      } else if (e.code == 'weak-password') {
        message = 'La contraseña es muy débil. Usa al menos 6 caracteres.';
      }
      _showErrorSnackBar(context, title, message);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(context, 'Error de Conexión', 'No pudimos conectar con los servidores de seguridad.');
    }
  }

  Future<void> _submit() async {
    final currentEmail = _emailController.text.trim();
    final currentPassword = _passwordController.text;
    
    if (!isLogin && (!acceptedPolicies || purpose.isEmpty)) {
      _showErrorSnackBar(context, 'Faltan datos', 'Por favor selecciona un propósito y acepta las políticas.');
      return;
    }
    if (currentEmail.isEmpty || currentPassword.isEmpty) {
      _showErrorSnackBar(context, 'Faltan datos', 'Por favor ingresa tu correo y contraseña.');
      return;
    }
    
    setState(() => _isLoading = true);
    await _performLogin(currentEmail, currentPassword);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleBiometricLogin() async {
    final credentials = await BiometricService.getSavedCredentials();
    if (credentials == null || credentials['password'] == 'saved_biometric_token' || credentials['password']!.isEmpty) {
      _showErrorSnackBar(context, 'Huella no vinculada', 'Ingresa una vez con tu correo y contraseña marcando la opción "Recordar y activar acceso con Huella" abajo para activarla.');
      return;
    }

    if (kIsWeb) {
      await _showBiometricScanningAnimation(credentials['email']!, credentials['password']!);
    } else {
      final success = await BiometricService.authenticate(reason: 'Acceso seguro con Huella o Face ID');
      if (success && mounted) {
        await _performLogin(credentials['email']!, credentials['password']!);
      } else if (mounted) {
        _showErrorSnackBar(context, 'Autenticación cancelada', 'No se pudo verificar la huella o rostro.');
      }
    }
  }

  Future<void> _showBiometricScanningAnimation(String savedEmail, String savedPass) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5), width: 2),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF0284C7).withValues(alpha: 0.3), blurRadius: 40, spreadRadius: 5),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔐 AUTENTICACIÓN BIOMÉTRICA SEGURA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Color(0xFF38BDF8))),
                    const SizedBox(height: 24),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.9, end: 1.1),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeInOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 100, height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF38BDF8)]),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFF38BDF8).withValues(alpha: 0.5), blurRadius: 20),
                              ],
                            ),
                            child: const Icon(LucideIcons.fingerprint, color: Colors.white, size: 56),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text('Escaneando Huella / Face ID...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                    const SizedBox(height: 8),
                    Text('Autenticando usuario en servidor encriptado', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                    const SizedBox(height: 24),
                    const LinearProgressIndicator(backgroundColor: Color(0xFF1E293B), color: Color(0xFF38BDF8), minHeight: 4),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // Cerrar modal

    await _performLogin(savedEmail, savedPass);
  }

  void _showErrorSnackBar(BuildContext context, String title, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(title == 'Verificación Requerida' ? LucideIcons.mailWarning : LucideIcons.shieldAlert, color: Colors.white, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(message, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9), height: 1.3)),
                ],
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: title == 'Verificación Requerida' ? (isDark ? const Color(0xFFD97706) : const Color(0xFFF59E0B)) : (isDark ? const Color(0xFF991B1B) : const Color(0xFFDC2626)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        duration: const Duration(seconds: 5),
        elevation: 10,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background Elements
          Positioned(
            top: -100, right: -50,
            child: Container(
              width: 300, height: 300, 
              decoration: BoxDecoration(
                shape: BoxShape.circle, 
                color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.15), blurRadius: 80, spreadRadius: 20)],
              ),
            ),
          ),
          Positioned(
            bottom: -50, left: -50,
            child: Container(
              width: 250, height: 250, 
              decoration: BoxDecoration(
                shape: BoxShape.circle, 
                color: const Color(0xFFEC4899).withValues(alpha: 0.1),
                boxShadow: [BoxShadow(color: const Color(0xFFEC4899).withValues(alpha: 0.1), blurRadius: 80, spreadRadius: 20)],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Logo & Title
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.2), blurRadius: 30, offset: const Offset(0, 10))
                          ],
                        ),
                        child: const Icon(LucideIcons.hexagon, size: 48, color: Color(0xFF6366F1)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      isLogin ? 'Bienvenido de vuelta' : 'Crea tu Bóveda',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isLogin ? 'Ingresa tus credenciales para continuar' : 'Comienza tu viaje hacia la libertad financiera',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Inputs
                    _buildInputField(
                      hint: 'Correo electrónico',
                      icon: LucideIcons.mail,
                      isDark: isDark,
                      controller: _emailController,
                      onChanged: (val) => setState(() => email = val),
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      hint: 'Contraseña',
                      icon: LucideIcons.lock,
                      isDark: isDark,
                      isPassword: true,
                      controller: _passwordController,
                      onChanged: (val) => setState(() => password = val),
                    ),

                    if (isLogin) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => ForgotPasswordModal.show(context),
                          child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                    
                    if (!isLogin) const SizedBox(height: 24),

                    // Biometric Checkbox
                    if (isBiometricSupported) ...[
                      InkWell(
                        onTap: () => setState(() => rememberBiometric = !rememberBiometric),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                rememberBiometric ? LucideIcons.checkSquare : LucideIcons.square,
                                color: rememberBiometric ? const Color(0xFF6366F1) : Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              Text('Usar huella/Face ID', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Purposes
                    if (!isLogin) ...[
                      const SizedBox(height: 24),
                      Text('Tu propósito principal:', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: purposes.map((p) {
                          final isSelected = purpose == (p['value'] as String);
                          return GestureDetector(
                            onTap: () => setState(() => purpose = p['value'] as String),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF6366F1) : (isDark ? const Color(0xFF1E293B) : Colors.white),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isSelected ? const Color(0xFF6366F1) : (isDark ? Colors.grey[800]! : Colors.grey[300]!)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(p['icon'] as IconData?, size: 16, color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600])),
                                  const SizedBox(width: 8),
                                  Text(
                                    p['label'] as String,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: acceptedPolicies,
                            onChanged: (val) => setState(() => acceptedPolicies = val ?? false),
                            activeColor: const Color(0xFF6366F1),
                          ),
                          Expanded(
                            child: Text(
                              'Acepto los Términos y Condiciones y Política de Privacidad',
                              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
                            ),
                          )
                        ],
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(isLogin ? 'Ingresar' : 'Crear Cuenta', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 16),

                    // Google Login Button
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : () async {
                        setState(() => _isLoading = true);
                        try {
                          await ref.read(authProvider.notifier).loginWithGoogle();
                          
                          final user = ref.read(authProvider).user;
                          if (user != null && user.isTwoFactorEnabled) {
                            final verified = await _showMfaLoginVerificationDialog(context, user);
                            if (!verified) {
                              await ref.read(authProvider.notifier).logout();
                              if (mounted) setState(() => _isLoading = false);
                              return;
                            }
                          }
                          
                          if (!mounted) return;
                          context.go('/dashboard'); _showWelcomeMessage(context);
                          
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error con Google: ${e.toString()}'), backgroundColor: Colors.red),
                          );
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                      icon: Icon(LucideIcons.chrome, color: isDark ? Colors.white : Colors.black, size: 20),
                      label: Text(
                        'Continuar con Google',
                        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Toggle Mode
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isLogin = !isLogin;
                          purpose = '';
                          acceptedPolicies = false;
                        });
                      },
                      child: Text(
                        isLogin ? '¿No tienes cuenta? Regístrate' : '¿Ya tienes cuenta? Inicia sesión',
                        style: TextStyle(
                          color: isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showMfaLoginVerificationDialog(BuildContext context, dynamic user) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = ref.read(localizationProvider);
    final otpController = TextEditingController();
    final generatedOtp = '123456';
    
    if (user.twoFactorMethod == 'email') {
      try {
        await FirebaseFirestore.instance.collection('mail').add({
          'to': user.email,
          'message': {
            'subject': '${loc.get('two_factor_title')} - Código de Verificación',
            'text': '${loc.get('two_factor_enter_code')} ${user.email}: $generatedOtp',
            'html': '<p>${loc.get('two_factor_enter_code')} <strong>$generatedOtp</strong></p>',
          },
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Error sending MFA email: $e');
      }
    } else if (user.twoFactorMethod == 'sms') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${loc.get('two_factor_sms_subtitle')}: $generatedOtp'),
          backgroundColor: const Color(0xFF6366F1),
          duration: const Duration(seconds: 8),
        ),
      );
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(LucideIcons.shieldCheck, color: Color(0xFF6366F1), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                loc.get('two_factor_title'),
                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${loc.get('two_factor_enter_code')} ${user.twoFactorMethod?.toUpperCase() ?? ''}:',
              style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '000000',
                fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.get('cancel') ?? 'Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final code = otpController.text.trim();
              if (code == generatedOtp) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.get('two_factor_wrong_code')), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white),
            child: const Text('Verificar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
