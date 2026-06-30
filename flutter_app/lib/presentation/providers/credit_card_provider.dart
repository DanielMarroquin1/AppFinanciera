import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/credit_card.dart';
import 'transaction_provider.dart';

final creditCardsProvider = StreamProvider<List<CreditCard>>((ref) {
  final user = firebase_auth.FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('credit_cards')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => CreditCard.fromFirestore(doc)).toList());
});

final computedCreditCardsProvider = Provider<AsyncValue<List<CreditCard>>>((ref) {
  final cardsAsync = ref.watch(creditCardsProvider);
  final txAsync = ref.watch(transactionsProvider);

  if (cardsAsync.isLoading || txAsync.isLoading) return const AsyncValue.loading();
  if (cardsAsync.hasError) return AsyncValue.error(cardsAsync.error!, cardsAsync.stackTrace!);
  if (txAsync.hasError) return AsyncValue.error(txAsync.error!, txAsync.stackTrace!);

  final cards = cardsAsync.value ?? [];
  final txs = txAsync.value ?? [];

  final computedCards = cards.map((card) {
    double spent = 0;
    double paid = 0;
    for (var tx in txs) {
      if (tx.creditCardId == card.id) {
        if (tx.type == 'expense') {
          spent += tx.amount;
        } else if (tx.type == 'cc_payment') {
          paid += tx.amount;
        }
      }
    }
    // card.currentBalance represents the initial debt when the card was created
    return card.copyWith(currentBalance: card.currentBalance + spent - paid);
  }).toList();

  return AsyncValue.data(computedCards);
});

class CreditCardNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> addCreditCard(CreditCard card) async {
    state = const AsyncValue.loading();
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('credit_cards')
          .add(card.toFirestore());
          
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateCreditCard(CreditCard card) async {
    state = const AsyncValue.loading();
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      // We only update the visual and configuration fields. 
      // We NEVER update currentBalance during edit to avoid overwriting the computed initialBalance.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('credit_cards')
          .doc(card.id)
          .update({
            'name': card.name,
            'limit': card.limit,
            'cutOffDay': card.cutOffDay,
            'paymentDay': card.paymentDay,
            'network': card.network,
            'color': card.color.value,
          });
          
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteCreditCard(String id) async {
    state = const AsyncValue.loading();
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('credit_cards')
          .doc(id)
          .delete();
          
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final creditCardControllerProvider = NotifierProvider<CreditCardNotifier, AsyncValue<void>>(() {
  return CreditCardNotifier();
});
