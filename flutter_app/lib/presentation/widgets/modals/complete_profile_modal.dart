import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/auth_provider.dart';
import '../../providers/color_palette_provider.dart';
import '../../../core/utils/localization.dart';
import '../../../core/utils/country_currency_helper.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/config/database_config.dart';

class CompleteProfileModal extends ConsumerStatefulWidget {
  const CompleteProfileModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => const CompleteProfileModal(),
    );
  }

  @override
  ConsumerState<CompleteProfileModal> createState() =>
      _CompleteProfileModalState();
}

class _CompleteProfileModalState extends ConsumerState<CompleteProfileModal> {
  final TextEditingController _usernameController = TextEditingController();
  String _selectedCountry = 'Guatemala';
  String _selectedCountryFlag = '🇬🇹';
  String _selectedCurrency = 'Quetzales (GTQ)';
  String _selectedCurrencySymbol = 'Q';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user = ref.read(authProvider).user;
      if (user != null && mounted) {
        if (user.country != null && user.country!.isNotEmpty) {
          final cInfo = CountryCurrencyHelper.findCountry(user.country);
          setState(() {
            _selectedCountry = user.country!;
            if (cInfo != null) _selectedCountryFlag = cInfo['flag'] ?? '🌎';
          });
        }
        if (user.currency != null && user.currency!.isNotEmpty) {
          final currInfo = CountryCurrencyHelper.findCurrency(user.currency);
          setState(() {
            _selectedCurrency = user.currency!;
            if (currInfo != null) {
              _selectedCurrencySymbol = currInfo['symbol'] ?? '\$';
            }
          });
        }
        if (user.name.isNotEmpty && user.name != 'Usuario' && user.name != 'QUIVO') {
          _usernameController.text = user.name;
        }
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_selectedCountry.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, selecciona tu país.'),
          backgroundColor: Colors.amber[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('No user');

      final chosenUsername = _usernameController.text.trim();

      final updateData = <String, dynamic>{
        'country': _selectedCountry,
        'currency': _selectedCurrency,
        'profileComplete': true,
      };

      if (chosenUsername.isNotEmpty) {
        updateData['name'] = chosenUsername;
      }

      await DatabaseConfig.usersCollection.doc(uid).update(updateData);

      final currentUser = ref.read(authProvider).user;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          country: _selectedCountry,
          currency: _selectedCurrency,
          name: chosenUsername.isNotEmpty ? chosenUsername : currentUser.name,
          profileComplete: true,
        );
        await ref.read(authProvider.notifier).updateProfile(updatedUser);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            dismissDirection: DismissDirection.horizontal,
            content: Row(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '¡Perfil configurado con éxito!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(20),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final loc = ref.read(localizationProvider);
        final safeMsg = AppErrorHandler.getFriendlyMessage(e, loc) ??
            (loc.get('err_saving_data').isNotEmpty
                ? loc.get('err_saving_data')
                : 'No se pudo guardar la configuración. Intenta nuevamente.');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            dismissDirection: DismissDirection.horizontal,
            content: Text(
              safeMsg,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(20),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = ref.watch(colorPaletteProvider);
    final loc = ref.watch(localizationProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final primaryAccent = palette.colors.first;
    final secondaryAccent = palette.colors.length > 1 ? palette.colors[1] : primaryAccent;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Grab Handle
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Card with SAMI / Logo Welcome
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  primaryAccent.withValues(alpha: 0.22),
                                  secondaryAccent.withValues(alpha: 0.08),
                                ]
                              : [
                                  primaryAccent.withValues(alpha: 0.12),
                                  secondaryAccent.withValues(alpha: 0.04),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: primaryAccent.withValues(alpha: 0.25),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [primaryAccent, secondaryAccent],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryAccent.withValues(alpha: 0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('🌱', style: TextStyle(fontSize: 30)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryAccent.withValues(alpha: 0.20),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '¡Bienvenido a QUIVO!',
                                    style: TextStyle(
                                      color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Personaliza tu Perfil',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Configura tu país y moneda para adaptar tus balances financieros.',
                                  style: TextStyle(
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    fontSize: 12.5,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // SECTION 1: PAÍS (Country)
                    _buildSectionLabel(
                      title: 'País de Residencia',
                      isRequired: true,
                      isDark: isDark,
                      primaryAccent: primaryAccent,
                    ),
                    const SizedBox(height: 8),
                    _buildSelectionCard(
                      isDark: isDark,
                      leadingEmoji: _selectedCountryFlag,
                      title: _selectedCountry.isNotEmpty ? _selectedCountry : 'Selecciona tu país',
                      subtitle: 'Formato local de cuentas y presupuesto',
                      trailingText: 'Cambiar',
                      onTap: () {
                        CountryCurrencyHelper.showCountryModal(
                          context: context,
                          isDark: isDark,
                          currentCountry: _selectedCountry,
                          loc: loc,
                          onCountrySelected: (c) {
                            setState(() {
                              _selectedCountry = c['name'] ?? _selectedCountry;
                              _selectedCountryFlag = c['flag'] ?? _selectedCountryFlag;
                              // Auto-suggest country currency if available
                              if (c['currencyName'] != null) {
                                _selectedCurrency = c['currencyName']!;
                                _selectedCurrencySymbol = c['currencySymbol'] ?? '\$';
                              }
                            });
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // SECTION 2: MONEDA (Currency)
                    _buildSectionLabel(
                      title: 'Moneda Principal',
                      isRequired: true,
                      isDark: isDark,
                      primaryAccent: primaryAccent,
                    ),
                    const SizedBox(height: 8),
                    _buildSelectionCard(
                      isDark: isDark,
                      leadingBadgeText: _selectedCurrencySymbol,
                      title: _selectedCurrency.isNotEmpty ? _selectedCurrency : 'Selecciona tu moneda',
                      subtitle: 'Símbolo visual en gastos, ingresos y metas',
                      trailingText: 'Cambiar',
                      onTap: () {
                        CountryCurrencyHelper.showCurrencyModal(
                          context: context,
                          isDark: isDark,
                          currentCurrency: _selectedCurrency,
                          loc: loc,
                          onCurrencySelected: (curr) {
                            setState(() {
                              _selectedCurrency = curr['name'] ?? _selectedCurrency;
                              _selectedCurrencySymbol = curr['symbol'] ?? _selectedCurrencySymbol;
                            });
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // SECTION 3: NOMBRE DE USUARIO (Opcional)
                    _buildSectionLabel(
                      title: 'Nombre de Usuario',
                      isRequired: false,
                      isDark: isDark,
                      primaryAccent: primaryAccent,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _usernameController,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: '¿Cómo te gustaría que te llamemos?',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                          prefixIcon: Icon(
                            LucideIcons.user,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // SAVE BUTTON
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF10B981),
                            const Color(0xFF059669),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.8,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Comenzar mi Experiencia QUIVO',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15.5,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    LucideIcons.sparkles,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel({
    required String title,
    required bool isRequired,
    required bool isDark,
    required Color primaryAccent,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: isRequired
                ? const Color(0xFF10B981).withValues(alpha: 0.15)
                : (isDark ? Colors.grey[800] : Colors.grey[200]),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            isRequired ? 'Requerido' : 'Opcional',
            style: TextStyle(
              color: isRequired
                  ? const Color(0xFF10B981)
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionCard({
    required bool isDark,
    String? leadingEmoji,
    String? leadingBadgeText,
    required String title,
    required String subtitle,
    required String trailingText,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              if (leadingEmoji != null)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.25)
                        : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      leadingEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                )
              else if (leadingBadgeText != null)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      leadingBadgeText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF334155).withValues(alpha: 0.6)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      trailingText,
                      style: TextStyle(
                        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 14,
                      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
