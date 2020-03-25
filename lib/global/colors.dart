import 'package:flutter/material.dart';

const PRIMARY = 0xff34C7B5;
const ACCENT = 0xff4476CC;
const PRIMARY_DARK = 0xff121212;
const ENABLED_GREY = 0xffFAFAFA;
const DISABLED_GREY = 0xffD8D8D8;
const GREY_DARK = 0xff4D5767;
const BACKGROUND = 0xffFEFEFE;

const PRIMARY_COLOR = const Color(PRIMARY);
const ACCENT_COLOR = const Color(ACCENT);
const PRIMRARY_DARK_COLOR = const Color(PRIMARY_DARK);
const ENABLED_GREY_COLOR = const Color(ENABLED_GREY);
const DISABLED_GREY_COLOR = const Color(DISABLED_GREY);
const BACKGROUND_COLOR = const Color(BACKGROUND);
const GREY_DARK_COLOR = const Color(GREY_DARK);

const DEFAULT_RED = 0xffc96480;
const DEFAULT_ORANGE = 0xffb47978;
const DEFAULT_YELLOW = 0xffb1ae91;
const DEFAULT_GREEN = 0xff95bf8f;
const DEFAULT_SEA_FOAM = 0xff99d17b;
const DEFAULT_BLUE = 0xff20639b;

const SENDER_COLORS = [
  Color(DEFAULT_RED),
  Color(DEFAULT_ORANGE),
  Color(DEFAULT_YELLOW),
  Color(DEFAULT_GREEN),
  Color(DEFAULT_SEA_FOAM),
  Color(DEFAULT_BLUE),
];

Color hashedColor(String hashable) {
  int hash = hashable.codeUnits.reduce((value, element) => value + element);
  return SENDER_COLORS[hash % SENDER_COLORS.length];
}
