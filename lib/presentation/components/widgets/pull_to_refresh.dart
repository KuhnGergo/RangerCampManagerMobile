import 'package:flutter/material.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';

class PullToRefreshController {
  VoidCallback? _completeRefresh;

  void completeRefresh() {
    _completeRefresh?.call();
  }

  void dispose() {
    _completeRefresh = null;
  }
}

class PullToRefresh extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final PullToRefreshController? controller;
  final double dragFactor;
  final double triggerOffset;
  final double minVisibleOffset;

  const PullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.controller,
    this.dragFactor = 0.6,
    this.triggerOffset = 20,
    this.minVisibleOffset = 30,
  });

  @override
  State<PullToRefresh> createState() => _PullToRefreshState();
}

class _PullToRefreshState extends State<PullToRefresh>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0;
  bool _isRefreshing = false;
  bool _isCompleting = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    widget.controller?._completeRefresh = _handleRefreshComplete;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(PullToRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._completeRefresh = null;
      widget.controller?._completeRefresh = _handleRefreshComplete;
    }
  }

  /// Centralized animation method for offset changes
  Future<void> _animateOffsetTo(double targetOffset) async {
    final animation = Tween<double>(begin: _dragOffset, end: targetOffset)
        .animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    void listener() {
      if (mounted) {
        setState(() {
          _dragOffset = animation.value;
        });
      }
    }

    animation.addListener(listener);
    await _animationController.forward(from: 0);
    animation.removeListener(listener);
  }

  void _handleRefreshComplete() {
    if (!_isRefreshing) return;

    // Trigger fadeout animation on the indicator
    setState(() {
      _isCompleting = true;
    });
  }

  void _handleFadeoutComplete() {
    // After fadeout completes, animate offset back to 0
    _animateOffsetTo(0).then((_) {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _isCompleting = false;
          _dragOffset = 0;
        });
      }
    });
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);

    // Animate to minimum visible offset
    await _animateOffsetTo(widget.minVisibleOffset);

    // Call the refresh callback
    await widget.onRefresh();

    // If no controller is provided, auto-complete
    if (widget.controller == null) {
      _handleRefreshComplete();
    }
  }

  void _handleCancelPull() {
    // Animate back to 0 when pull is cancelled
    _animateOffsetTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (_isRefreshing) return false;

        if (notification is OverscrollNotification) {
          final adjustedOverscroll =
              notification.overscroll * widget.dragFactor;

          if (notification.overscroll < 0) {
            // Pulling down (increasing overscroll)
            setState(() {
              _dragOffset = (_dragOffset - adjustedOverscroll).clamp(
                0.0,
                double.infinity,
              );
            });
          } else if (notification.overscroll > 0 && _dragOffset > 0) {
            // Scrolling back up (decreasing overscroll)
            setState(() {
              _dragOffset = (_dragOffset - adjustedOverscroll).clamp(
                0.0,
                double.infinity,
              );
            });
          }
        }

        if (notification is ScrollEndNotification) {
          if (_dragOffset > widget.triggerOffset) {
            _handleRefresh();
          } else if (_dragOffset > 0) {
            _handleCancelPull();
          }
        }

        return false;
      },
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Transform.translate(
            offset: Offset(0, _dragOffset),
            child: widget.child,
          ),
          if (_dragOffset > 0 || _isRefreshing)
            Positioned(
              top: _dragOffset > 0
                  ? (_dragOffset / 2 - 20).clamp(10.0, 30.0)
                  : 16,
              child: Opacity(
                opacity: _isRefreshing
                    ? 1.0
                    : (_dragOffset / widget.triggerOffset).clamp(0.0, 1.0),
                child: ThreeDotLoadingIndicator(
                  size: 40,
                  value: _isRefreshing
                      ? null
                      : (_dragOffset / widget.triggerOffset).clamp(0.0, 1.0),
                  isCompleting: _isCompleting,
                  onCompleted: _handleFadeoutComplete,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.controller?._completeRefresh = null;
    _animationController.dispose();
    super.dispose();
  }
}
