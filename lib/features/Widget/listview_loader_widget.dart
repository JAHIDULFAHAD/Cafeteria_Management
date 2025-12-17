import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
class ListviewLoaderWidget extends StatelessWidget {
  const ListviewLoaderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              title: Container(
                height: 14,
                width: double.infinity,
                color: Colors.white,
              ),
              subtitle: Container(
                margin: const EdgeInsets.only(top: 6),
                height: 12,
                width: 100,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}