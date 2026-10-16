import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// Keeps the editor mounted while its back-button slot expands or collapses.
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
                  width: 39 * progress,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.centerLeft,
                      minWidth: 39,
                      maxWidth: 39,
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
                    child: Semantics(
                      label: 'Quay lại',
                      button: true,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onBack == null
                            ? null
                            : () {
                                HapticFeedback.mediumImpact();
                                onBack!();
                              },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 18),
                          child: SizedBox(
                            height: 38,
                            child: Center(
                              child: FigmaIcon('arrow-left', size: 21),
                            ),
                          ),
                        ),
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
                    textCapitalization: TextCapitalization.none,
                    autocorrect: false,
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
                        constraints: const BoxConstraints.tightFor(
                          width: 32,
                          height: 38,
                        ),
                        icon: const FigmaIcon(
                          'camera',
                          size: 20,
                          color: AppColors.blue,
                        ),
                        onPressed: null,
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
