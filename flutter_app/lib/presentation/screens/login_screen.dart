import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../widgets/modals/forgot_password_modal.dart';
import '../widgets/modals/privacy_policy_modal.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
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

  void _showWelcomeMessage(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('💡', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('¡Bienvenido a Finanzas App!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text('Aquí podrás visualizar tu resumen mensual. Usa el menú inferior para agregar Gastos o Ahorros y gamificar tus logros.', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9), height: 1.3)),
                ],
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF4C1D95) : const Color(0xFF7E22CE),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        duration: const Duration(seconds: 5),
        elevation: 10,
      ),
    );
  }

  final purposes = [
    {'value': 'save', 'label': 'Aprender a ahorrar', 'emoji': '💰'},
    {'value': 'finance', 'label': 'Saber más de finanzas', 'emoji': '📈'},
    {'value': 'expenses', 'label': 'Aprender a llevar mis gastos', 'emoji': '📊'},
    {'value': 'invest', 'label': 'Aprender a invertir', 'emoji': '💎'},
    {'value': 'debts', 'label': 'Salir de deudas', 'emoji': '🎯'},
    {'value': 'goals', 'label': 'Cumplir metas financieras', 'emoji': '🏆'},
  ];

  Future<void> _submit() async {
    if ((!isLogin && (!acceptedPolicies || purpose.isEmpty)) || email.isEmpty || password.isEmpty) return;
    
    try {
      if (isLogin) {
        await ref.read(authProvider.notifier).login(email, password);
      } else {
        await ref.read(authProvider.notifier).register(email, password, purpose);
      }
      
      if (!context.mounted) return;
      context.go('/dashboard');
      _showWelcomeMessage(context);
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      
      String title = 'Error';
      String message = e.message ?? 'Ocurrió un error inesperado.';
      
      if (e.code == 'email-not-verified' || e.code == 'email-not-verified-registered') {
         title = 'Verificación Requerida';
         if (e.code == 'email-not-verified-registered') {
           setState(() {
             isLogin = true;
           });
         }
      } else if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
         message = 'Correo o contraseña incorrectos.';
      } else if (e.code == 'email-already-in-use') {
         message = 'Este correo ya está registrado.';
      } else if (e.code == 'weak-password') {
         message = 'La contraseña es muy débil. Usa al menos 6 caracteres.';
      }
      
      _showErrorSnackBar(context, title, message);
    } catch (e) {
      if (!context.mounted) return;
      _showErrorSnackBar(context, 'Error', 'No pudimos conectar con el servidor.');
    }
  }

  void _showErrorSnackBar(BuildContext context, String title, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(title == 'Verificación Requerida' ? LucideIcons.mailWarning : LucideIcons.alertCircle, color: Colors.white, size: 28),
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
          // Fondo base más atractivo
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)], 
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFAF5FF), Color(0xFFDBEAFE)], // purple-50 to blue-100
                ),
        ),
        child: SafeArea(
          child: Center( // Center everything
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo & Header
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? const LinearGradient(colors: [Color(0xFF7E22CE), Color(0xFF1D4ED8)])
                          : const LinearGradient(colors: [Color(0xFF9333EA), Color(0xFF2563EB)]),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? const Color(0xFF7E22CE) : const Color(0xFF9333EA)).withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('💸', style: TextStyle(fontSize: 44)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    isLogin ? '¡Hola de nuevo!' : 'Únete a Finanzas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isLogin ? 'Inicia sesión para continuar ahorrando' : 'Empieza tu camino hacia la libertad financiera',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Contenedor Estilo Tarjeta Cristalina (Glassmorphism / Elevated Card)
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 480),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F2937).withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Google Sign In
                        OutlinedButton.icon(
                          icon: const Icon(LucideIcons.chrome, color: Colors.blue), // Simulation for google
                          label: Text('Continuar con Google', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: isDark ? const Color(0xFF374151).withValues(alpha: 0.5) : const Color(0xFFF9FAFB),
                            side: BorderSide(color: isDark ? const Color(0xFF4B5563) : Colors.grey[300]!, width: 1.5),
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
                              // Don't show error if user cancelled
                              if (e.code == 'sign-in-cancelled') return;
                              _showErrorSnackBar(context, 'Error', e.message ?? 'Error al iniciar sesión con Google.');
                            } catch (e) {
                              if (context.mounted) {
                                _showErrorSnackBar(context, 'Error', 'Error al iniciar sesión con Google.');
                              }
                            }
                          },
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Row(
                            children: [
                              Expanded(child: Divider(color: isDark ? Colors.grey[700] : Colors.grey[300])),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text('O con tu correo', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)),
                              ),
                              Expanded(child: Divider(color: isDark ? Colors.grey[700] : Colors.grey[300])),
                            ],
                          ),
                        ),

                        // Formulario Email
                        Text('Correo Electrónico', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          onChanged: (val) => setState(() => email = val),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'tu@email.com',
                            hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
                            prefixIcon: Icon(LucideIcons.mail, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFF9333EA), width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Formulario Password
                        Text('Contraseña', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          onChanged: (val) => setState(() => password = val),
                          obscureText: !showPassword,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
                            prefixIcon: Icon(LucideIcons.lock, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                            suffixIcon: IconButton(
                              icon: Icon(showPassword ? LucideIcons.eyeOff : LucideIcons.eye, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                              onPressed: () => setState(() => showPassword = !showPassword),
                            ),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFF9333EA), width: 2),
                            ),
                          ),
                        ),
                        
                        if (isLogin) ...[
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => ForgotPasswordModal.show(context),
                              style: TextButton.styleFrom(
                                foregroundColor: isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],

                        // Purposes (Only when registering)
                        if (!isLogin) ...[
                          const SizedBox(height: 24),
                          Text('¿Cuál es tu propósito para usar esta app?', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ...purposes.map((p) {
                            final isSelected = purpose == p['value'];
                            return GestureDetector(
                              onTap: () => setState(() => purpose = p['value']!),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark ? const Color(0xFF581C87).withValues(alpha: 0.5) : const Color(0xFFF3E8FF))
                                      : (isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB)),
                                  border: Border.all(
                                    color: isSelected
                                        ? (isDark ? const Color(0xFFA855F7) : const Color(0xFF9333EA))
                                        : (isDark ? const Color(0xFF4B5563) : Colors.grey[200]!),
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Text(p['emoji']!, style: const TextStyle(fontSize: 24)),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text(p['label']!, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
                                    if (isSelected)
                                      const Icon(LucideIcons.checkCircle2, color: Color(0xFF9333EA)),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24, height: 24,
                                child: Checkbox(
                                  value: acceptedPolicies,
                                  onChanged: (val) => setState(() => acceptedPolicies = val ?? false),
                                  activeColor: const Color(0xFF9333EA),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 13),
                                    children: [
                                      const TextSpan(text: 'He leído y acepto las '),
                                      TextSpan(
                                        text: 'Políticas de Privacidad',
                                        style: TextStyle(
                                          color: isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA), 
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()..onTap = () {
                                          PrivacyPolicyModal.show(context);
                                        },
                                      ),
                                      const TextSpan(text: ' y Términos de Servicio.'),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],

                        const SizedBox(height: 32),

                        // Submit Button
                        // Submit Button
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
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: isDisabled
                                    ? LinearGradient(colors: [isDark ? const Color(0xFF374151) : Colors.grey[300]!, isDark ? const Color(0xFF374151) : Colors.grey[300]!])
                                    : const LinearGradient(colors: [Color(0xFF9333EA), Color(0xFF2563EB)]),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: isDisabled
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: const Color(0xFF9333EA).withValues(alpha: 0.3),
                                          blurRadius: 16,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  constraints: const BoxConstraints(minHeight: 56),
                                  child: isLoading
                                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : Text(
                                          isLogin ? 'Ingresar a mi cuenta' : 'Crear Cuenta',
                                          style: TextStyle(
                                            color: isDisabled ? Colors.grey[500] : Colors.white, 
                                            fontSize: 16, 
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                ),
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Toggle Login / Register
                  TextButton(
                    onPressed: () => setState(() {
                      isLogin = !isLogin;
                      purpose = '';
                      acceptedPolicies = false;
                    }),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 15),
                        children: [
                          TextSpan(text: isLogin ? '¿No tienes cuenta? ' : '¿Ya tienes cuenta? '),
                          TextSpan(
                            text: isLogin ? 'Regístrate' : 'Inicia Sesión',
                            style: TextStyle(
                              color: isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA),
                              fontWeight: FontWeight.bold,
                            )
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
      ),
    );
  }
}
