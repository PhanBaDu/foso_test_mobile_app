import 'package:flutter/material.dart';
import '../core/formatters.dart';
import '../theme.dart';
import '../view_models/cart_view_model.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.viewModel});
  final CartViewModel viewModel;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) {
      if (viewModel.lines.isEmpty) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FigmaIcon('cart', size: 64, color: AppColors.muted),
              SizedBox(height: 16),
              Text('Giỏ hàng của bạn đang trống'),
              SizedBox(height: 8),
              Text(
                'Khám phá sản phẩm tại Trang chủ',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        );
      }
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Giỏ hàng',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),
              for (final line in viewModel.lines)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      assetImage(line.product.image, width: 96, height: 100),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              line.product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${formatMoney(line.product.price)} đ',
                              style: const TextStyle(
                                color: AppColors.red,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  tooltip: 'Giảm số lượng',
                                  onPressed: () =>
                                      viewModel.remove(line.product.id),
                                  icon: const Text(
                                    '−',
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: AppColors.blue,
                                    ),
                                  ),
                                ),
                                Text('${line.quantity}'),
                                IconButton(
                                  tooltip: 'Tăng số lượng',
                                  onPressed: () =>
                                      viewModel.add(line.product.id),
                                  icon: const Text(
                                    '+',
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: AppColors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                'Tổng cộng: ${formatMoney(viewModel.total)} đ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
