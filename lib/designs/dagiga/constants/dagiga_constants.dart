import 'package:flutter/material.dart';

/// Fade-in duration used across Dagiga chrome.
const kDagigaFadeInDuration = Duration(milliseconds: 220);

/// Stagger delay between Dagiga fade-in animations.
const kDagigaFadeInStaggerDelay = Duration(milliseconds: 25);

/// Height of the text / paint sub-bar strips (Figma: py 8 + 32 controls).
const kDagigaSubBarHeight = 48.0;

/// Editor background (Dagiga navy).
const kDagigaBackground = Color(0xFF000529);

/// Frosted bottom sheet tint (`#000529` @ ~70% opacity).
const kDagigaBottomSheetBackground = Color(0xB3000529);

/// Backdrop blur strength for the frosted bottom sheet (matches Figma blur).
const kDagigaBottomSheetBlurSigma = 8.0;

/// Translucent strip behind font / color controls (Figma `rgba(0,0,0,0.4)`).
const kDagigaStripBackground = Color(0x66000000);

/// Accent / Save button fill.
const kDagigaAccent = Color(0xFFD3DE00);

/// Text selection border (Figma `#d7e400`).
const kDagigaSelectionBorder = Color(0xFFD7E400);

/// Accent text on Save button.
const kDagigaAccentForeground = Color(0xFF000529);

/// Tool chip fill (`rgba(217,217,217,0.1)`).
const kDagigaChipBackground = Color(0x1AD9D9D9);

/// Circle control fill on color strip (`rgba(255,255,255,0.3)`).
const kDagigaCircleControlFill = Color(0x4DFFFFFF);

/// Alternate Style glyph box (`rgba(140,140,140,0.55)`).
const kDagigaAlternateStyleFill = Color(0x8C8C8C8C);

/// Unselected font chip label (`rgba(235,235,235,0.9)`).
const kDagigaFontChipForeground = Color(0xE6EBEBEB);

/// Top corner radius for the bottom options sheet.
const kDagigaBottomSheetRadius = 14.0;

/// Main tool sheet horizontal inset (Figma `6352:12645` px 20).
const kDagigaMainSheetHorizontal = 20.0;

/// Main tool sheet top inset (Figma `6352:12644` pt 20).
const kDagigaMainSheetTop = 20.0;

/// Main tool sheet bottom inset (Figma `6352:12644` pb 40).
const kDagigaMainSheetBottom = 40.0;

/// Gap between main tool chips (Figma `6352:12645` gap 12).
const kDagigaMainToolGap = 12.0;

/// Tool chip corner radius (Figma sticker/logo pills use 32).
const kDagigaToolChipRadius = 32.0;

/// Tool chip horizontal padding (Figma Label px 12).
const kDagigaToolChipPaddingH = 12.0;

/// Tool chip vertical padding (Figma Label py 8).
const kDagigaToolChipPaddingV = 8.0;

/// Gap between icon and label inside a tool chip (Figma gap 8).
const kDagigaToolChipIconGap = 8.0;

/// Tool icon size (Figma size 16).
const kDagigaToolIconSize = 16.0;

/// Minimum chip width when scrolling (Figma w 83 on some pills).
const kDagigaToolChipMinWidth = 83.0;

/// Filter preview strip height in sub-editors.
const kDagigaFilterListHeight = 72.0;

/// Control diameter used by color / close / eyedropper circles.
const kDagigaControlSize = 32.0;

/// Gap between color-strip controls (Figma `6347:10414` gap 16).
const kDagigaColorStripGap = 16.0;

/// Selected swatch ring width (Figma `border-3`).
const kDagigaSwatchSelectedBorderWidth = 3.0;

/// Selected swatch ring color (Figma `#000529`).
const kDagigaSwatchSelectedBorder = Color(0xFF000529);

/// Close (X) glyph size inside the 32px control (Figma 8).
const kDagigaColorCloseIconSize = 8.0;

/// Eyedropper glyph size inside the 32px control (Figma 14).
const kDagigaColorEyedropperIconSize = 14.0;

/// Package asset path for the rainbow color-entry ring.
const kDagigaColorRingAsset =
    'packages/pro_image_editor/lib/designs/dagiga/assets/dagiga_color_ring.png';

/// Color strip: close (X).
const kDagigaColorCloseAsset =
    'packages/pro_image_editor/lib/designs/dagiga/assets/dagiga_color_close.svg';

/// Color strip: eyedropper / pick color.
const kDagigaColorEyedropperAsset =
    'packages/pro_image_editor/lib/designs/dagiga/assets/dagiga_color_eyedropper.svg';

/// Text selection menu: bold.
const kDagigaMenuBoldAsset =
    'packages/pro_image_editor/lib/designs/dagiga/assets/dagiga_menu_bold.svg';

/// Text selection menu: italic.
const kDagigaMenuItalicAsset =
    'packages/pro_image_editor/lib/designs/dagiga/assets/dagiga_menu_italic.svg';

