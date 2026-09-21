import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../widgets/modals/forgot_password_modal.dart';
import '../widgets/modals/privacy_policy_modal.dart';
import '../widgets/modals/terms_conditions_modal.dart';
import '../widgets/modals/language_modal.dart';
import '../../core/services/biometric_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../providers/auth_provider.dart';
import '../../core/utils/localization.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool isLogin = true;
  String email = '';
  String password = '';
  String purpose = '';
  bool acceptedPolicies = false;
  bool isBiometricSupported = false;
  bool rememberBiometric = true;
  bool _isLoading = false;
  bool obscurePassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final purposes = [
    {'value': 'save', 'icon': LucideIcons.piggyBank, 'key': 'purpose_save'},
    {'value': 'finance', 'icon': LucideIcons.trendingUp, 'key': 'purpose_finance'},
    {'value': 'expenses', 'icon': LucideIcons.pieChart, 'key': 'purpose_expenses'},
    {'value': 'invest', 'icon': LucideIcons.gem, 'key': 'purpose_invest'},
    {'value': 'debts', 'icon': LucideIcons.target, 'key': 'purpose_debts'},
    {'value': 'goals', 'icon': LucideIcons.award, 'key': 'purpose_goals'},
  ];

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

  String _t(String key) {
    final code = ref.watch(localizationProvider).intlLocale;
    const translations = {
      'es': {
        'tab_login': 'Iniciar Sesión',
        'tab_register': 'Registro',
        'welcome': '¡Hola! Qué gusto verte',
        'welcome_sub': 'Tu bienestar financiero empieza aquí',
        'start_journey': 'Comienza tu viaje',
        'start_journey_sub': 'Crea tu cuenta y toma el control',
        'email': 'Correo electrónico',
        'password': 'Contraseña',
        'forgot_pass': '¿Olvidaste tu contraseña?',
        'purpose_title': '¿Qué quieres lograr?',
        'purpose_save': 'Aprender a ahorrar',
        'purpose_finance': 'Saber más de finanzas',
        'purpose_expenses': 'Aprender a llevar gastos',
        'purpose_invest': 'Aprender a invertir',
        'purpose_debts': 'Salir de deudas',
        'purpose_goals': 'Cumplir metas',
        'read_accept': 'He leído y acepto los ',
        'terms': 'Términos y Condiciones',
        'and': ' y la ',
        'privacy': 'Política de Privacidad',
        'biometric_login': 'Ingresar con Huella/Face ID',
        'biometric_enable': 'Activar Huella/Face ID para la próxima vez',
        'btn_login': 'Ingresar a mi cuenta',
        'btn_register': 'Crear mi cuenta',
        'err_missing': 'Faltan datos',
        'err_missing_desc': 'Por favor completa todos los campos',
        'err_policies': 'Términos y Condiciones',
        'err_policies_desc': 'Debes aceptar los términos y políticas para continuar',
        'err_purpose': 'Propósito de uso',
        'err_purpose_desc': 'Selecciona qué quieres lograr con la app',
        'err_cred': 'Credenciales no encontradas',
        'err_cred_desc': 'No se encontraron credenciales guardadas',
        'succ_login': '¡Bienvenido de vuelta!',
        'succ_login_desc': 'Nos alegra verte por aquí',
        'succ_reg': '¡Cuenta creada con éxito!',
                'succ_reg_desc': 'Tu bienestar financiero empieza ahora',
        'new_to_quivo': '¿Nuevo en QUIVO?',
        'already_have_account': '¿Ya tienes una cuenta?',
      },
      'en': {
        'tab_login': 'Log In',
        'tab_register': 'Sign Up',
        'welcome': 'Hello! Good to see you',
        'welcome_sub': 'Your financial wellbeing starts here',
        'start_journey': 'Start your journey',
        'start_journey_sub': 'Create your account and take control',
        'email': 'Email address',
        'password': 'Password',
        'forgot_pass': 'Forgot Password?',
        'purpose_title': 'What do you want to achieve?',
        'purpose_save': 'Learn to save',
        'purpose_finance': 'Learn about finance',
        'purpose_expenses': 'Track expenses',
        'purpose_invest': 'Learn to invest',
        'purpose_debts': 'Get out of debt',
        'purpose_goals': 'Achieve goals',
        'read_accept': 'I have read and accept the ',
        'terms': 'Terms and Conditions',
        'and': ' and the ',
        'privacy': 'Privacy Policy',
        'biometric_login': 'Log in with Fingerprint / Face ID',
        'biometric_enable': 'Enable Fingerprint/Face ID for next time',
        'btn_login': 'Log in to my account',
        'btn_register': 'Create my account',
        'err_missing': 'Missing data',
        'err_missing_desc': 'Please fill in all fields',
        'err_policies': 'Terms and Conditions',
        'err_policies_desc': 'You must accept the terms and policies to continue',
        'err_purpose': 'Purpose of use',
        'err_purpose_desc': 'Select what you want to achieve with the app',
        'err_cred': 'Credentials not found',
        'err_cred_desc': 'No saved credentials were found',
        'succ_login': 'Welcome back!',
        'succ_login_desc': 'We are glad to see you here',
        'succ_reg': 'Account successfully created!',
                'succ_reg_desc': 'Your financial wellbeing starts now',
        'new_to_quivo': 'New to QUIVO?',
        'already_have_account': 'Already have an account?',
      }
    };
    return translations[code]?[key] ?? translations['en']![key] ?? key;
  }

  void _showWelcomeMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        dismissDirection: DismissDirection.horizontal, 
        content: Row(
          children: [
            const Icon(LucideIcons.checkCircle, color: Colors.white, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLogin ? _t('succ_login') : _t('succ_reg'), 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isLogin ? _t('succ_login_desc') : _t('succ_reg_desc'), 
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9), height: 1.3)
                  ),
                ],
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF059669),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        duration: const Duration(seconds: 4),
        elevation: 10,
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String title, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        dismissDirection: DismissDirection.horizontal, 
        content: Row(
          children: [
            const Icon(LucideIcons.shieldAlert, color: Colors.white, size: 28),
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
        backgroundColor: isDark ? const Color(0xFF991B1B) : const Color(0xFFDC2626),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        duration: const Duration(seconds: 4),
        elevation: 10,
      ),
    );
  }

  Future<void> _loginWithBiometrics() async {
    final saved = await BiometricService.getSavedCredentials();
    if (saved != null && saved['email'] != null && saved['password'] != null) {
      final authenticated = await BiometricService.authenticate(reason: 'Autentícate para continuar');
      if (authenticated) {
        setState(() => _isLoading = true);
        try {
          await ref.read(authProvider.notifier).login(saved['email']!, saved['password']!);
          if (!mounted) return;
          _showWelcomeMessage(context);
          context.go('/dashboard');
        } catch (e) {
          _showErrorSnackBar(context, 'Error', e.toString());
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      }
    } else {
      _showErrorSnackBar(context, _t('err_cred'), _t('err_cred_desc'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = const Color(0xFF13131A); 
    final sheetColor = isDark ? const Color(0xFF1E1E26) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);
    final inputBg = isDark ? const Color(0xFF2A2A35) : const Color(0xFFF3F4F6);
    
    return Scaffold(
      backgroundColor: bgColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SafeArea(
                        bottom: false,
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 24.0),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => LanguageModal.show(context),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(LucideIcons.globe, color: Colors.white, size: 16),
                                          const SizedBox(width: 6),
                                          Text(
                                            ref.watch(localizationProvider).intlLocale.toUpperCase(),
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            Hero(
                              tag: 'app_logo',
                              child: Container(
                                width: 80, height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.5), blurRadius: 30, spreadRadius: -5),
                                  ]
                                ),
                                child: const Center(
                                  child: Text('Q', style: TextStyle(color: Color(0xFF0F172A), fontSize: 50, fontWeight: FontWeight.w900, fontFamily: 'serif', decoration: TextDecoration.none)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'QUIVO',
                              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2),
                            ),
                            const SizedBox(height: 24),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                isLogin ? _t('welcome') : _t('start_journey'),
                                key: ValueKey(isLogin),
                                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'serif'),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                      
                      const Spacer(),
                      
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: sheetColor,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 30, offset: const Offset(0, -10))
                          ],
                        ),
                        padding: const EdgeInsets.only(left: 32, right: 32, top: 32, bottom: 40),
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: inputBg,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => isLogin = true),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          decoration: BoxDecoration(
                                            color: isLogin ? (isDark ? Colors.white : const Color(0xFF0F172A)) : Colors.transparent,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: Text(_t('tab_login'), style: TextStyle(
                                              color: isLogin ? (isDark ? Colors.black : Colors.white) : subtitleColor,
                                              fontWeight: isLogin ? FontWeight.bold : FontWeight.w600,
                                            )),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => isLogin = false),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          decoration: BoxDecoration(
                                            color: !isLogin ? (isDark ? Colors.white : const Color(0xFF0F172A)) : Colors.transparent,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: Text(_t('tab_register'), style: TextStyle(
                                              color: !isLogin ? (isDark ? Colors.black : Colors.white) : subtitleColor,
                                              fontWeight: !isLogin ? FontWeight.bold : FontWeight.w600,
                                            )),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              Container(
                                decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(16)),
                                child: TextField(
                                  controller: _emailController,
                                  style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                                  decoration: InputDecoration(
                                    hintText: _t('email'),
                                    hintStyle: TextStyle(color: subtitleColor),
                                    prefixIcon: Icon(LucideIcons.mail, color: subtitleColor, size: 20),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              Container(
                                decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(16)),
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: obscurePassword,
                                  style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                                  decoration: InputDecoration(
                                    hintText: _t('password'),
                                    hintStyle: TextStyle(color: subtitleColor),
                                    prefixIcon: Icon(LucideIcons.lock, color: subtitleColor, size: 20),
                                    suffixIcon: IconButton(
                                      icon: Icon(obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye, color: subtitleColor, size: 20),
                                      onPressed: () => setState(() => obscurePassword = !obscurePassword),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                                  ),
                                ),
                              ),
                              
                              if (!isLogin) ...[
                                const SizedBox(height: 24),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(_t('purpose_title'), style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: purposes.map((p) {
                                    final isSelected = purpose == p['value'];
                                    return GestureDetector(
                                      onTap: () => setState(() => purpose = p['value'] as String),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFF3B82F6) : inputBg,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(p['icon'] as IconData, size: 16, color: isSelected ? Colors.white : subtitleColor),
                                            const SizedBox(width: 6),
                                            Text(_t(p['key'] as String), style: TextStyle(
                                              color: isSelected ? Colors.white : textColor,
                                              fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500
                                            )),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                              
                              const SizedBox(height: 16),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (isBiometricSupported && isLogin)
                                    GestureDetector(
                                      onTap: _loginWithBiometrics,
                                      child: Row(
                                        children: [
                                          const Icon(LucideIcons.fingerprint, color: Color(0xFF3B82F6), size: 20),
                                          const SizedBox(width: 8),
                                          Text(_t('biometric_login'), style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13)),
                                        ],
                                      ),
                                    )
                                  else if (isBiometricSupported && !isLogin)
                                    Row(
                                      children: [
                                        Switch(
                                          value: rememberBiometric,
                                          onChanged: (val) => setState(() => rememberBiometric = val),
                                          activeColor: const Color(0xFF3B82F6),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(_t('biometric_enable'), style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13)),
                                      ],
                                    )
                                  else const SizedBox(),
                                  
                                  if (isLogin)
                                    GestureDetector(
                                      onTap: () => ForgotPasswordModal.show(context),
                                      child: Text(_t('forgot_pass'), style: TextStyle(color: const Color(0xFF3B82F6), fontWeight: FontWeight.w700, fontSize: 13)),
                                    )
                                ],
                              ),
                              const SizedBox(height: 24),
                              
                              _AnimatedScaleButton(
                                onPressed: _isLoading ? null : () async {
                                  setState(() => _isLoading = true);
                                  try {
                                    if (isLogin) {
                                      await ref.read(authProvider.notifier).login(_emailController.text.trim(), _passwordController.text.trim());
                                      if (!mounted) return;
                                      _showWelcomeMessage(context);
                                      context.go('/dashboard');
                                    } else {
                                      await ref.read(authProvider.notifier).register(_emailController.text.trim(), _passwordController.text.trim(), purpose);
                                      if (!mounted) return;
                                      _showWelcomeMessage(context);
                                      context.go('/dashboard');
                                    }
                                  } catch (e) {
                                    _showErrorSnackBar(context, 'Error', e.toString());
                                  } finally {
                                    if (mounted) setState(() => _isLoading = false);
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))],
                                  ),
                                  child: Center(
                                    child: _isLoading
                                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                        : Text(isLogin ? _t('tab_login') : _t('tab_register'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              Row(
                                children: [
                                  Expanded(child: Divider(color: subtitleColor.withValues(alpha: 0.2))),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('OR CONTINUE WITH', style: TextStyle(color: subtitleColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                  ),
                                  Expanded(child: Divider(color: subtitleColor.withValues(alpha: 0.2))),
                                ],
                              ),
                              const SizedBox(height: 24),
                              
                              _AnimatedScaleButton(
                                onPressed: _isLoading ? null : () async {
                                  setState(() => _isLoading = true);
                                  try {
                                    await ref.read(authProvider.notifier).loginWithGoogle();
                                    if (!mounted) return;
                                    _showWelcomeMessage(context);
                                    context.go('/dashboard');
                                  } catch (e) {
                                    _showErrorSnackBar(context, 'Error', e.toString());
                                  } finally {
                                    if (mounted) setState(() => _isLoading = false);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF2A2A35) : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png', height: 20, errorBuilder: (_, __, ___) => const Icon(LucideIcons.chrome, color: Colors.blue)),
                                      const SizedBox(width: 10),
                                      Text('Google', style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 14)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  Text(isLogin ? _t('new_to_quivo') : _t('already_have_account'), style: TextStyle(color: subtitleColor, fontSize: 13)),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () => setState(() => isLogin = !isLogin),
                                    child: Text(isLogin ? _t('btn_register') : _t('btn_login'), style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 13)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AnimatedScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  const _AnimatedScaleButton({required this.child, this.onPressed});

  @override
  State<_AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<_AnimatedScaleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onPressed != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        onTapDown: widget.onPressed != null ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: widget.onPressed != null ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: widget.onPressed != null ? () => setState(() => _isPressed = false) : null,
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: widget.child,
        ),
      ),
    );
  }
}
