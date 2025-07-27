import 'package:flutter/gestures.dart';

import '../models/editor_configs/pro_image_editor_configs.dart';

/// A service that tracks the state of mouse buttons (left, right, and middle).
///
/// This service can be used in conjunction with a [Listener] widget to monitor
/// mouse button press and release events.
class MouseService {
  bool _isPrimaryMousePressed = false;

  /// Whether the primary (left) mouse button is currently pressed.
  bool get isPrimaryMousePressed => _isPrimaryMousePressed;

  bool _isSecondaryMousePressed = false;

  /// Whether the secondary (right) mouse button is currently pressed.
  bool get isSecondaryMousePressed => _isSecondaryMousePressed;

  bool _isMiddleMousePressed = false;

  /// Whether the middle mouse button is currently pressed.
  bool get isMiddleMousePressed => _isMiddleMousePressed;

  /// Handles a [PointerDownEvent] to update mouse button press states.
  ///
  /// This method should be called from the `onPointerDown` callback
  /// of a [Listener] widget.
  void onPointerDown(PointerDownEvent event) {
    final buttons = event.buttons;

    _isPrimaryMousePressed = (buttons & kPrimaryMouseButton) != 0;
    _isSecondaryMousePressed = (buttons & kSecondaryMouseButton) != 0;
    _isMiddleMousePressed = (buttons & kMiddleMouseButton) != 0;
  }

  /// Handles a [PointerUpEvent] to update mouse button release states.
  ///
  /// This method should be called from the `onPointerUp` callback
  /// of a [Listener] widget.
  void onPointerUp(PointerUpEvent event) {
    final buttons = event.buttons;

    if ((buttons & kPrimaryMouseButton) == 0) {
      _isPrimaryMousePressed = false;
    }
    if ((buttons & kSecondaryMouseButton) == 0) {
      _isSecondaryMousePressed = false;
    }
    if ((buttons & kMiddleMouseButton) == 0) {
      _isMiddleMousePressed = false;
    }
  }

  /// Returns `true` if panning is currently allowed based on the provided
  /// [configs] and the current mouse button states.
  ///
  /// Panning is only enabled when zooming is allowed (`enableZoom == true`)
  /// and the pressed mouse button is configured for a `pan` action.
  ///
  /// Checks all three mouse buttons (primary, secondary, and middle) against
  /// their assigned actions in [ProImageEditorConfigs.layerInteraction].
  ///
  /// Returns:
  /// - `true` if any of the currently pressed buttons is mapped to `pan`.
  /// - `false` otherwise.
  bool validatePanAction(ProImageEditorConfigs configs) {
    if (!configs.mainEditor.enableZoom) return false;

    final layerInteraction = configs.layerInteraction;

    final isPrimaryPan =
        layerInteraction.mouseButtonPrimaryAction == MouseButtonAction.pan &&
            isPrimaryMousePressed;
    final isSecondaryPan =
        layerInteraction.mouseButtonSecondaryAction == MouseButtonAction.pan &&
            isSecondaryMousePressed;
    final isMiddlePan =
        layerInteraction.mouseButtonMiddleAction == MouseButtonAction.pan &&
            isMiddleMousePressed;

    return isPrimaryPan || isSecondaryPan || isMiddlePan;
  }

  /// Returns `true` if drag selection is currently allowed based on the
  /// [configs] and the current mouse button states.
  ///
  /// This checks whether any of the mouse buttons
  /// (primary, secondary, or middle)
  /// is currently pressed and is assigned the `dragSelect` action in
  /// [ProImageEditorConfigs.layerInteraction].
  ///
  /// Returns:
  /// - `true` if any button is mapped to `dragSelect` and currently pressed.
  /// - `false` otherwise.
  bool validateDragAction(ProImageEditorConfigs configs) {
    final layerInteraction = configs.layerInteraction;

    final isPrimaryPan = layerInteraction.mouseButtonPrimaryAction ==
            MouseButtonAction.dragSelect &&
        isPrimaryMousePressed;
    final isSecondaryPan = layerInteraction.mouseButtonSecondaryAction ==
            MouseButtonAction.dragSelect &&
        isSecondaryMousePressed;
    final isMiddlePan = layerInteraction.mouseButtonMiddleAction ==
            MouseButtonAction.dragSelect &&
        isMiddleMousePressed;

    return isPrimaryPan || isSecondaryPan || isMiddlePan;
  }
}
