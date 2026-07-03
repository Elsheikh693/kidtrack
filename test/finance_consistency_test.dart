import 'package:flutter_test/flutter_test.dart';
import 'package:kidtrack/Data/models/expense/expense_model.dart';
import 'package:kidtrack/Data/models/financial_transaction/financial_transaction_model.dart';
import 'package:kidtrack/presentation/screens/finance/services/finance_analytics_service.dart';

// Finance Consistency Test — the exact scenario the team defined.
//
// Branch A, one month (July 2026):
//   Ahmed  : form 300 + books 500 + uniform 700 + subscription 1500 = 3000
//   Mohamed: subscription 1500 + trip 250                            = 1750
//   Kareem : course 900                                              =  900
//   Revenue                                                          = 5650
//
//   Expenses: salaries 2500 + electricity 400                        = 2900
//   Net profit                                                       = 2750
//
//   Category summary: subscription 3000, course 900, uniform 700,
//                     books 500, form 300, trip 250  (sum = 5650)
void main() {
  final service = FinanceAnalyticsService();

  const branch = 'branchA';
  const nursery = 'n1';

  // July 2026 window.
  final startMs = DateTime(2026, 7, 1).millisecondsSinceEpoch;
  final endMs = DateTime(2026, 8, 1).millisecondsSinceEpoch;
  final day = DateTime(2026, 7, 4).millisecondsSinceEpoch;

  FinancialTransactionModel tx(
    String child,
    String catId,
    String catName,
    double amount,
  ) =>
      FinancialTransactionModel(
        nurseryId: nursery,
        branchId: branch,
        childId: child,
        childName: child,
        categoryId: catId,
        categoryName: catName,
        amount: amount,
        date: day,
      );

  ExpenseModel ex(String catId, String name, double amount) => ExpenseModel(
        nurseryId: nursery,
        branchId: branch,
        party: name,
        categoryId: catId,
        categoryName: name,
        amount: amount,
        paidAt: day,
        status: 'paid',
      );

  final transactions = <FinancialTransactionModel>[
    // Ahmed
    tx('ahmed', 'form', 'استمارة', 300),
    tx('ahmed', 'books', 'كتب', 500),
    tx('ahmed', 'uniform', 'يونيفورم', 700),
    tx('ahmed', 'subscription', 'اشتراك', 1500),
    // Mohamed
    tx('mohamed', 'subscription', 'اشتراك', 1500),
    tx('mohamed', 'trip', 'رحلات', 250),
    // Kareem
    tx('kareem', 'course', 'كورسات', 900),
  ];

  final expenses = <ExpenseModel>[
    ex('salaries', 'مرتبات', 2500),
    ex('electricity', 'كهرباء', 400),
  ];

  group('FinanceAnalyticsService — branch scope', () {
    test('revenue = 5650, expenses = 2900, net = 2750', () {
      final s = service.getSummary(
        transactions,
        expenses,
        branchId: branch,
        startMs: startMs,
        endMs: endMs,
      );
      expect(s.revenue, 5650);
      expect(s.expenses, 2900);
      expect(s.netProfit, 2750);
    });

    test('per-child totals (what Reception & Parent see)', () {
      double childTotal(String id) => transactions
          .where((t) => t.childId == id)
          .fold(0.0, (a, t) => a + t.amount);
      expect(childTotal('ahmed'), 3000);
      expect(childTotal('mohamed'), 1750);
      expect(childTotal('kareem'), 900);
    });

    test('Ahmed shows exactly his 4 categories', () {
      final ahmed = transactions.where((t) => t.childId == 'ahmed').toList();
      expect(ahmed.map((t) => t.categoryName).toSet(),
          {'استمارة', 'كتب', 'يونيفورم', 'اشتراك'});
    });

    test('category summary matches, highest first, sums to revenue', () {
      final cats = service.getCategorySummaries(
        transactions,
        branchId: branch,
        startMs: startMs,
        endMs: endMs,
      );

      final byName = {for (final c in cats) c.categoryName: c.total};
      expect(byName['اشتراك'], 3000);
      expect(byName['كورسات'], 900);
      expect(byName['يونيفورم'], 700);
      expect(byName['كتب'], 500);
      expect(byName['استمارة'], 300);
      expect(byName['رحلات'], 250);

      // subscription is aggregated across Ahmed + Mohamed → count 2.
      final sub = cats.firstWhere((c) => c.categoryName == 'اشتراك');
      expect(sub.transactionsCount, 2);

      // Sorted highest-earning first.
      expect(cats.first.categoryName, 'اشتراك');

      // Category totals reconcile with revenue.
      final sum = cats.fold(0.0, (a, c) => a + c.total);
      expect(sum, 5650);
    });
  });

  group('FinanceAnalyticsService — network scope (all branches)', () {
    test('same totals when branchId is null', () {
      final s = service.getSummary(
        transactions,
        expenses,
        branchId: null,
        startMs: startMs,
        endMs: endMs,
      );
      expect(s.revenue, 5650);
      expect(s.expenses, 2900);
      expect(s.netProfit, 2750);
    });
  });

  group('FinanceAnalyticsService — scoping guards', () {
    test('out-of-month transactions are excluded', () {
      final stale = tx('ahmed', 'form', 'استمارة', 999)
          .copyWith(date: DateTime(2026, 6, 30).millisecondsSinceEpoch);
      final s = service.getSummary(
        [...transactions, stale],
        expenses,
        branchId: branch,
        startMs: startMs,
        endMs: endMs,
      );
      expect(s.revenue, 5650); // stale June row ignored
    });

    test('other-branch rows are excluded under a branch scope', () {
      final other = tx('x', 'form', 'استمارة', 999).copyWith(branchId: 'branchB');
      final s = service.getSummary(
        [...transactions, other],
        expenses,
        branchId: branch,
        startMs: startMs,
        endMs: endMs,
      );
      expect(s.revenue, 5650); // branchB row ignored
    });

    test('non-collection transactions do not count as revenue', () {
      final refund = tx('ahmed', 'form', 'استمارة', 100)
          .copyWith(type: TransactionType.refund);
      final s = service.getSummary(
        [...transactions, refund],
        expenses,
        branchId: branch,
        startMs: startMs,
        endMs: endMs,
      );
      expect(s.revenue, 5650); // refund excluded by _scopeTx
    });
  });
}
