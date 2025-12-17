import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../Widget/Page_Title_widget.dart';
import '../../../Widget/amount_text_widget.dart';
import '../../../Widget/appbar_widget.dart';
import '../../../Widget/show_item_list_dialog.dart';
import '../../../Widget/empty_state_widget.dart';
import '../../../Widget/listview_loader_widget.dart';
import '../../../Widget/total_card_widget.dart';
import '../data/purchase_provider.dart';

class PurchaseSummaryScreen extends StatefulWidget {
  const PurchaseSummaryScreen({super.key});

  @override
  State<PurchaseSummaryScreen> createState() => _PurchaseSummaryScreenState();
}

class _PurchaseSummaryScreenState extends State<PurchaseSummaryScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  bool _isLoadingView = false;
  static bool _firstLoadDone = false;
  @override
  void initState() {
    super.initState();
     final _uid = FirebaseAuth.instance.currentUser!.uid;
     Provider.of<PurchaseProvider>(context, listen: false).initialize(_uid);
    if (!_firstLoadDone) {
      _triggerLoading();
    }
  }

  Future<void> _triggerLoading({bool force = false}) async {
    if (!_firstLoadDone || force) {
      setState(() => _isLoadingView = true);
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _isLoadingView = false;
          _firstLoadDone = true;
        });
      }
    }
  }

  void _onMonthYearChanged({int? month, int? year}) async {
    setState(() {
      if (month != null) _selectedMonth = month;
      if (year != null) _selectedYear = year;
    });
    await _triggerLoading(force: true);
  }

  String _getMonthName(int month) {
    return DateFormat.MMMM().format(DateTime(_selectedYear, month));
  }

  @override
  Widget build(BuildContext context) {
    final monthName = _getMonthName(_selectedMonth);

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: const AppbarWidget(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<PurchaseProvider>(
          builder: (context, provider, _) {
            final dailyTotals = provider.getDailyTotalsForMonth(
              _selectedYear,
              _selectedMonth,
            );
            final monthlyTotal = provider.getMonthlyTotal(
              _selectedYear,
              _selectedMonth,
            );

            final isLoading = _isLoadingView || provider.isLoading;

            return Column(
              children: [
                PageTitleWidget(
                  title: "Monthly Purchase Summary\n$monthName $_selectedYear",
                ),
                const SizedBox(height: 14),

                /// Month & Year Picker
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButton<int>(
                            value: _selectedMonth,
                            underline: const SizedBox(),
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
                            items: List.generate(12, (i) => i + 1)
                                .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(_getMonthName(m), style: const TextStyle(fontSize: 16)),
                            ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) _onMonthYearChanged(month: val);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButton<int>(
                            value: _selectedYear,
                            underline: const SizedBox(),
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
                            items: [2024, 2025, 2026, 2027]
                                .map((y) => DropdownMenuItem(
                              value: y,
                              child: Text("$y", style: const TextStyle(fontSize: 16)),
                            ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) _onMonthYearChanged(year: val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                /// Animated Content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isLoading
                        ? const ListviewLoaderWidget()
                        : dailyTotals.isEmpty
                        ? const EmptyStateWidget(
                      message: "No purchases this month",
                      icon: Icons.shopping_bag_outlined,
                      iconColor: Colors.green,
                    )
                        : ListView.builder(
                      key: ValueKey("$_selectedMonth-$_selectedYear"),
                      itemCount: dailyTotals.length,
                      itemBuilder: (context, index) {
                        final entry = dailyTotals.entries.elementAt(index);
                        final date = entry.key;
                        final amount = entry.value;

                        final dayPurchases = provider.purchases.where((p) {
                          return p.date.year == date.year &&
                              p.date.month == date.month &&
                              p.date.day == date.day;
                        }).toList();

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            onTap: () {
                              showItemListDialog(
                                context: context,
                                title:
                                "Purchases on ${DateFormat.yMMMMd().format(date)}",
                                date: date,
                                items: dayPurchases,
                                itemName: (p) => p.item,
                                itemAmount: (p) => p.amount,
                                iconColor: Colors.green,
                                icon: Icons.shopping_bag,
                                primaryColor: Colors.green,
                              );
                            },
                            leading: const CircleAvatar(
                              backgroundColor: Colors.green,
                              child: Icon(Icons.calendar_today, color: Colors.white),
                            ),
                            title: Text(
                              DateFormat.yMMMMd().format(date),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              "${dayPurchases.length} item${dayPurchases.length > 1 ? 's' : ''}",
                            ),
                            trailing: AmountText(
                              amount,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 16,
                            ),
                          ),
                          ), );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TotalCardWidget(
                  total: monthlyTotal,
                  title: "Total Purchase - $monthName $_selectedYear",
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}
