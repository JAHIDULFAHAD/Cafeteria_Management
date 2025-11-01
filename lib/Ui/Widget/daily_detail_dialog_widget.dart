import 'package:flutter/material.dart';

/// Reusable dialog for showing itemized data (expenses, purchases, etc.)
void showItemListDialog<T>({
  required BuildContext context,
  required String title,
  required DateTime date,
  required List<T> items,
  required String Function(T) itemName,
  required String Function(T) itemAmount,
  Color iconColor = Colors.orange,
  IconData icon = Icons.receipt_long,
  Color? primaryColor,
}) {
  final totalAmount = items.fold<double>(
    0,
        (sum, item) => sum + double.tryParse(itemAmount(item))!,
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
            backgroundColor:
            Colors.white.withValues(alpha: 0.95), // ✅ replaced withValues
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$title ${date.day}/${date.month}/${date.year}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor ?? Colors.orange,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: items.isEmpty
                  ? const Center(
                child: Text(
                  "No items found for this date.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...items.map(
                        (item) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (primaryColor ?? Colors.orange)
                            .withValues(alpha: 0.1), // ✅ updated
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(icon, color: iconColor),
                              const SizedBox(width: 8),
                              Text(
                                itemName(item),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "AED ${itemAmount(item)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryColor ?? Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (primaryColor ?? Colors.orange)
                          .withValues(alpha: 0.1), // ✅ updated
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "AED ${totalAmount.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryColor ?? Colors.orange,
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
      );
    },
  );
}
