const esc = '\x1B';
const gs = '\x1D';

// Miscellaneous
const cInit = '$esc@'; // Initialize printer
const cBeep = '${esc}B'; // Beeper [count] [duration]

// Mech. Control
const cCut = '${gs}V0'; // Cut paper
const cCutFull = '${esc}i'; // Execute paper full cut
const cCutPart = '${esc}m'; // Execute paper partial cut.

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

// Print Position
const cAlignLeft = '${esc}a0'; // Left justification
const cAlignCenter = '${esc}a1'; // Centered
const cAlignRight = '${esc}a2'; // Right justification

// Print
const cFeedN = '${esc}d'; // Print and feed n lines [N]
const cReverseFeedN = '${esc}e'; // Print and reverse feed n lines [N]
