import 'package:flutter/material.dart';
import 'package:mastercs_mobile/presentation/app/payments/widgets/owner/collection_progress_header.dart';

class CurrencyData {
  final String currency;
  final int totalCollected;
  final int totalExpected;

  const CurrencyData({
    required this.currency,
    required this.totalCollected,
    required this.totalExpected,
  });
}

class CurrencyProgressCarousel extends StatefulWidget {
  final List<CurrencyData> currencyData;

  const CurrencyProgressCarousel({super.key, required this.currencyData});

  @override
  State<CurrencyProgressCarousel> createState() =>
      _CurrencyProgressCarouselState();
}

class _CurrencyProgressCarouselState extends State<CurrencyProgressCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPage) {
        setState(() {
          _currentPage = newPage;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.currencyData.isEmpty) {
      return const SizedBox.shrink();
    }

    if (widget.currencyData.length == 1) {
      // Single currency - no carousel needed
      final data = widget.currencyData.first;
      return CollectionProgressHeader(
        totalCollected: data.totalCollected,
        totalExpected: data.totalExpected,
        currency: data.currency,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // PageView carousel
        SizedBox(
          height: 230,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.currencyData.length,
            itemBuilder: (context, index) {
              final data = widget.currencyData[index];
              return CollectionProgressHeader(
                totalCollected: data.totalCollected,
                totalExpected: data.totalExpected,
                currency: data.currency,
              );
            },
          ),
        ),

        // Page indicators
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: List.generate(widget.currencyData.length, (index) {
              final isActive = index == _currentPage;
              final data = widget.currencyData[index];

              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isActive ? 14 : 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withAlpha(200),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isActive
                        ? null
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: colorScheme.primary.withAlpha(40),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isActive) ...[
                        Icon(
                          Icons.circle,
                          size: 6,
                          color: colorScheme.onPrimary,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        data.currency,
                        style: TextStyle(
                          color: isActive
                              ? colorScheme.onPrimary
                              : colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
