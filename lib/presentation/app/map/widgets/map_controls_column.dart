import 'package:flutter/material.dart';
import 'package:mastercs_mobile/presentation/app/map/widgets/focus_me_button.dart';
import 'package:mastercs_mobile/presentation/app/map/widgets/zoom_in_button.dart';
import 'package:mastercs_mobile/presentation/app/map/widgets/zoom_out_button.dart';
import 'package:mastercs_mobile/presentation/app/map/widgets/orientation_button.dart';
import 'package:mastercs_mobile/presentation/app/map/widgets/layer_switcher.dart';

class MapControlsColumn extends StatelessWidget {
  const MapControlsColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const FocusButton(),
        const SizedBox(height: 8),
        const ZoomInButton(),
        const SizedBox(height: 8),
        const ZoomOutButton(),
        const SizedBox(height: 8),
        const OrientationButton(),
        const SizedBox(height: 8),
        const LayerSwitcher(),
      ],
    );
  }
}
