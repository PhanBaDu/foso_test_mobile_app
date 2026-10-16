import 'package:flutter/material.dart';
import '../models/catalog.dart';
import '../theme.dart';
import '../core/formatters.dart';

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
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: InkWell(
            onTap: () => showProductDetails(context, product, onBuy),
            child: Center(child: assetImage(product.image, width: 132)),
          ),
        ),
        if (limited)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB200),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FigmaIcon('fire', size: 10),
                SizedBox(width: 2),
                Text(
                  'Chỉ còn 1 sản phẩm',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7A4A00),
                  ),
                ),
              ],
            ),
          ),
        InkWell(
          onTap: () => showProductDetails(context, product, onBuy),
          child: Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '${formatMoney(product.price)} đ',
          style: TextStyle(
            color: Color(0xFFCF1717),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              '${formatMoney(product.originalPrice)} đ',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.muted,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            SizedBox(width: 10),
            Text(
              '-${product.discountPercent}%',
              style: TextStyle(fontSize: 10, color: AppColors.red),
            ),
          ],
        ),
        if (flash) ...[
          const SizedBox(height: 20),
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: const LinearProgressIndicator(
                  value: .63,
                  minHeight: 6,
                  backgroundColor: Color(0xFFF5D5D4),
                  color: Color(0xFFFF653D),
                ),
              ),
              const Positioned(
                left: 72,
                top: -8,
                child: FigmaIcon('fire', size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Đã bán ${product.soldCount} sản phẩm',
            style: TextStyle(fontSize: 10, color: Color(0xFF454F5B)),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 26,
          child: TextButton(
            onPressed: onBuy,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: AppColors.paleBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(
              'Mua ngay',
              style: TextStyle(
                fontSize: 11,
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

void showProductDetails(
  BuildContext context,
  Product product,
  VoidCallback onBuy,
) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: assetImage(product.image, width: 200, height: 180)),
            Text(
              product.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              '${formatMoney(product.price)} đ',
              style: TextStyle(
                color: AppColors.red,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  onBuy();
                },
                child: Text('Thêm vào giỏ hàng'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
