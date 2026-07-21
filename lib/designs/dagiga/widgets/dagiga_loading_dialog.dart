import 'package:flutter/material.dart';

import '/designs/frosted_glass/widgets/frosted_glass_effect.dart';
import '/pro_image_editor.dart';
import '../constants/dagiga_constants.dart';

/// Loading dialog for the Dagiga design kit.
class DagigaLoadingDialog extends StatelessWidget {
  /// Creates a [DagigaLoadingDialog].
  const DagigaLoadingDialog({
    super.key,
    required this.message,
    required this.configs,
  });

  /// Status message.
  final String message;

  /// Editor configs.
  final ProImageEditorConfigs configs;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const ModalBarrier(color: Colors.black38),
        Center(
          child: DefaultTextStyle(
            style: const TextStyle(),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FrostedGlassEffect(
                radius: BorderRadius.circular(16),
                child: Container(
                  color: Colors.transparent,
                  constraints: const BoxConstraints(maxWidth: 280),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: SizedBox(
                          height: 40,
                          width: 40,
                          child: FittedBox(
                            child: CircularProgressIndicator(
                              color: kDagigaAccent,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
