import 'package:flutter/material.dart';
import '../theme.dart';

class ShopHeader extends StatelessWidget {
  const ShopHeader({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    this.onBack,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.blue,
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
        child: SizedBox(
          height: 38,
          child: Row(
            children: [
              if (onBack != null)
                Padding(
                  padding: const EdgeInsets.only(right: 23),
                  child: InkWell(
                    onTap: onBack,
                    child: const FigmaIcon('back', size: 21),
                  ),
                ),
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    controller: controller,
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm sản phẩm',
                      hintStyle: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 15,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(9),
                        child: FigmaIcon(
                          'search',
                          size: 20,
                          color: AppColors.muted,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 39),
                      suffixIcon: IconButton(
                        tooltip: 'Tìm kiếm bằng hình ảnh',
                        padding: EdgeInsets.zero,
                        icon: const FigmaIcon(
                          'camera',
                          size: 20,
                          color: AppColors.blue,
                        ),
                        onPressed: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Tìm kiếm bằng hình ảnh sẽ sớm được cập nhật.',
                                ),
                              ),
                            ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              SizedBox(
                width: 40,
                height: 38,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 38,
                  ),
                  tooltip: 'Thông báo',
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    builder: (_) => const SafeArea(
                      child: SizedBox(
                        height: 180,
                        child: Center(
                          child: Text('Bạn chưa có thông báo mới.'),
                        ),
                      ),
                    ),
                  ),
                  icon: const FigmaIcon('notification', size: 40),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
