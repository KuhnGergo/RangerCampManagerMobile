import 'package:flutter/material.dart';
import 'package:flutter_color_picker_wheel/flutter_color_picker_wheel.dart';
import 'package:flutter_color_picker_wheel/models/button_behaviour.dart';
import 'package:mastercs_mobile/presentation/app/chats/utils/chat_color_helper.dart';
import 'package:mastercs_mobile/presentation/auth/utils/form_field_style.dart';
import 'package:mastercs_mobile/utils/chat_color_palette.dart';

class ChatColorSelectorField extends StatelessWidget {
  final String labelText;
  final Color selectedColor;
  final ValueChanged<Color> onChanged;
  final bool enabled;
  final String? errorText;

  const ChatColorSelectorField({
    super.key,
    required this.labelText,
    required this.selectedColor,
    required this.onChanged,
    this.enabled = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Opacity(
      opacity: enabled ? 1 : 0.75,
      child: IgnorePointer(
        ignoring: !enabled,
        child: InputDecorator(
          decoration: getFormFieldDecoration(
            labelText: labelText,
            themeData: theme,
            errorText: errorText,
            enabled: enabled,
            prefixIcon: Icon(Icons.palette_outlined),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          child: ClipRect(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select Color',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface.withAlpha(150),
                    ),
                  ),

                  const SizedBox(width: 8),
                  WheelColorPicker(
                    behaviour: ButtonBehaviour.clickToOpen,
                    defaultColor: selectedColor,
                    onSelect: onChanged,
                    animationConfig: fanLikeAnimationConfig,
                    colorList: chatColorWheelPalette,
                    buttonSize: 32,
                    pieceHeight: 18,
                    innerRadius: 50,
                    fanPieceBorderSize: 1,
                  ),
                  const SizedBox(width: 8),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: ChatColorHelper.getBackgroundColor(
                        '',
                        asColor: selectedColor,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(width: 24, height: 24),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
