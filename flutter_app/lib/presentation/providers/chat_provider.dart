import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/domain/models/chat_message.dart';
import 'package:flutter_app/domain/repositories/ai_repository.dart';
import 'package:flutter_app/data/repositories/ai_repository_impl.dart';
import 'package:flutter_app/presentation/providers/transaction_provider.dart';
import 'package:flutter_app/presentation/providers/debts_provider.dart';
import 'package:flutter_app/presentation/providers/auth_provider.dart';

final aiRepositoryProvider = Provider<AIRepository>((ref) {
  return AIRepositoryImpl();
});

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  late AIRepository _repository;

  @override
  ChatState build() {
    _repository = ref.read(aiRepositoryProvider);
    return ChatState();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(text: text, role: MessageRole.user);
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    try {
      // Obtener contexto financiero
      final transactions = ref.read(transactionsProvider).value ?? [];
      final debts = ref.read(debtsProvider).value ?? [];
      final authState = ref.read(authProvider);
      
      final contextStr = _buildFinancialContext(transactions, debts, authState.user);

      final responseStream = _repository.sendMessage(
        text, 
        state.messages.sublist(0, state.messages.length - 1),
        context: contextStr,
      );

      String fullResponse = '';
      ChatMessage? assistantMessage;

      await for (final chunk in responseStream) {
        fullResponse += chunk;
        
        // Intentar parsear el chunk para ver si es un payload JSON de propuesta
        bool isProposal = false;
        Map<String, dynamic>? payload;
        String displayText = fullResponse;

        try {
          final decoded = jsonDecode(fullResponse);
          if (decoded is Map<String, dynamic> && decoded['___PROPOSAL___'] == true) {
            isProposal = true;
            payload = decoded;
            displayText = "He analizado tus datos y tengo una propuesta de ahorro para ti.";
          }
        } catch (_) {
          // No es JSON, o aún no está completo (en el caso de stream)
        }

        if (assistantMessage == null) {
          assistantMessage = ChatMessage(
            text: displayText, 
            role: MessageRole.assistant,
            isProposal: isProposal,
            payload: payload,
          );
          state = state.copyWith(
            messages: [...state.messages, assistantMessage],
          );
        } else {
          assistantMessage = ChatMessage(
            text: displayText, 
            role: MessageRole.assistant,
            isProposal: isProposal,
            payload: payload,
          );
          state = state.copyWith(
            messages: [...state.messages.sublist(0, state.messages.length - 1), assistantMessage],
          );
        }
      }
    } catch (e) {
      final errorMessage = ChatMessage(
        text: 'Lo siento, hubo un error al procesar tu solicitud: $e', 
        role: MessageRole.assistant
      );
      state = state.copyWith(
        messages: [...state.messages, errorMessage],
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  String _buildFinancialContext(dynamic transactions, dynamic debts, dynamic user) {
    // Gastos e Ingresos
    final expensesList = transactions.where((t) => t.type == 'expense').toList();
    final incomesList = transactions.where((t) => t.type == 'income').toList();
    
    final totalExpenses = expensesList.fold(0.0, (sum, item) => sum + (item.amount as num).toDouble());
    final totalIncomes = incomesList.fold(0.0, (sum, item) => sum + (item.amount as num).toDouble());
    final totalDebts = debts.fold(0.0, (sum, item) {
      final remainingInstallments = item.totalInstallments - item.paidInstallments;
      return sum + (item.installmentAmount * remainingInstallments);
    });

    // Desglose de Gastos por Categoría
    final Map<String, double> expensesByCategory = {};
    for (var exp in expensesList) {
      expensesByCategory[exp.category] = (expensesByCategory[exp.category] ?? 0.0) + exp.amount;
    }
    
    String categoryBreakdown = expensesByCategory.entries
        .map((e) => "  - ${e.key}: \$${e.value.toStringAsFixed(2)}")
        .join("\n");

    // Desglose de Deudas
    String debtsBreakdown = debts.isEmpty 
        ? "  - No hay deudas registradas." 
        : debts.map((d) {
            final remaining = d.installmentAmount * (d.totalInstallments - d.paidInstallments);
            return "  - ${d.name}: Restante \$${remaining.toStringAsFixed(2)} (${d.paidInstallments}/${d.totalInstallments} cuotas)";
          }).join("\n");

    // Datos del Usuario
    final salary = user?.salary ?? 'No especificado';
    final currency = user?.currency ?? 'USD';
    final country = user?.country ?? 'No especificado';
    final purpose = user?.purpose ?? 'No especificado';

    return '''
Resumen financiero y perfil del usuario:
- País: $country
- Moneda principal: $currency
- Salario mensual declarado: $salary
- Objetivo financiero principal: $purpose

Estado Actual:
- Ingresos totales registrados: \$${totalIncomes.toStringAsFixed(2)}
- Gastos totales registrados: \$${totalExpenses.toStringAsFixed(2)}
- Deudas totales registradas: \$${totalDebts.toStringAsFixed(2)}

Desglose de Gastos por Categoría:
$categoryBreakdown

Detalle de Deudas:
$debtsBreakdown

Instrucción adicional para la IA: Utiliza estos datos precisos para crear estrategias personalizadas, planes de ahorro o presupuestos si el usuario te lo solicita. No inventes números, cíñete a los datos proporcionados.
''';
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(() {
  return ChatNotifier();
});
