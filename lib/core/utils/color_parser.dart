import 'package:flutter/material.dart';

/// Parses `#RRGGBB` hex strings stored in Supabase into [Color].
Color? tryParseColor(String? hex) {
  if (hex == null) return null;
  final value = hex.replaceFirst('#', '');
  if (value.length != 6) return null;
  final parsed = int.tryParse('FF$value', radix: 16);
  return parsed == null ? null : Color(parsed);
}