/// Text selection menu: underline.
const kDagigaMenuUnderlineAsset =
    'packages/pro_image_editor/lib/designs/dagiga/assets/dagiga_menu_underline.svg';

/// Text selection menu: duplicate.
const kDagigaMenuDuplicateAsset =
    'packages/pro_image_editor/lib/designs/dagiga/assets/dagiga_menu_duplicate.svg';

/// Text selection menu: delete.
const kDagigaMenuDeleteAsset =
    'packages/pro_image_editor/lib/designs/dagiga/assets/dagiga_menu_delete.svg';

/// Figma SVG for the Text tool.
const kDagigaToolTextIconAsset =
    'packages/pro_image_editor/lib/designs/dagiga/assets/dagiga_tool_text.svg';

/// Figma SVG for the Sticker tool.
const kDagigaToolStickerIconAsset =
    'packages/pro_image_editor/lib/designs/dagiga/assets/dagiga_tool_sticker.svg';

/// Figma SVG for the Paint / pen tool.
const kDagigaToolPenIconAsset =
    'packages/pro_image_editor/lib/designs/dagiga/assets/dagiga_tool_pen.svg';

/// Sticker sheet solid fill (Figma `6300:3570` `#000529`).
const kDagigaStickerSheetBackground = Color(0xFF000529);

/// Expanded sticker sheet height fraction (Figma `6300:3557`: 409/874).
const kDagigaStickerSheetExpandedSize = 409 / 874;

/// Collapsed sticker sheet height fraction (Figma `6351:10968`: 199/874).
const kDagigaStickerSheetCollapsedSize = 199 / 874;

/// Maximum sticker sheet height when dragged up (~85% of screen).
const kDagigaStickerSheetMaxSize = 0.85;

/// Drag handle on sticker sheet (44×5, white @ 32%).
const kDagigaStickerHandleColor = Color(0x52FFFFFF);
const kDagigaStickerHandleWidth = 44.0;
const kDagigaStickerHandleHeight = 5.0;

/// Search field corner radius (Figma pill 32).
const kDagigaStickerSearchRadius = 32.0;

/// Selected section chip fill (`#d3de00` @ 10%).
const kDagigaStickerChipSelectedFill = Color(0x1AD3DE00);

/// Idle section chip fill (`rgba(217,217,217,0.1)`).
const kDagigaStickerChipIdleFill = Color(0x1AD9D9D9);

/// Sticker grid cell size (Figma ~60).
const kDagigaStickerCellSize = 60.0;

/// Gap between sticker cells (Figma 16).
const kDagigaStickerGridGap = 16.0;

/// Upload CTA height (Figma 48).
const kDagigaStickerUploadHeight = 48.0;


/// Default text color swatches (Figma color strip).
const List<Color> selectionColors = [
  Color.fromRGBO(0, 0, 0, 1.0),
  Color.fromRGBO(0, 76, 179, 1.0),
  Color.fromRGBO(0, 154, 181, 1.0),
  Color.fromRGBO(0, 185, 255, 1.0),
  Color.fromRGBO(0, 195, 87, 1.0),
  Color.fromRGBO(0, 196, 227, 1.0),
  Color.fromRGBO(0, 229, 232, 1.0),
  Color.fromRGBO(27, 0, 180, 1.0),
  Color.fromRGBO(72, 113, 255, 1.0),
  Color.fromRGBO(84, 84, 84, 1.0),
  Color.fromRGBO(89, 220, 61, 1.0),
  Color.fromRGBO(103, 14, 245, 1.0),
  Color.fromRGBO(115, 115, 115, 1.0),
  Color.fromRGBO(149, 78, 255, 1.0),
  Color.fromRGBO(166, 166, 166, 1.0),
  Color.fromRGBO(174, 255, 87, 1.0),
  Color.fromRGBO(180, 180, 180, 1.0),
  Color.fromRGBO(216, 217, 217, 1.0),
  Color.fromRGBO(218, 101, 237, 1.0),
  Color.fromRGBO(235, 166, 246, 1.0),
  Color.fromRGBO(254, 255, 255, 1.0),
  Color.fromRGBO(255, 0, 28, 1.0),
  Color.fromRGBO(255, 68, 79, 1.0),
  Color.fromRGBO(255, 87, 200, 1.0),
  Color.fromRGBO(255, 106, 0, 1.0),
  Color.fromRGBO(255, 138, 56, 1.0),
  Color.fromRGBO(255, 186, 63, 1.0),
  Color.fromRGBO(255, 221, 51, 1.0),
];

/// Background color swatches — same palette plus transparent (no fill).
const List<Color> kDagigaBackgroundSwatches = [
  Colors.transparent,
  ...selectionColors, // Fixed: removed '+' prefix
];

const kDagigaDefaultSwatches = <Color>[
  ...selectionColors
];


