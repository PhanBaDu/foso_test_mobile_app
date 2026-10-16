import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

class ShopHeader extends StatelessWidget {
  const ShopHeader({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    this.onBack,
    this.onSearchTap,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onBack;
  final VoidCallback? onSearchTap;

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
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: onBack != null ? 1 : 0),
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                builder: (context, progress, child) => SizedBox(
                  width: 44 * progress,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.centerLeft,
                      minWidth: 44,
                      maxWidth: 44,
                      child: Opacity(
                        opacity: progress.clamp(0, 1),
                        child: Transform.translate(
                          offset: Offset(-8 * (1 - progress), 0),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ),
                child: ExcludeSemantics(
                  excluding: onBack == null,
                  child: IgnorePointer(
                    ignoring: onBack == null,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 23),
                      child: InkWell(
                        onTap: onBack == null
                            ? null
                            : () {
                                HapticFeedback.mediumImpact();
                                onBack!();
                              },
                        child: const FigmaIcon('arrow-left', size: 21),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    controller: controller,
                    onTap: onSearchTap,
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
                  onPressed: null,
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
