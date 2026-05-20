import 'package:flutter/material.dart';
import 'package:mastercs_mobile/presentation/app/payments/widgets/camper/payment_summary_header.dart';
import 'package:mastercs_mobile/presentation/app/payments/widgets/camper/payment_progress_bar.dart';

class CamperCurrencyData {
  final String currency;
  final int paidAmount;
  final int upcomingAmount;

  const CamperCurrencyData({
    required this.currency,
    required this.paidAmount,
    required this.upcomingAmount,
  });

  int get totalAmount => paidAmount + upcomingAmount;
}

class CamperCurrencyCarousel extends StatefulWidget {
  final List<CamperCurrencyData> currencyData;

  const CamperCurrencyCarousel({super.key, required this.currencyData});

  @override
  State<CamperCurrencyCarousel> createState() => _CamperCurrencyCarouselState();
}

class _CamperCurrencyCarouselState extends State<CamperCurrencyCarousel> {
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
      return Column(
        children: [
          PaymentSummaryHeader(
            upcomingAmount: data.upcomingAmount,
            paidAmount: data.paidAmount,
            currency: data.currency,
          ),
          const SizedBox(height: 8),
          PaymentProgressBar(
            paidAmount: data.paidAmount,
            totalAmount: data.totalAmount,
            currency: data.currency,
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // PageView carousel
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.currencyData.length,
            itemBuilder: (context, index) {
              final data = widget.currencyData[index];
              return Column(
                children: [
                  PaymentSummaryHeader(
                    upcomingAmount: data.upcomingAmount,
                    paidAmount: data.paidAmount,
                    currency: data.currency,
                  ),
                  const SizedBox(height: 8),
                  PaymentProgressBar(
                    paidAmount: data.paidAmount,
                    totalAmount: data.totalAmount,
                    currency: data.currency,
                  ),
                ],
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
                          fontSize: 13,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.w500,
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
