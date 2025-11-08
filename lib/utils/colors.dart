import 'package:flutter/material.dart';

class AppColors {
  // Primary colors from original screens
  static const Color primaryBackground = Color.fromRGBO(
    230,
    221,
    192,
    1,
  ); // Light beige
  static const Color secondaryBackground = Color(0xFFF5EDE3); // Light coffee
  static const Color primaryButton = Color(0xFF8B5E3C); // Coffee brown
  static const Color secondaryButton = Color.fromARGB(
    255,
    188,
    118,
    93,
  ); // Darker coffee
  static const Color textPrimary = Color(0xFF8B5E3C); // Coffee brown for text
  static const Color textSecondary = Color.fromARGB(
    255,
    188,
    118,
    93,
  ); // Darker coffee for secondary text

  // Additional colors for consistency
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF424242);

  // Shadow and border colors
  static const Color shadowColor = Color.fromRGBO(0, 0, 0, 0.1);
  static const Color borderColor = Color.fromRGBO(230, 221, 192, 0.5);
}
