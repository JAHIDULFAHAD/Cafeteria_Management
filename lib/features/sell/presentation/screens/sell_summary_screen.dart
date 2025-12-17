import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../Widget/Page_Title_widget.dart';
import '../../../Widget/amount_text_widget.dart';
import '../../../Widget/appbar_widget.dart';
import '../../../Widget/show_item_list_dialog.dart'; // যদি দরকার হয় (এখানে ব্যবহার করিনি)
import '../../../Widget/empty_state_widget.dart';
import '../../../Widget/listview_loader_widget.dart';
import '../../../Widget/total_card_widget.dart';
import '../data/sell_provider.dart';

class SellSummaryScreen extends StatefulWidget {
  const SellSummaryScreen({super.key});

  @override
  State<SellSummaryScreen> createState() => _SellSummaryScreenState();
}

class _SellSummaryScreenState extends State<SellSummaryScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  bool _isLoadingView = false;
  static bool _firstLoadDone = false;

  @override
  void initState() {
    super.initState();
    Provider.of<SellProvider>(context, listen: false)..initialize();
    if (!_firstLoadDone) {
      _triggerLoading();
    }
  }

  Future<void> _triggerLoading({bool force = false}) async {
    if (!_firstLoadDone || force) {
      setState(() => _isLoadingView = true);
      await Future.delayed(const Duration(milliseconds: 500)); // simulation delay
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
        child: Consumer<SellProvider>(
          builder: (context, provider, _) {
            final monthlySells = provider.getMonthlySellList(
              _selectedYear,
              _selectedMonth,
            );

            // Sort by date (oldest first)
            monthlySells.sort((a, b) => a.date.compareTo(b.date));

            // Calculate totals
            final totalSell = monthlySells.fold<double>(
              0.0,
                  (sum, s) => sum + s.amount,
            );
            final totalNetCash = monthlySells.fold<double>(
              0.0,
                  (sum, s) => sum + s.netCash,
            );

            final isLoading = _isLoadingView || provider.isLoading;

            return Column(
              children: [
                PageTitleWidget(
                  title: "Monthly Sells Summary\n$monthName $_selectedYear",
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
                            items: List.generate(5, (i) => DateTime.now().year - 2 + i)
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
                        : monthlySells.isEmpty
                        ? const EmptyStateWidget(
                      message: "No Sell Records Found",
                      icon: Icons.sell_outlined,
                      iconColor: Colors.grey,
                    )
                        : ListView.builder(
                      key: ValueKey("$_selectedMonth-$_selectedYear"),
                      itemCount: monthlySells.length,
                      itemBuilder: (context, index) {
                        final sell = monthlySells[index];
                        final day = sell.date.day;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.shade100,
                              child: Text(
                                "$day",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            title: Text(
                              "$monthName $day, $_selectedYear",
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Row(
                              children: [
                                Text('Net Cash: ',style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),),
                                AmountText(
                                  sell.netCash,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: sell.netCash >= 0 ? Colors.green : Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  "Sell",
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                AmountText(
                                  sell.amount,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// Summary Cards Row
                TotalCardWidget(
                  total: totalSell,
                  title: "Total Sell - $monthName $_selectedYear",
                ),
                const SizedBox(width: 12),
                TotalCardWidget(
                  total: totalNetCash,
                  title: "Net Profit - $monthName $_selectedYear",
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