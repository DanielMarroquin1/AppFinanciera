import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';
import '../../../core/services/ai_analysis_service.dart';
import 'ai_plan_result_screen.dart';

class InteractiveAiPlanModal extends ConsumerStatefulWidget {
  const InteractiveAiPlanModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const InteractiveAiPlanModal(),
    );
  }

  @override
  ConsumerState<InteractiveAiPlanModal> createState() => _InteractiveAiPlanModalState();
}

class _InteractiveAiPlanModalState extends ConsumerState<InteractiveAiPlanModal> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isGenerating = false;

  // Form State
  String _goalName = '';
  double _targetAmount = 0.0;
  String _timeframe = '6 meses';
  String _riskProfile = 'Moderado';

  final _goalController = TextEditingController();
  final _amountController = TextEditingController();

  void _nextStep() {
    if (_currentStep == 0) {
      if (_goalController.text.isEmpty || _amountController.text.isEmpty) return;
      _goalName = _goalController.text;
      _targetAmount = double.tryParse(_amountController.text) ?? 0.0;
    }

    if (_currentStep < 2) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep++);
    } else {
      _generatePlan();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep--);
    }
  }

  Future<void> _generatePlan() async {
    setState(() => _isGenerating = true);
    
    // Simulate generation for demo, but normally call AI here
    final user = ref.read(authProvider).user;
    
    // Create prompt
    final prompt = '''
      Eres un asesor financiero experto. El usuario ${user?.name ?? ''} quiere crear el siguiente plan de ahorro:
      - Meta: $_goalName
      - Monto: $_targetAmount
      - Plazo: $_timeframe
      - Perfil de Ajuste: $_riskProfile
      
      Genera un plan de accion paso a paso, con un resumen ejecutivo, recomendaciones de ahorro, y riesgos potenciales. Devuelve el texto estructurado en Markdown.
    ''';

    // Call AI (we use AiAnalysisService logic directly or a new method. For now, we simulate).
    // In reality, you'd call ref.read(chatProvider.notifier).sendMessage(prompt) or a direct API.
    // We will just wait a bit and push the result screen.
    await Future.delayed(const Duration(seconds: 3));
    
    final mockMarkdown = '''
# Plan Financiero: $_goalName

## 1. Resumen Ejecutivo
Para alcanzar **\$$_targetAmount** en **$_timeframe** con un perfil **$_riskProfile**, necesitarás ahorrar de manera disciplinada.

## 2. Cuota de Ahorro Sugerida
Debes ahorrar aproximadamente un monto especifico cada mes. Ajusta tus gastos innecesarios como salidas a comer o suscripciones.

## 3. Estrategia a Seguir
* **Paso 1:** Abre una cuenta separada para este fondo.
* **Paso 2:** Automatiza tus transferencias cada día de pago.
* **Paso 3:** Revisa tus gastos hormiga de fin de semana.

## 4. Riesgos
* Inflación o gastos inesperados. Mantén tu fondo de emergencia intacto.
    ''';

    setState(() => _isGenerating = false);
    if (mounted) {
      Navigator.pop(context); // close modal
      AiPlanResultScreen.show(context, planMarkdown: mockMarkdown, goalName: _goalName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          Text('Creador de Plan de Ahorro IA', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 24),
          
          // Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 4,
                    decoration: BoxDecoration(
                      color: index <= _currentStep ? Theme.of(context).primaryColor : (isDark ? Colors.grey[800] : Colors.grey[300]),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),

          // Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(isDark),
                _buildStep2(isDark),
                _buildStep3(isDark),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (_currentStep > 0 && !_isGenerating)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Atrás', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (_currentStep > 0 && !_isGenerating) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isGenerating ? null : _nextStep,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isGenerating 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(_currentStep == 2 ? 'Generar Plan Mágico' : 'Siguiente', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStep1(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('1. Define tu objetivo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('¿Qué quieres lograr y cuánto necesitas?', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
          const SizedBox(height: 32),
          
          TextField(
            controller: _goalController,
            decoration: InputDecoration(
              labelText: 'Nombre de la Meta (ej. Coche nuevo)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(LucideIcons.target),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Monto a Ahorrar',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(LucideIcons.dollarSign),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(bool isDark) {
    final options = ['3 meses', '6 meses', '1 año', '2 años', '5 años'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('2. Tiempo Estimado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('¿Para cuándo necesitas este dinero?', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
          const SizedBox(height: 32),
          
          ...options.map((opt) => RadioListTile(
            title: Text(opt),
            value: opt,
            groupValue: _timeframe,
            onChanged: (v) => setState(() => _timeframe = v.toString()),
            activeColor: Theme.of(context).primaryColor,
            contentPadding: EdgeInsets.zero,
          )),
        ],
      ),
    );
  }

  Widget _buildStep3(bool isDark) {
    final options = [
      {'title': 'Conservador', 'desc': 'Ahorros lentos sin afectar tu estilo de vida'},
      {'title': 'Moderado', 'desc': 'Recortes de lujos pero sin ser extremo'},
      {'title': 'Agresivo', 'desc': 'Ahorro masivo recortando todos los gastos no esenciales'},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('3. Perfil de Ajuste', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('¿Qué tan estrictos pueden ser tus recortes?', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
          const SizedBox(height: 32),
          
          ...options.map((opt) => RadioListTile(
            title: Text(opt['title']!),
            subtitle: Text(opt['desc']!),
            value: opt['title']!,
            groupValue: _riskProfile,
            onChanged: (v) => setState(() => _riskProfile = v.toString()),
            activeColor: Theme.of(context).primaryColor,
            contentPadding: EdgeInsets.zero,
          )),
        ],
      ),
    );
  }
}
