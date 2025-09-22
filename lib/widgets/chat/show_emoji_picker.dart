import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:characters/characters.dart';

class ShowEmojiPicker extends StatelessWidget {
  final bool isShowEmojiPicker;
  final TextEditingController messageController;
  final ValueChanged<String>? onTextChanged;

  const ShowEmojiPicker({
    Key? key,
    required this.isShowEmojiPicker,
    required this.messageController,
    this.onTextChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: !isShowEmojiPicker,
      child: SizedBox(
        height: 250,
        child: EmojiPicker(
          onEmojiSelected: (category, emoji) {
            try {
              final text = messageController.text;
              final selection = messageController.selection;
              final start =
                  selection.baseOffset >= 0 ? selection.baseOffset : 0;
              final end =
                  selection.extentOffset >= 0 ? selection.extentOffset : 0;

              final emojiText = emoji.emoji;
              if (emojiText.isNotEmpty) {
                final newText = text.replaceRange(start, end, emojiText);
                messageController.value = TextEditingValue(
                  text: newText,
                  selection: TextSelection.collapsed(
                    offset: start + emojiText.length,
                  ),
                );
                onTextChanged?.call(newText);
              }
            } catch (e) {
              print("Error inserting emoji: $e");
            }
          },
          onBackspacePressed: () {
            final controller = messageController;
            final text = controller.text;
            var selection = controller.selection;

            if (selection.start == -1) {
              selection = TextSelection.fromPosition(
                TextPosition(offset: text.length),
              );
            }

            final textBefore = selection.textBefore(text);
            final textAfter = selection.textAfter(text);

            if (textBefore.isEmpty) return;

            final newTextBefore = textBefore.characters.skipLast(1).toString();
            controller.value = TextEditingValue(
              text: newTextBefore + textAfter,
              selection: TextSelection.fromPosition(
                TextPosition(offset: newTextBefore.length),
              ),
            );
            onTextChanged?.call(controller.text);
          },
          textEditingController: null,
          config: Config(
            height: 250,
            checkPlatformCompatibility: true,
            emojiViewConfig: EmojiViewConfig(
              emojiSizeMax:
                  28 *
                  (foundation.defaultTargetPlatform ==
                          foundation.TargetPlatform.iOS
                      ? 1.2
                      : 1.0),
              columns: 7,
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
            ),
            skinToneConfig: const SkinToneConfig(),
            categoryViewConfig: const CategoryViewConfig(
              categoryIcons: CategoryIcons(),
              iconColor: Colors.grey,
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
            ),
            bottomActionBarConfig: const BottomActionBarConfig(
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
            ),
            searchViewConfig: const SearchViewConfig(
              backgroundColor: Colors.white,
              hintTextStyle: TextStyle(fontFamily: 'a-m'),
              inputTextStyle: TextStyle(fontFamily: 'a-m'),
            ),
          ),
        ),
      ),
    );
  }
}
