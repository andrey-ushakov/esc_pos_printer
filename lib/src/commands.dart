/*
 * esc_pos_printer
 * Created by Andrey Ushakov
 * 
 * Copyright (c) 2019. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

const esc = '\x1B';
const gs = '\x1D';
const fs = '\x1C';

// Miscellaneous
const cInit = '$esc@'; // Initialize printer
const cBeep = '${esc}B'; // Beeper [count] [duration]

// Mech. Control
const cCutFull = '${gs}V0'; // Full cut
const cCutPart = '${gs}V1'; // Partial cut

// Character
const cReverseOn = '${gs}B1'; // Turn white/black reverse print mode on
const cReverseOff = '${gs}B0'; // Turn white/black reverse print mode off
const cSizeGSn = '$gs!'; // Select character size [N]
const cSizeESCn = '$esc!'; // Select character size [N]
const cUnderlineOff = '$esc-0'; // Turns off underline mode
const cUnderline1dot = '$esc-1'; // Turns on underline mode (1-dot thick)
const cUnderline2dots = '$esc-2'; // Turns on underline mode (2-dots thick)
const cBoldOn = '${esc}E1'; // Turn emphasized mode on
const cBoldOff = '${esc}E0'; // Turn emphasized mode off
const cFontA = '${esc}M0'; // Font A
const cFontB = '${esc}M1'; // Font B
const cTurn90On = '${esc}V1'; // Turn 90° clockwise rotation mode on
const cTurn90Off = '${esc}V0'; // Turn 90° clockwise rotation mode off
const cCodeTable = '${esc}t'; // Select character code table [N]
const cKanjiOn = '$fs&'; // Select Kanji character mode
const cKanjiOff = '$fs.'; // Cancel Kanji character mode

// Print Position
const cAlignLeft = '${esc}a0'; // Left justification
const cAlignCenter = '${esc}a1'; // Centered
const cAlignRight = '${esc}a2'; // Right justification
const cPos = '$esc\$'; // Set absolute print position [nL] [nH]

// Print
const cFeedN = '${esc}d'; // Print and feed n lines [N]
const cReverseFeedN = '${esc}e'; // Print and reverse feed n lines [N]

// Bit Image
const cRasterImg = '${gs}v0'; // Print raster bit image [obsolete command]
const cBitImg = '$esc*'; // Set bit image mode

// Barcode
const cBarcodeSelectPos =
    '${gs}H'; // Select print position of HRI characters [N]
const cBarcodeSelectFont = '${gs}f'; // Select font for HRI characters [N]
const cBarcodeSetH = '${gs}h'; // Set barcode height [N]
const cBarcodeSetW = '${gs}w'; // Set barcode width [N]
const cBarcodePrint = '${gs}k'; // Print barcode
