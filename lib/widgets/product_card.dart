import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/catalog.dart';
import '../theme.dart';
import 'sales_progress.dart';

/// Shared native-sized card; buying is the only interactive action.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.onBuy,
    required this.product,
    this.flash = false,
    this.limited = false,
  });

  final VoidCallback onBuy;
  final Product product;
  final bool flash;
  final bool limited;

  @override
  Widget build(BuildContext context) => Container(
    width: 148,
    height: flash
        ? 340
        : limited
        ? 320
        : 290,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Center(child: assetImage(product.image, width: 124))),
        const SizedBox(height: 12),
        if (limited)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB200),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FigmaIcon('flashsale', size: 12),
                SizedBox(width: 3),
                Text(
                  'Chỉ còn 1 sản phẩm',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.limitedStockText,
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          height: 40,
          child: Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${formatMoney(product.price)} đ',
          style: const TextStyle(
            color: Color(0xFFCF1717),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              '${formatMoney(product.originalPrice)} đ',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.muted,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '-${product.discountPercent}%',
              style: const TextStyle(fontSize: 11, color: AppColors.red),
            ),
          ],
        ),
        if (flash) ...[
          const SizedBox(height: 12),
          const SalesProgress(value: 0.63),
          const SizedBox(height: 12),
          Text(
            'Đã bán ${product.soldCount} sản phẩm',
            style: const TextStyle(fontSize: 11, color: Color(0xFF454F5B)),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 30,
          child: TextButton(
            onPressed: onBuy,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: AppColors.paleBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text(
              'Mua ngay',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.blue,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
