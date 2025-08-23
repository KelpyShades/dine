import 'package:dine/components/store/data/models/vendor_models.dart';
import 'package:dine/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class VendorCard extends ConsumerWidget {
  final Vendor vendor;
  const VendorCard({super.key, required this.vendor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        context.push('/vendor', extra: vendor);
      },
      child: Container(
        // padding: const EdgeInsets.all(10),
        // margin: const EdgeInsets.all(8),
        width: 250,
        constraints: const BoxConstraints(maxHeight: 175),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withAlpha(100),
              spreadRadius: 2,
              blurRadius: 7,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: 250,
                  height: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(vendor.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                    // color: Colors.red,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                if (!vendor.isOpen)
                  Container(
                    width: 250,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(200),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: vendor.isOpen ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      vendor.isOpen ? 'Open' : 'Closed',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 5,
                children: [
                  Text(
                    vendor.name!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    vendor.description!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  Row(
                    spacing: 5,
                    children: [
                      Icon(Icons.location_on, size: 10, color: Colors.grey),
                      Text(
                        vendor.location!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
