import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/auth_provider.dart';
import '../../providers/color_palette_provider.dart';
import '../../../core/utils/localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/currency_formatter.dart';

class CompleteProfileModal extends ConsumerStatefulWidget {
  const CompleteProfileModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CompleteProfileModal(),
    );
  }

  @override
  ConsumerState<CompleteProfileModal> createState() => _CompleteProfileModalState();
}

class _CompleteProfileModalState extends ConsumerState<CompleteProfileModal> {
  final TextEditingController countryController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  String selectedCurrency = 'USD';
  String selectedSalaryType = 'monthly'; // 'monthly' or 'biweekly'
  bool isLoading = false;

  final currencies = [
    {'code': 'USD', 'symbol': '\$', 'name': 'Dólar (US)'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GTQ', 'symbol': 'Q', 'name': 'Quetzal (GT)'},
    {'code': 'MXN', 'symbol': '\$', 'name': 'Peso (MX)'},
    {'code': 'COP', 'symbol': '\$', 'name': 'Peso (CO)'},
    {'code': 'ARS', 'symbol': '\$', 'name': 'Peso (AR)'},
    {'code': 'BRL', 'symbol': 'R\$', 'name': 'Real (BR)'},
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user = ref.read(authProvider).user;
      if (user != null && mounted) {
        if (user.country?.isNotEmpty == true) countryController.text = user.country!;
        if (user.salary?.isNotEmpty == true) salaryController.text = user.salary!;
        if (user.currency?.isNotEmpty == true) {
          setState(() {
            selectedCurrency = user.currency!;
            if (user.salaryType?.isNotEmpty == true) {
              selectedSalaryType = user.salaryType!;
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    countryController.dispose();
    salaryController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (countryController.text.isEmpty || salaryController.text.isEmpty) return;

    setState(() => isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('No user');

      final salary = double.tryParse(salaryController.text) ?? 0.0;
      
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'country': countryController.text,
        'currency': selectedCurrency,
        'salary': salary,
        'salaryType': selectedSalaryType,
        'profileComplete': true,
      });

      final currentUser = ref.read(authProvider).user;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          country: countryController.text,
          currency: selectedCurrency,
          salary: salary.toString(),
          salaryType: selectedSalaryType,
          profileComplete: true,
        );
        await ref.read(authProvider.notifier).updateProfile(updatedUser);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Perfil completado con éxito!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paletteGradient = ref.watch(colorPaletteProvider.notifier).getGradient(isDark);
    final loc = ref.watch(localizationProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: paletteGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(LucideIcons.userCheck, color: Colors.white, size: 28),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(loc.get('complete_profile'), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(loc.get('complete_profile_desc'), style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16)),
              ],
            ),
          ),

          // Form
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Country
                  Text(loc.get('country'), style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: countryController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Ej. México, Colombia, España',
                      hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
                      prefixIcon: Icon(LucideIcons.mapPin, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB))),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Currency
                  Text(loc.get('currency'), style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
                      border: Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCurrency,
                        isExpanded: true,
                        dropdownColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                        items: currencies.map((c) => DropdownMenuItem(
                          value: c['code'],
                          child: Row(
                            children: [
                              Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(color: paletteGradient[0].withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                child: Center(child: Text(c['symbol']!, style: TextStyle(color: paletteGradient[0], fontWeight: FontWeight.bold))),
                              ),
                              const SizedBox(width: 12),
                              Text('${c['name']} (${c['code']})', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                            ],
                          ),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => selectedCurrency = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Salary
                  Text(loc.get('salary'), style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: salaryController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            prefixIcon: Container(
                              padding: const EdgeInsets.all(12),
                              child: Text(CurrencyFormatter.getSymbol(selectedCurrency), style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            ),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
                            border: Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedSalaryType,
                              isExpanded: true,
                              dropdownColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                              items: [
                                DropdownMenuItem(value: 'monthly', child: Text('Mensual', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14))),
                                DropdownMenuItem(value: 'biweekly', child: Text('Quincenal', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14))),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => selectedSalaryType = val);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Submit
                  Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: paletteGradient),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: paletteGradient[0].withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: InkWell(
                      onTap: isLoading ? null : _saveProfile,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: isLoading 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(loc.get('save_changes'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
