import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'model/rive_assets.dart';

const double defaultPadding = 16;
final navigatorKey = GlobalKey<NavigatorState>();
final cacheOptions = CacheOptions(
  policy: CachePolicy.refresh,
  store: MemCacheStore(),
  hitCacheOnErrorExcept: [401, 403],
  maxStale: const Duration(hours: 6),
  priority: CachePriority.high,
);
final List<RiveAsset> bottomNavigators = [
  RiveAsset("assets/RiveAssets/icons.riv",
      artboard: "HOME", stateMachineName: "HOME_interactivity", title: "Home"),
  RiveAsset("assets/RiveAssets/icons.riv",
      artboard: "SEARCH", stateMachineName: "SEARCH_Interactivity", title: "Search"),
  RiveAsset("assets/RiveAssets/icons.riv",
      artboard: "LIBRARY", stateMachineName: "LIBRARY_Interactivity", title: "Library"),
  RiveAsset("assets/RiveAssets/icons.riv",
      artboard: "SETTINGS", stateMachineName: "SETTINGS_Interactivity", title: "Account"),
];
final cycleBin = RiveAsset("assets/RiveAssets/icons.riv",
    artboard: "DELETE", stateMachineName: "DELETE_Interactivity", title: "delete all");

final refresh = RiveAsset("assets/RiveAssets/icons.riv",
    artboard: "REFRESH/RELOAD", stateMachineName: "REFRESH/RELOAD_Interactivity", title: "update");

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  appBarTheme: const AppBarTheme(
    elevation: 5,
    centerTitle: true,
    titleTextStyle: TextStyle(color: Color(0xff0D0D0D), fontSize: 28),
  ),
  navigationBarTheme: NavigationBarThemeData(
    elevation: 5,
    backgroundColor: Colors.black54,
    labelTextStyle:
        MaterialStateProperty.all(const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: const Color(0xffF78C25),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 20,
    contentTextStyle: GoogleFonts.robotoCondensed(fontSize: 28),
  ),
  colorScheme: const ColorScheme.light(
    background: Color(0xfff6f5f5),
    primary: Color(0xffF78C25),
    secondary: Color(0xff9f5023),
    tertiary: Color(0xffF78C25),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xffF78C25),
      alignment: Alignment.center,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      disabledBackgroundColor: const Color(0x33f6f5f5),
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  appBarTheme: const AppBarTheme(
    elevation: 5,
    color: Color(0xff0f0f0f),
    centerTitle: true,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 28),
  ),
  navigationBarTheme: NavigationBarThemeData(
    elevation: 5,
    backgroundColor: const Color(0xff0f0f0f),
    labelTextStyle:
        MaterialStateProperty.all(const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: const Color(0xff005B41),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 20,
    contentTextStyle: GoogleFonts.robotoCondensed(fontSize: 28),
  ),
  colorScheme: const ColorScheme.dark(
    background: Color(0xff0f0f0f),
    primary: Color(0xff005B41),
    secondary: Color(0xff232D3F),
    tertiary: Color(0xff008170),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xff005B41),
      alignment: Alignment.center,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      disabledBackgroundColor: const Color(0xff232D3F),
    ),
  ),
);
