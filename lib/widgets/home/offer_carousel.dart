import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../view_models/home_view_model.dart';

class OfferCarousel extends StatefulWidget {
  const OfferCarousel({
    super.key,
    required this.viewModel,
    required this.active,
  });
  final HomeViewModel viewModel;
  final bool active;
  @override
  State<OfferCarousel> createState() => _OfferCarouselState();
}

class _OfferCarouselState extends State<OfferCarousel> {
  late final _pageController = PageController(
    initialPage: widget.viewModel.banner,
  );
  Timer? _bannerTimer;
  @override
  void initState() {
    super.initState();
    _restartBannerTimer();
  }

  // A fresh one-shot timer after touch/scroll completion prevents autoplay races.
  void _restartBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      if (!widget.active ||
          !_pageController.hasClients ||
          MediaQuery.disableAnimationsOf(context) ||
          WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed ||
          _pageController.position.isScrollingNotifier.value) {
        _restartBannerTimer();
        return;
      }
      _pageController
          .animateToPage(
            (widget.viewModel.banner + 1) % 3,
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeInOutCubic,
          )
          .then((_) {
            if (mounted) _restartBannerTimer();
          });
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.viewModel,
    builder: (context, _) => Column(
      children: [
        SizedBox(
          height: 170,
          child: Listener(
            onPointerDown: (_) => _bannerTimer?.cancel(),
            onPointerUp: (_) => _restartBannerTimer(),
            onPointerCancel: (_) => _restartBannerTimer(),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification &&
                    notification.dragDetails != null) {
                  _bannerTimer?.cancel();
                } else if (notification is ScrollEndNotification) {
                  _restartBannerTimer();
                }
                return false;
              },
              child: PageView(
                physics: const PageScrollPhysics(),
                controller: _pageController,
                onPageChanged: (i) => widget.viewModel.selectBanner(i),
                children: ['offer_banner', 'offer_banner', 'offer_banner']
                    .map(
                      (name) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: assetImage(name, fit: BoxFit.fill),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(right: index < 2 ? 3 : 0),
                child: AnimatedContainer(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: 20,
                  height: 3,
                  decoration: BoxDecoration(
                    color: widget.viewModel.banner == index
                        ? AppColors.brightBlue
                        : const Color(0xFFC4CDD5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
