import 'package:flutter/material.dart';

/// Palet pastel. Nama lama (ink, inkSoft, peach, pink, lemon) dipertahankan
/// supaya kode lain yang masih memakainya tidak rusak.
class AppColors {
  AppColors._();

  // Teks
  static const ink = Color(0xFF2B2A33);
  static const inkSoft = Color(0xFF7C7A88);

  // Dasar
  static const cream = Color(0xFFFFFBF7);

  // Pastel
  static const peach = Color(0xFFFFE4D6);
  static const pink = Color(0xFFFFC9DE);
  static const lemon = Color(0xFFFFF4BF);
  static const mint = Color(0xFFCFF1E2);
  static const lavender = Color(0xFFE0D8FF);
  static const sky = Color(0xFFD3EAFF);
  static const rose = Color(0xFFFFD9DC);

  // Aksen yang lebih tegas (spinner, fokus, hapus, bintang)
  static const pinkDeep = Color(0xFFFF8FB8);
  static const danger = Color(0xFFC2415A);
  static const star = Color(0xFFF0A93B);

  static const _tints = [peach, mint, lavender, sky, lemon, pink];

  /// Warna pastel bergilir, dipakai untuk latar gambar produk.
  static Color tint(int i) => _tints[i % _tints.length];
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get soft => [
        BoxShadow(
          color: AppColors.ink.withValues(alpha: 0.06),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];
}

/// "kategori-produk" -> "Kategori Produk"
String prettyLabel(String s) => s
    .split(RegExp(r'[-_ ]'))
    .where((w) => w.isNotEmpty)
    .map((w) => w[0].toUpperCase() + w.substring(1))
    .join(' ');

/// Latar gradasi lembut. Bungkus Scaffold (dengan backgroundColor transparan)
/// di dalamnya.
class AppBackdrop extends StatelessWidget {
  final Widget child;
  const AppBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF0E8), AppColors.cream, Color(0xFFF5F1FF)],
            ),
          ),
        ),
        Positioned(top: -90, right: -70, child: _blob(AppColors.pink, 260)),
        Positioned(bottom: -80, left: -70, child: _blob(AppColors.sky, 240)),
        child,
      ],
    );
  }

  Widget _blob(Color c, double size) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [c.withValues(alpha: 0.55), c.withValues(alpha: 0)],
            ),
          ),
        ),
      );
}

class AppTheme {
  AppTheme._();

  /// Alias supaya cocok dengan nama yang mungkin dipakai di main.dart.
  static ThemeData get theme => light;

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.pink,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.ink,
      onPrimary: Colors.white,
      secondary: AppColors.pink,
      onSecondary: AppColors.ink,
      surface: AppColors.cream,
      onSurface: AppColors.ink,
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);

    OutlineInputBorder border(Color c, [double w = 0]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: w == 0
              ? BorderSide.none
              : BorderSide(color: c, width: w),
        );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.cream,
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.ink,
        titleTextStyle: TextStyle(
          color: AppColors.ink,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: const TextStyle(color: AppColors.inkSoft),
        prefixIconColor: AppColors.inkSoft,
        suffixIconColor: AppColors.inkSoft,
        border: border(Colors.transparent),
        enabledBorder: border(Colors.transparent),
        focusedBorder: border(AppColors.pinkDeep, 1.5),
        errorBorder: border(AppColors.danger, 1),
        focusedErrorBorder: border(AppColors.danger, 1.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.ink.withValues(alpha: 0.7),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: const TextStyle(
          color: AppColors.ink,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: AppColors.pinkDeep),
    );
  }
}