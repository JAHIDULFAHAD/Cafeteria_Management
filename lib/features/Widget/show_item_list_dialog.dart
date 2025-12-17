import 'package:flutter/material.dart';

void showItemListDialog<T>({
  required BuildContext context,
  required String title,
  required DateTime date,
  required List<T> items,
  required String Function(T) itemName,
  required double Function(T) itemAmount,
  Color iconColor = Colors.green,
  IconData icon = Icons.shopping_bag,
  Color? primaryColor,
}) {
  // Smart amount formatting: 1000.0 → "1000", 999.50 → "999.50"
  String formatAmount(double amount) {
    if (amount == amount.truncateToDouble()) {
      return amount.toInt().toString();
    } else {
      return amount.toStringAsFixed(2);
    }
  }

  // Total calculation
  final double totalAmount = items.fold<double>(
    0.0,
        (sum, item) => sum + itemAmount(item),
  );


  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (context, anim1, anim2, child) {
      return Transform.scale(
        scale: anim1.value,
        child: Opacity(
          opacity: anim1.value,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white.withOpacity(0.95),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "$title",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor ?? Colors.green,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400), // ← overflow prevent
              child: items.isEmpty
                  ? const Center(
                child: Text(
                  "No items found for this date.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...items.map(
                          (item) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (primaryColor ?? Colors.green).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(icon, color: iconColor, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                itemName(item),
                                style: const TextStyle(fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "AED ${formatAmount(itemAmount(item))}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryColor ?? Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(thickness: 1),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (primaryColor ?? Colors.green).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(), // ← perfectly right aligned
                          Text(
                            "AED ${formatAmount(totalAmount)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryColor ?? Colors.green,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}