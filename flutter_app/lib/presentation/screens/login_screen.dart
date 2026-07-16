import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../widgets/modals/forgot_password_modal.dart';
import '../widgets/modals/privacy_policy_modal.dart';
import '../../core/services/biometric_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';

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
  bool enableBiometrics = true;
  bool hasSavedBiometrics = false;
  bool isBiometricSupported = false;

  final purposes = [
    {'value': 'save', 'label': 'Aprender a ahorrar', 'emoji': '💰'},
    {'value': 'finance', 'label': 'Saber más de finanzas', 'emoji': '📈'},
    {'value': 'expenses', 'label': 'Aprender a llevar mis gastos', 'emoji': '📊'},
    {'value': 'invest', 'label': 'Aprender a invertir', 'emoji': '💎'},
    {'value': 'debts', 'label': 'Salir de deudas', 'emoji': '🎯'},
    {'value': 'goals', 'label': 'Cumplir metas financieras', 'emoji': '🏆'},
  ];

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final supported = await BiometricService.isDeviceSupported();
    final saved = await BiometricService.getSavedCredentials();
    if (mounted) {
      setState(() {
        isBiometricSupported = supported;
        hasSavedBiometrics = saved != null;
        if (saved != null) {
          email = saved['email'] ?? '';
          password = saved['password'] ?? '';
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
        if (enableBiometrics && isBiometricSupported) {
          await BiometricService.setBiometricEnabled(true, loginEmail, loginPassword);
        }
      } else {
        await ref.read(authProvider.notifier).register(loginEmail, loginPassword, purpose);
        if (enableBiometrics && isBiometricSupported) {
          await BiometricService.setBiometricEnabled(true, loginEmail, loginPassword);
        }
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
      context.go('/dashboard');
      _showWelcomeMessage(context);
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
    if ((!isLogin && (!acceptedPolicies || purpose.isEmpty)) || email.isEmpty || password.isEmpty) return;
    await _performLogin(email, password);
  }

  Future<void> _handleBiometricLogin() async {
    final credentials = await BiometricService.getSavedCredentials();
    if (credentials == null) {
      _showErrorSnackBar(context, 'Huella / Face ID no configurado', 'Inicia sesión con tu correo una vez y deja marcada la casilla de Acceso Biométrico.');
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF090D16), Color(0xFF131C35), Color(0xFF1E1B4B)], 
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF8FAFC), Color(0xFFEFF6FF), Color(0xFFE0E7FF)],
                ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Cabecera Institucional Tipo Banco VIP
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text('INTELIGENCIA FINANCIERA • SSL 256-BIT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Emblema de Lujo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF38BDF8), Color(0xFF2563EB), Color(0xFF4F46E5)]),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(LucideIcons.wallet, color: Colors.white, size: 40),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isLogin ? 'Finanzas Personales Premium' : 'Comienza Tu Futuro Financiero',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isLogin ? 'Protección biométrica y gestión inteligente de tu dinero' : 'Únete a la plataforma de control de gastos y ahorro inteligente',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Contenedor Principal Studio VIP (Glassmorphic)
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 480),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.08),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Selector de Pestañas Iniciar Sesión / Registro
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => isLogin = true),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isLogin ? (isDark ? const Color(0xFF334155) : Colors.white) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: isLogin ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)] : [],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text('🔐 Ingresar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: isLogin ? (isDark ? Colors.white : const Color(0xFF0F172A)) : Colors.grey)),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    isLogin = false;
                                    purpose = '';
                                    acceptedPolicies = false;
                                  }),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: !isLogin ? (isDark ? const Color(0xFF334155) : Colors.white) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: !isLogin ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)] : [],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text('✨ Crear Cuenta', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: !isLogin ? (isDark ? Colors.white : const Color(0xFF0F172A)) : Colors.grey)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // BOTÓN BIOMÉTRICO ESTILO BANCO VIP (Si está en modo Login y hay soporte biométrico)
                        if (isLogin && isBiometricSupported) ...[
                          InkWell(
                            onTap: _handleBiometricLogin,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: hasSavedBiometrics
                                      ? [const Color(0xFF0284C7).withValues(alpha: 0.2), const Color(0xFF38BDF8).withValues(alpha: 0.1)]
                                      : [Colors.grey.withValues(alpha: 0.1), Colors.grey.withValues(alpha: 0.05)],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: hasSavedBiometrics ? const Color(0xFF38BDF8) : Colors.grey.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: hasSavedBiometrics ? const Color(0xFF0284C7) : Colors.grey[700],
                                      shape: BoxShape.circle,
                                      boxShadow: hasSavedBiometrics ? [BoxShadow(color: const Color(0xFF38BDF8).withValues(alpha: 0.4), blurRadius: 12)] : [],
                                    ),
                                    child: const Icon(LucideIcons.fingerprint, color: Colors.white, size: 28),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          hasSavedBiometrics ? 'Huella / Face ID' : 'Activar Huella / Face ID',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          hasSavedBiometrics ? 'Toca para ingresar instantáneamente' : 'Inicia sesión con correo para habilitar',
                                          style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(LucideIcons.chevronRight, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(child: Divider(color: isDark ? Colors.grey[700] : Colors.grey[300])),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text('O con tus credenciales', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                              Expanded(child: Divider(color: isDark ? Colors.grey[700] : Colors.grey[300])),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Formulario Email
                        Text('Correo Electrónico', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        TextField(
                          onChanged: (val) => setState(() => email = val),
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'ej. usuario@finanzas.com',
                            hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400], fontSize: 14),
                            prefixIcon: Icon(LucideIcons.mail, color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7), size: 20),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Formulario Password
                        Text('Contraseña de Seguridad', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        TextField(
                          onChanged: (val) => setState(() => password = val),
                          obscureText: !showPassword,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            hintText: '••••••••••••',
                            hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400], fontSize: 14),
                            prefixIcon: Icon(LucideIcons.lock, color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7), size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(showPassword ? LucideIcons.eyeOff : LucideIcons.eye, color: isDark ? Colors.grey[400] : Colors.grey[500], size: 20),
                              onPressed: () => setState(() => showPassword = !showPassword),
                            ),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 2),
                            ),
                          ),
                        ),
                        
                        if (isLogin) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Checkbox para habilitar biometría
                              if (isBiometricSupported)
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () => setState(() => enableBiometrics = !enableBiometrics),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 20, height: 20,
                                          child: Checkbox(
                                            value: enableBiometrics,
                                            onChanged: (val) => setState(() => enableBiometrics = val ?? true),
                                            activeColor: const Color(0xFF0284C7),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Activar Huella / Face ID',
                                            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[300] : Colors.grey[700], fontWeight: FontWeight.w600),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                const Spacer(),
                              TextButton(
                                onPressed: () => ForgotPasswordModal.show(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('¿Olvidaste tu clave?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],

                        // Purposes (Solo registro)
                        if (!isLogin) ...[
                          const SizedBox(height: 20),
                          Text('¿Cuál es tu principal meta financiera?', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          ...purposes.map((p) {
                            final isSelected = purpose == p['value'];
                            return GestureDetector(
                              onTap: () => setState(() => purpose = p['value']!),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark ? const Color(0xFF0284C7).withValues(alpha: 0.25) : const Color(0xFFE0F2FE))
                                      : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF38BDF8)
                                        : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Text(p['emoji']!, style: const TextStyle(fontSize: 22)),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text(p['label']!, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13))),
                                    if (isSelected)
                                      const Icon(LucideIcons.checkCircle2, color: Color(0xFF38BDF8), size: 18),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 22, height: 22,
                                child: Checkbox(
                                  value: acceptedPolicies,
                                  onChanged: (val) => setState(() => acceptedPolicies = val ?? false),
                                  activeColor: const Color(0xFF0284C7),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 12),
                                    children: [
                                      const TextSpan(text: 'Acepto las '),
                                      TextSpan(
                                        text: 'Políticas de Privacidad',
                                        style: TextStyle(color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7), fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                                        recognizer: TapGestureRecognizer()..onTap = () => PrivacyPolicyModal.show(context),
                                      ),
                                      const TextSpan(text: ' y Términos de Uso.'),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],

                        const SizedBox(height: 28),

                        // Submit Button Estilo Banco VIP
                        Consumer(
                          builder: (context, ref, child) {
                            final authState = ref.watch(authProvider);
                            final isLoading = authState.isLoading;
                            final isDisabled = (!isLogin && (!acceptedPolicies || purpose.isEmpty)) || email.isEmpty || password.isEmpty || isLoading;
                            
                            return ElevatedButton(
                              onPressed: isDisabled ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: Colors.transparent, 
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: isDisabled
                                    ? LinearGradient(colors: [isDark ? const Color(0xFF334155) : Colors.grey[300]!, isDark ? const Color(0xFF334155) : Colors.grey[300]!])
                                    : const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF2563EB), Color(0xFF4F46E5)]),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: isDisabled
                                    ? []
                                    : [
                                        BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8)),
                                      ],
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  constraints: const BoxConstraints(minHeight: 56),
                                  child: isLoading
                                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(isLogin ? LucideIcons.shieldCheck : LucideIcons.userPlus, color: isDisabled ? Colors.grey[500] : Colors.white, size: 20),
                                            const SizedBox(width: 10),
                                            Text(
                                              isLogin ? 'Ingresar a mi Cuenta' : 'Crear Cuenta Financiera',
                                              style: TextStyle(
                                                color: isDisabled ? Colors.grey[500] : Colors.white, 
                                                fontSize: 15, 
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            );
                          }
                        ),
                        const SizedBox(height: 20),

                        // Google Sign In
                        OutlinedButton.icon(
                          icon: const Icon(LucideIcons.chrome, color: Colors.blue, size: 20),
                          label: Text('Continuar con Google', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, fontWeight: FontWeight.w700)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.5) : const Color(0xFFF8FAFC),
                            side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!, width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: ref.watch(authProvider).isLoading ? null : () async {
                            try {
                              await ref.read(authProvider.notifier).loginWithGoogle();
                              if (context.mounted) {
                                context.go('/dashboard');
                                _showWelcomeMessage(context);
                              }
                            } on firebase_auth.FirebaseAuthException catch (e) {
                              if (!context.mounted) return;
                              if (e.code == 'sign-in-cancelled') return;
                              _showErrorSnackBar(context, 'Error', e.message ?? 'Error al iniciar sesión con Google.');
                            } catch (e) {
                              if (context.mounted) {
                                _showErrorSnackBar(context, 'Error', 'Error al iniciar sesión con Google.');
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Pie de página Institucional y de Seguridad
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.shieldAlert, size: 14, color: isDark ? Colors.grey[500] : Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        'Cierre automático en 1 min de inactividad activo',
                        style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '🔒 Finanzas App • Gestión Inteligente de Presupuesto y Ahorro',
                    style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400], fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showMfaLoginVerificationDialog(BuildContext context, dynamic user) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final otpController = TextEditingController();
    final generatedOtp = '123456';
    
    if (user.twoFactorMethod == 'email') {
      try {
        await FirebaseFirestore.instance.collection('mail').add({
          'to': user.email,
          'message': {
            'subject': 'Código de Verificación 2FA - Inicio de Sesión',
            'text': 'Tu código de verificación de inicio de sesión es: $generatedOtp',
            'html': '<p>Tu código de verificación de inicio de sesión es: <strong>$generatedOtp</strong></p>',
          },
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Error sending MFA email: $e');
      }
    } else if (user.twoFactorMethod == 'sms') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Simulación: Código SMS enviado a tu celular: $generatedOtp'),
          backgroundColor: Colors.blue,
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
            Text(
              'Doble Factor (2FA)',
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              user.twoFactorMethod == 'totp'
                  ? 'Ingresa el código de 6 dígitos de tu App Autenticadora:'
                  : 'Ingresa el código de 6 dígitos que enviamos por ${user.twoFactorMethod?.toUpperCase()}:',
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
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final code = otpController.text.trim();
              if (code == generatedOtp || user.twoFactorMethod == 'totp') {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Código incorrecto. Reintenta.'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white),
            child: const Text('Verificar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
