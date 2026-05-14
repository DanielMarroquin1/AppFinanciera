import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class ForgotPasswordModal extends ConsumerStatefulWidget {
  const ForgotPasswordModal({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ForgotPasswordModal(),
    );
  }

  @override
  ConsumerState<ForgotPasswordModal> createState() => _ForgotPasswordModalState();
}

class _ForgotPasswordModalState extends ConsumerState<ForgotPasswordModal> {
  String email = '';
  bool sent = false;

  Future<void> _handleSubmit() async {
    try {
      await ref.read(authProvider.notifier).resetPassword(email);
      if (!mounted) return;
      
      // Mostrar mensaje emergente de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se ha enviado el enlace de recuperación exitosamente.'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Cerramos el modal inmediatamente
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Ocurrió un error al enviar el correo.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo conectar con el servidor.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : Colors.white.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón Cerrar
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(LucideIcons.x, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 20),
              ),
            ),
            
            if (!sent) ...[
              // Icono principal
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF581C87).withValues(alpha: 0.3) : const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(LucideIcons.mail, size: 32, color: isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA)),
              ),
              const SizedBox(height: 16),
              
              Text(
                '¿Olvidaste tu contraseña?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ingresa tu correo y te enviaremos un enlace para recuperar tu cuenta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Formulario
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Correo Electrónico', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: (val) => setState(() => email = val),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'tu@email.com',
                  prefixIcon: Icon(LucideIcons.mail, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF374151) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFA855F7), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Consumer(
                builder: (context, ref, child) {
                  final isLoading = ref.watch(authProvider).isLoading;
                  return ElevatedButton(
                    onPressed: email.isEmpty || isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.transparent, 
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: email.isEmpty || isLoading 
                            ? LinearGradient(colors: [isDark ? const Color(0xFF374151) : Colors.grey[300]!, isDark ? const Color(0xFF374151) : Colors.grey[300]!])
                            : const LinearGradient(colors: [Color(0xFF9333EA), Color(0xFF2563EB)]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 52),
                        child: isLoading 
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Enviar Enlace', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                },
              ),
            ] else ...[
              // Estado Enviado Exitoso
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF14532D).withValues(alpha: 0.3) : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(LucideIcons.checkCircle2, size: 32, color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A)),
              ),
              const SizedBox(height: 16),
              Text(
                '¡Correo Enviado!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
                  children: [
                    const TextSpan(text: 'Hemos enviado un enlace de recuperación a '),
                    TextSpan(text: email, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF9333EA), Color(0xFF2563EB)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 52),
                    child: const Text('Entendido', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
