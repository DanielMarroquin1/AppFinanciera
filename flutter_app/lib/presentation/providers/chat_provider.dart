import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/domain/models/chat_message.dart';
import 'package:flutter_app/domain/repositories/ai_repository.dart';
import 'package:flutter_app/data/repositories/ai_repository_impl.dart';
import 'package:flutter_app/presentation/providers/transaction_provider.dart';
import 'package:flutter_app/presentation/providers/debts_provider.dart';
import 'package:flutter_app/presentation/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_app/domain/entities/transaction.dart' as entity;
import 'package:flutter_app/domain/entities/saving_goal.dart';
import 'package:flutter_app/presentation/providers/saving_goals_provider.dart';

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
          if (decoded is Map<String, dynamic>) {
            if (decoded['___PROPOSAL___'] == true) {
              isProposal = true;
              payload = decoded;
              displayText = "He analizado tus datos y tengo una propuesta de ahorro para ti.";
            } else if (decoded['___ADD_TRANSACTION___'] == true) {
              payload = decoded;
              final typeStr = decoded['type'] == 'income' ? 'ingreso' : 'gasto';
              displayText = "Registrando tu $typeStr de \$${decoded['amount']} en la categoría ${decoded['category']}... ¡Listo!";
              _executeAddTransaction(decoded);
            } else if (decoded['___CREATE_SAVINGS_GOAL___'] == true) {
              payload = decoded;
              displayText = "Creando la meta de ahorro: ${decoded['name']} por \$${decoded['targetAmount']}... ¡Listo!";
              _executeCreateSavingsGoal(decoded);
            }
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

    // Datos del Usuario e idioma
    final rawLang = user?.language ?? 'Español';
    final lower = rawLang.toLowerCase();
    
    String labelProfile = 'Resumen financiero y perfil del usuario:';
    String labelCountry = 'País';
    String labelCurrency = 'Moneda principal';
    String labelSalary = 'Salario mensual declarado';
    String labelPurpose = 'Objetivo financiero principal';
    String labelLang = 'Idioma preferido';
    String labelState = 'Estado Actual:';
    String labelIncomes = 'Ingresos totales registrados';
    String labelExpenses = 'Gastos totales registrados';
    String labelDebts = 'Deudas totales registradas';
    String labelCategoryBreakdown = 'Desglose de Gastos por Categoría:';
    String labelDebtsDetail = 'Detalle de Deudas:';
    String noDebtsMsg = '  - No hay deudas registradas.';
    String debtRemainingMsg = 'Restante';
    String installmentMsg = 'cuotas';
    String languageInstruction = 'Instrucción de Idioma: DEBES responder SIEMPRE en el idioma preferido por el usuario (Español). Responde todas las consultas en español.';
    String aiInstruction = 'Instrucción adicional para la IA: Utiliza estos datos precisos para crear estrategias personalizadas, planes de ahorro o presupuestos si el usuario te lo solicita. No inventes números, cíñete a los datos proporcionados.';

    if (lower == 'english' || lower == 'en') {
      labelProfile = 'Financial summary and user profile:';
      labelCountry = 'Country';
      labelCurrency = 'Main currency';
      labelSalary = 'Declared monthly salary';
      labelPurpose = 'Main financial goal';
      labelLang = 'Preferred language';
      labelState = 'Current State:';
      labelIncomes = 'Total registered incomes';
      labelExpenses = 'Total registered expenses';
      labelDebts = 'Total registered debts';
      labelCategoryBreakdown = 'Expense Breakdown by Category:';
      labelDebtsDetail = 'Debts Detail:';
      noDebtsMsg = '  - No registered debts.';
      debtRemainingMsg = 'Remaining';
      installmentMsg = 'installments';
      languageInstruction = "Language Instruction: You MUST always respond in the user's preferred language (English). Answer all queries in English.";
      aiInstruction = 'Additional instruction for the AI: Use these precise data to create personalized strategies, saving plans or budgets if requested by the user. Do not invent numbers, stick to the provided data.';
    } else if (lower == 'português' || lower == 'pt') {
      labelProfile = 'Resumo financeiro e perfil do usuário:';
      labelCountry = 'País';
      labelCurrency = 'Moeda principal';
      labelSalary = 'Salário mensal declarado';
      labelPurpose = 'Objetivo financeiro principal';
      labelLang = 'Idioma preferido';
      labelState = 'Estado Atual:';
      labelIncomes = 'Total de receitas registradas';
      labelExpenses = 'Total de despesas registradas';
      labelDebts = 'Total de dívidas registradas';
      labelCategoryBreakdown = 'Desmembramento de Despesas por Categoria:';
      labelDebtsDetail = 'Detalhe de Dívidas:';
      noDebtsMsg = '  - Nenhuma dívida registrada.';
      debtRemainingMsg = 'Restante';
      installmentMsg = 'parcelas';
      languageInstruction = "Instrução de Idioma: Você DEVE sempre responder no idioma preferido do usuário (Português). Responda a todas as consultas em português.";
      aiInstruction = 'Instrução adicional para a IA: Use esses dados precisos para criar estratégias personalizadas, planos de poupança ou orçamentos se solicitado pelo usuário. Não invente números, atenha-se aos dados fornecidos.';
    } else if (lower == 'français' || lower == 'fr') {
      labelProfile = 'Résumé financier et profil de l\'utilisateur :';
      labelCountry = 'Pays';
      labelCurrency = 'Devise principale';
      labelSalary = 'Salaire mensuel déclaré';
      labelPurpose = 'Objectif financier principal';
      labelLang = 'Langue préférée';
      labelState = 'État Actuel :';
      labelIncomes = 'Total des revenus enregistrés';
      labelExpenses = 'Total des dépenses enregistrées';
      labelDebts = 'Total des dettes enregistrées';
      labelCategoryBreakdown = 'Répartition des Dépenses par Catégorie :';
      labelDebtsDetail = 'Détail des Dettes :';
      noDebtsMsg = '  - Aucune dette enregistrée.';
      debtRemainingMsg = 'Restant';
      installmentMsg = 'échéances';
      languageInstruction = "Instruction de Langue: Vous DEVEZ toujours répondre dans la langue préférée de l'utilisateur (Français). Répondez à toutes les requêtes en français.";
      aiInstruction = 'Instruction supplémentaire pour l\'IA : Utilisez ces données précises pour créer des stratégies personnalisées, des plans d\'épargne ou des budgets si l\'utilisateur le demande. N\'inventez pas de chiffres, tenez-vous-en aux données fournies.';
    } else if (lower == 'italiano' || lower == 'it') {
      labelProfile = 'Riepilogo finanziario e profilo utente:';
      labelCountry = 'Paese';
      labelCurrency = 'Valuta principale';
      labelSalary = 'Stipendio mensile dichiarato';
      labelPurpose = 'Obbiettivo finanziario principale';
      labelLang = 'Lingua preferita';
      labelState = 'Stato Attuale:';
      labelIncomes = 'Totale entrate registrate';
      labelExpenses = 'Totale spese registrate';
      labelDebts = 'Totale debiti registrati';
      labelCategoryBreakdown = 'Ripartizione delle Spese per Categoria:';
      labelDebtsDetail = 'Dettaglio Debiti:';
      noDebtsMsg = '  - Nessun debito registrato.';
      debtRemainingMsg = 'Rimanente';
      installmentMsg = 'rate';
      languageInstruction = "Istruzione della Lingua: DEVI sempre rispondere nella lingua preferita dell'utente (Italiano). Rispondi a tutte le query in italiano.";
      aiInstruction = 'Istruzione aggiuntiva per l\'IA: Utilizza questi dati precisi per creare strategie personalizzate, piani di risparmio o budget se richiesto dall\'utente. Non inventare numeri, attieniti ai dati forniti.';
    }

    // Desglose de Deudas
    String debtsBreakdown = debts.isEmpty 
        ? noDebtsMsg 
        : debts.map((d) {
            final remaining = d.installmentAmount * (d.totalInstallments - d.paidInstallments);
            return "  - ${d.name}: $debtRemainingMsg \$${remaining.toStringAsFixed(2)} (${d.paidInstallments}/${d.totalInstallments} $installmentMsg)";
          }).join("\n");

    final salary = user?.salary ?? 'No especificado';
    final currency = user?.currency ?? 'USD';
    final country = user?.country ?? 'No especificado';
    final purpose = user?.purpose ?? 'No especificado';

    return '''
$labelProfile
- $labelCountry: $country
- $labelCurrency: $currency
- $labelSalary: $salary
- $labelPurpose: $purpose
- $labelLang: $rawLang

$labelState
- $labelIncomes: \$${totalIncomes.toStringAsFixed(2)}
- $labelExpenses: \$${totalExpenses.toStringAsFixed(2)}
- $labelDebts: \$${totalDebts.toStringAsFixed(2)}

$labelCategoryBreakdown
$categoryBreakdown

$labelDebtsDetail
$debtsBreakdown

$languageInstruction

$aiInstruction
''';
  }

  Future<void> _executeAddTransaction(Map<String, dynamic> decoded) async {
    try {
      final tx = entity.TransactionModel(
        id: '',
        userId: firebase_auth.FirebaseAuth.instance.currentUser?.uid ?? '',
        amount: (decoded['amount'] as num).toDouble(),
        type: decoded['type'] ?? 'expense',
        category: decoded['category'] ?? 'other',
        description: decoded['description'] ?? 'Transacción de Zent AI',
        date: DateTime.now(),
        isFixed: false,
      );
      await ref.read(transactionNotifierProvider.notifier).addTransaction(tx);
    } catch (e) {
      print('Error executing add_transaction from Zent AI: $e');
    }
  }

  Future<void> _executeCreateSavingsGoal(Map<String, dynamic> decoded) async {
    try {
      final user = ref.read(authProvider).user;
      if (user == null) return;
      
      final goal = SavingGoal(
        id: '',
        userId: user.email,
        name: decoded['name'] ?? 'Meta de ahorro',
        targetAmount: (decoded['targetAmount'] as num).toDouble(),
        currentAmount: 0.0,
        icon: decoded['icon'] ?? '🎯',
      );
      await ref.read(savingGoalsProvider.notifier).addGoal(goal);
    } catch (e) {
      print('Error executing create_savings_goal from Zent AI: $e');
    }
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(() {
  return ChatNotifier();
});
