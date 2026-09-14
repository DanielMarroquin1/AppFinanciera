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
        'btn_login': 'Ingresar a mi cuenta',
        'btn_register': 'Crear mi cuenta',
        'google_login': 'Continuar con Google',
        'biometric_login': 'Ingresar con Huella / Face ID',
        'biometric_enable': 'Activar Huella/Face ID para la próxima vez',
        'err_missing': 'Faltan datos',
        'err_missing_desc': 'Por favor completa todos los campos.',
        'err_policies': 'Políticas',
        'err_policies_desc': 'Debes aceptar los términos y políticas para registrarte.',
        'err_purpose': 'Propósito',
        'err_purpose_desc': 'Por favor selecciona tu propósito principal para empezar.',
        'err_cred': 'Error',
        'err_cred_desc': 'Credenciales incorrectas o error de conexión. Inténtalo de nuevo.',
      },
      'en': {
        'tab_login': 'Login',
        'tab_register': 'Register',
        'welcome': 'Hello! Nice to see you',
        'welcome_sub': 'Your financial wellbeing starts here',
        'start_journey': 'Start your journey',
        'start_journey_sub': 'Create an account and take control',
        'email': 'Email address',
        'password': 'Password',
        'forgot_pass': 'Forgot your password?',
        'purpose_title': 'What do you want to achieve?',
        'purpose_save': 'Learn to save',
        'purpose_finance': 'Learn about finance',
        'purpose_expenses': 'Track my expenses',
        'purpose_invest': 'Learn to invest',
        'purpose_debts': 'Get out of debt',
        'purpose_goals': 'Reach my goals',
        'read_accept': 'I have read and accept the ',
        'terms': 'Terms & Conditions',
        'and': ' and ',
        'privacy': 'Privacy Policy',
        'btn_login': 'Log in to my account',
        'btn_register': 'Create my account',
        'google_login': 'Continue with Google',
        'biometric_login': 'Log in with Fingerprint / Face ID',
        'biometric_enable': 'Enable Fingerprint/Face ID for next time',
        'err_missing': 'Missing data',
        'err_missing_desc': 'Please fill all the fields.',
        'err_policies': 'Policies',
        'err_policies_desc': 'You must accept the terms and policies to register.',
        'err_purpose': 'Purpose',
        'err_purpose_desc': 'Please select your main purpose to start.',
        'err_cred': 'Error',
        'err_cred_desc': 'Incorrect credentials or connection error. Try again.',
      },
      'pt': {
        'tab_login': 'Entrar',
        'tab_register': 'Registrar',
        'welcome': 'Olá! Que bom ver você',
        'welcome_sub': 'Seu bem-estar financeiro começa aqui',
        'start_journey': 'Comece sua jornada',
        'start_journey_sub': 'Crie uma conta e assuma o controle',
        'email': 'E-mail',
        'password': 'Senha',
        'forgot_pass': 'Esqueceu sua senha?',
        'purpose_title': 'O que você quer alcançar?',
        'purpose_save': 'Aprender a economizar',
        'purpose_finance': 'Saber mais sobre finanças',
        'purpose_expenses': 'Aprender a gerenciar despesas',
        'purpose_invest': 'Aprender a investir',
        'purpose_debts': 'Sair das dívidas',
        'purpose_goals': 'Alcançar metas',
        'read_accept': 'Eu li e aceito os ',
        'terms': 'Termos e Condições',
        'and': ' e a ',
        'privacy': 'Política de Privacidade',
        'btn_login': 'Entrar na minha conta',
        'btn_register': 'Criar minha conta',
        'google_login': 'Continuar com o Google',
        'biometric_login': 'Entrar com Digital / Face ID',
        'biometric_enable': 'Ativar Digital/Face ID para a próxima vez',
        'err_missing': 'Dados ausentes',
        'err_missing_desc': 'Por favor, preencha todos os campos.',
        'err_policies': 'Políticas',
        'err_policies_desc': 'Você deve aceitar os termos e políticas para se registrar.',
        'err_purpose': 'Propósito',
        'err_purpose_desc': 'Por favor, selecione seu propósito principal para começar.',
        'err_cred': 'Erro',
        'err_cred_desc': 'Credenciais incorretas ou erro de conexão. Tente novamente.',
      },
      'fr': {
        'tab_login': 'Connexion',
        'tab_register': 'S\'inscrire',
        'welcome': 'Bonjour ! Ravi de vous voir',
        'welcome_sub': 'Votre bien-être financier commence ici',
        'start_journey': 'Commencez votre voyage',
        'start_journey_sub': 'Créez un compte et prenez le contrôle',
        'email': 'Adresse e-mail',
        'password': 'Mot de passe',
        'forgot_pass': 'Mot de passe oublié ?',
        'purpose_title': 'Que voulez-vous accomplir ?',
        'purpose_save': 'Apprendre à épargner',
        'purpose_finance': 'En savoir plus sur la finance',
        'purpose_expenses': 'Gérer mes dépenses',
        'purpose_invest': 'Apprendre à investir',
        'purpose_debts': 'Sortir des dettes',
        'purpose_goals': 'Atteindre mes objectifs',
        'read_accept': 'J\'ai lu et j\'accepte les ',
        'terms': 'Conditions générales',
        'and': ' et la ',
        'privacy': 'Politique de confidentialité',
        'btn_login': 'Connectez-vous à mon compte',
        'btn_register': 'Créer mon compte',
        'google_login': 'Continuer avec Google',
        'biometric_login': 'Se connecter avec Empreinte / Face ID',
        'biometric_enable': 'Activer l\'empreinte/Face ID pour la prochaine fois',
        'err_missing': 'Données manquantes',
        'err_missing_desc': 'Veuillez remplir tous les champs.',
        'err_policies': 'Politiques',
        'err_policies_desc': 'Vous devez accepter les termes et politiques pour vous inscrire.',
        'err_purpose': 'Objectif',
        'err_purpose_desc': 'Veuillez sélectionner votre objectif principal pour commencer.',
        'err_cred': 'Erreur',
        'err_cred_desc': 'Identifiants incorrects ou erreur de connexion. Réessayez.',
      },
      'it': {
        'tab_login': 'Accedi',
        'tab_register': 'Registrati',
        'welcome': 'Ciao! Bello vederti',
        'welcome_sub': 'Il tuo benessere finanziario inizia qui',
        'start_journey': 'Inizia il tuo viaggio',
        'start_journey_sub': 'Crea un account e prendi il controllo',
        'email': 'Indirizzo e-mail',
        'password': 'Password',
        'forgot_pass': 'Hai dimenticato la password?',
        'purpose_title': 'Cosa vuoi ottenere?',
        'purpose_save': 'Imparare a risparmiare',
        'purpose_finance': 'Saperne di più sulla finanza',
        'purpose_expenses': 'Gestire le mie spese',
        'purpose_invest': 'Imparare a investire',
        'purpose_debts': 'Uscire dai debiti',
        'purpose_goals': 'Raggiungere i miei obiettivi',
        'read_accept': 'Ho letto e accetto i ',
        'terms': 'Termini e Condizioni',
        'and': ' e la ',
        'privacy': 'Informativa sulla privacy',
        'btn_login': 'Accedi al mio account',
        'btn_register': 'Crea il mio account',
        'google_login': 'Continua con Google',
        'biometric_login': 'Accedi con Impronta / Face ID',
        'biometric_enable': 'Abilita Impronta/Face ID per la prossima volta',
        'err_missing': 'Dati mancanti',
        'err_missing_desc': 'Si prega di compilare tutti i campi.',
        'err_policies': 'Politiche',
        'err_policies_desc': 'Devi accettare i termini e le politiche per registrarti.',
        'err_purpose': 'Scopo',
        'err_purpose_desc': 'Seleziona il tuo scopo principale per iniziare.',
        'err_cred': 'Errore',
        'err_cred_desc': 'Credenziali errate o errore di connessione. Riprova.',
      }
    };
    return translations[code]?[key] ?? translations['en']![key] ?? translations['es']![key]!;
  }

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
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        onChanged: onChanged,
        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
          prefixIcon: Icon(icon, color: const Color(0xFF3B82F6), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  void _showWelcomeMessage(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(dismissDirection: DismissDirection.horizontal, 
      SnackBar(dismissDirection: DismissDirection.horizontal, 
        content: Row(
          children: [
            const Text('👋', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_t('welcome'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(_t('welcome_sub'), style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9), height: 1.3)),
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
        duration: const Duration(seconds: 4),
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

      final user = ref.read(authProvider).user;

      if (rememberBiometric && isBiometricSupported) {
        await BiometricService.setBiometricEnabled(true, loginEmail, loginPassword);
      } else {
        await BiometricService.setBiometricEnabled(false);
      }

      if (mounted) {
        _showWelcomeMessage(context);
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(dismissDirection: DismissDirection.horizontal, context, _t('err_cred'), _t('err_cred_desc'));
      }
    }
  }

  Future<void> _submit() async {
    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar(dismissDirection: DismissDirection.horizontal, context, _t('err_missing'), _t('err_missing_desc'));
      return;
    }

    if (!isLogin && !acceptedPolicies) {
      _showErrorSnackBar(dismissDirection: DismissDirection.horizontal, context, _t('err_policies'), _t('err_policies_desc'));
      return;
    }
    
    if (!isLogin && purpose.isEmpty) {
      _showErrorSnackBar(dismissDirection: DismissDirection.horizontal, context, _t('err_purpose'), _t('err_purpose_desc'));
      return;
    }

    setState(() => _isLoading = true);
    await _performLogin(email, password);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loginWithBiometrics() async {
    final authenticated = await BiometricService.authenticate(reason: _t('biometric_login'));
    if (authenticated) {
      final saved = await BiometricService.getSavedCredentials();
      if (saved != null && saved['email'] != null && saved['password'] != null) {
        setState(() => _isLoading = true);
        await _performLogin(saved['email']!, saved['password']!);
        if (mounted) setState(() => _isLoading = false);
      } else {
        if (mounted) {
          _showErrorSnackBar(dismissDirection: DismissDirection.horizontal, context, _t('err_cred'), _t('err_cred_desc'));
        }
      }
    }
  }


  void _showErrorSnackBar(dismissDirection: DismissDirection.horizontal, BuildContext context, String title, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(dismissDirection: DismissDirection.horizontal, 
      SnackBar(dismissDirection: DismissDirection.horizontal, 
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

  Widget _buildTopTabs(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                isLogin = true;
                acceptedPolicies = false;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isLogin ? (isDark ? const Color(0xFF3B82F6) : Colors.white) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isLogin && !isDark ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))] : [],
                ),
                child: Center(
                  child: Text(
                    _t('tab_login'),
                    style: TextStyle(
                      fontWeight: isLogin ? FontWeight.bold : FontWeight.w500,
                      color: isLogin ? (isDark ? Colors.white : const Color(0xFF0F172A)) : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isLogin = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isLogin ? (isDark ? const Color(0xFF3B82F6) : Colors.white) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: !isLogin && !isDark ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))] : [],
                ),
                child: Center(
                  child: Text(
                    _t('tab_register'),
                    style: TextStyle(
                      fontWeight: !isLogin ? FontWeight.bold : FontWeight.w500,
                      color: !isLogin ? (isDark ? Colors.white : const Color(0xFF0F172A)) : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
          // Gentle, Friendly Background Waves
          Positioned(
            top: -150, left: -100,
            child: Container(
              width: 400, height: 400, 
              decoration: BoxDecoration(
                shape: BoxShape.circle, 
                color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.10), blurRadius: 100)],
              ),
            ),
          ),
          Positioned(
            bottom: -200, right: -100,
            child: Container(
              width: 500, height: 500, 
              decoration: BoxDecoration(
                shape: BoxShape.circle, 
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.10), blurRadius: 100)],
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
                    // Friendly App Logo
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))
                          ],
                        ),
                        child: const Icon(LucideIcons.piggyBank, size: 56, color: Color(0xFF3B82F6)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    Text(
                      isLogin ? _t('welcome') : _t('start_journey'),
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
                      isLogin ? _t('welcome_sub') : _t('start_journey_sub'),
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    _buildTopTabs(isDark),

                    // Inputs
                    _buildInputField(
                      hint: _t('email'),
                      icon: LucideIcons.mail,
                      isDark: isDark,
                      controller: _emailController,
                      onChanged: (val) => setState(() => email = val),
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      hint: _t('password'),
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
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF3B82F6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                          ),
                          child: Text(_t('forgot_pass'), style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                    
                    if (!isLogin) const SizedBox(height: 24),

                    // Purposes
                    if (!isLogin) ...[
                      Text(_t('purpose_title'), style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontWeight: FontWeight.bold)),
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
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF3B82F6) : (isDark ? const Color(0xFF1E293B) : Colors.white),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : (isDark ? Colors.transparent : Colors.grey[200]!)),
                                boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(p['icon'] as IconData?, size: 18, color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600])),
                                  const SizedBox(width: 8),
                                  Text(
                                    _t(p['key'] as String),
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : const Color(0xFF0F172A)),
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: acceptedPolicies,
                              onChanged: (val) => setState(() => acceptedPolicies = val ?? false),
                              activeColor: const Color(0xFF3B82F6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, height: 1.5),
                                children: [
                                  TextSpan(text: _t('read_accept')),
                                  TextSpan(
                                    text: _t('terms'),
                                    style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                                    recognizer: TapGestureRecognizer()..onTap = () => TermsConditionsModal.show(context),
                                  ),
                                  TextSpan(text: _t('and')),
                                  TextSpan(
                                    text: _t('privacy'),
                                    style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                                    recognizer: TapGestureRecognizer()..onTap = () => PrivacyPolicyModal.show(context),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Submit Button
                    _AnimatedScaleButton(
                      onPressed: _isLoading ? null : _submit,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                              : Text(isLogin ? _t('btn_login') : _t('btn_register'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Google Login Button
                    _AnimatedScaleButton(
                      onPressed: _isLoading ? null : () async {
                        setState(() => _isLoading = true);
                        try {
                          await ref.read(authProvider.notifier).loginWithGoogle();
                          final user = ref.read(authProvider).user;
                          if (!mounted) return;
                          _showWelcomeMessage(context);
                          context.go('/dashboard');
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(dismissDirection: DismissDirection.horizontal, SnackBar(dismissDirection: DismissDirection.horizontal, content: Text('Error con Google: ${e.toString()}'), backgroundColor: Colors.red));
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
                          boxShadow: [
                            if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                          ]
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png', height: 22, errorBuilder: (_, __, ___) => const Icon(LucideIcons.chrome, color: Colors.blue)),
                            const SizedBox(width: 12),
                            Text(_t('google_login'), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),

                    if (isBiometricSupported) ...[
                      const SizedBox(height: 24),
                      if (isLogin) 
                        TextButton.icon(
                          onPressed: _isLoading ? null : _loginWithBiometrics,
                          icon: const Icon(LucideIcons.fingerprint, size: 28, color: Color(0xFF10B981)),
                          label: Text(_t('biometric_login'), style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w700, fontSize: 15)),
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        )
                      else
                        Row(
                          children: [
                            Switch(
                              value: rememberBiometric,
                              onChanged: (val) => setState(() => rememberBiometric = val),
                              activeColor: const Color(0xFF10B981),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_t('biometric_enable'), style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
                            )
                          ],
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Colorful Language Selector Button (Placed after SafeArea so it receives taps)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 24,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => LanguageModal.show(context),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.globe, color: const Color(0xFF3B82F6), size: 20),
                      const SizedBox(width: 6),
                      Text(
                        ref.watch(localizationProvider).intlLocale.toUpperCase(),
                        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
