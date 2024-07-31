import 'package:flutter/material.dart';

ThemeData ligthmode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
      background: Color.fromARGB(255, 255, 255, 255),
      primary: Color.fromARGB(255, 153, 153, 153),
      secondary: Color.fromARGB(255, 224, 224, 224),
      secondaryContainer: Color.fromARGB(255, 241, 241, 241)),
  hintColor: Color.fromARGB(255, 15, 15, 15),
  appBarTheme: AppBarTheme(
    backgroundColor: const Color.fromARGB(255, 243, 243, 243), // สีของ AppBar
    foregroundColor: Colors.black, // สีของ Text ใน AppBar
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.black,
      backgroundColor: Color.fromARGB(255, 212, 212, 212),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color.fromARGB(255, 243, 238, 238),
    selectedItemColor: Color.fromARGB(255, 37, 37, 37),
    unselectedItemColor: Colors.grey.shade600,
    elevation: 8.0,
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark, // แก้เป็น Brightness.dark สำหรับโหมดมืด
  colorScheme: ColorScheme.dark(
      background: Color.fromARGB(255, 77, 77, 77),
      primary: Color.fromARGB(255, 241, 241, 241),
      secondary: Color.fromARGB(255, 59, 59, 59),
      secondaryContainer: Color.fromARGB(255, 255, 255, 255)),
  hintColor: Color.fromARGB(255, 10, 10, 10),
  appBarTheme: AppBarTheme(
    backgroundColor: Color.fromARGB(255, 66, 66, 66), // สีของ AppBar
    foregroundColor: Colors.white, // สีของข้อความใน AppBar
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: const Color.fromARGB(255, 61, 61, 61),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color.fromARGB(255, 66, 66, 66),
    selectedItemColor: Color.fromARGB(255, 241, 241, 241),
    unselectedItemColor: Colors.grey.shade400,
    elevation: 8.0,
  ),
);
