import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itech/providers/get_myArticle_manager.dart';
import 'package:itech/providers/chat/notifications_socket.dart';
import 'package:itech/providers/notifications/notifications_socket_group.dart';
import 'package:itech/providers/user/profile_socket_manager.dart';
import 'package:itech/providers/temporal_behavior.dart';
import 'package:itech/widgets/authCheck/auth_check.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileSocketManager()),
        ChangeNotifierProvider(create: (_) => TemporalBehaviorProvider()),
        ChangeNotifierProvider(create: (_) => GetMyArticleManager()),
        ChangeNotifierProvider(
          create: (_) => NotificationsProvider(),
          lazy: false, // اتصال فوری وب‌سوکت
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationsGroupProvider(),
          lazy: false, // اتصال فوری وب‌سوکت
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// کلاس ThemeProvider برای مدیریت تم
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class NavBarItemColors extends ThemeExtension<NavBarItemColors> {
  final Color? navBarItemColor;

  const NavBarItemColors({this.navBarItemColor});

  @override
  NavBarItemColors copyWith({Color? navBarItemColor}) {
    return NavBarItemColors(
      navBarItemColor: navBarItemColor ?? this.navBarItemColor,
    );
  }

  @override
  NavBarItemColors lerp(ThemeExtension<NavBarItemColors>? other, double t) {
    if (other is! NavBarItemColors) return this;
    return NavBarItemColors(
      navBarItemColor: Color.lerp(navBarItemColor, other.navBarItemColor, t),
    );
  }
}

class CategoryBorderColors extends ThemeExtension<CategoryBorderColors> {
  final Color? categoryBorderColor;

  const CategoryBorderColors({this.categoryBorderColor});

  @override
  CategoryBorderColors copyWith({Color? categoryBorderColor}) {
    return CategoryBorderColors(
      categoryBorderColor: categoryBorderColor ?? this.categoryBorderColor,
    );
  }

  @override
  CategoryBorderColors lerp(
    ThemeExtension<CategoryBorderColors>? other,
    double t,
  ) {
    if (other is! CategoryBorderColors) return this;
    return CategoryBorderColors(
      categoryBorderColor: Color.lerp(
        categoryBorderColor,
        other.categoryBorderColor,
        t,
      ),
    );
  }
}

class IconColors extends ThemeExtension<IconColors> {
  final Color? iconColor;

  const IconColors({this.iconColor});

  @override
  IconColors copyWith({Color? iconColor}) {
    return IconColors(iconColor: iconColor ?? this.iconColor);
  }

  @override
  IconColors lerp(ThemeExtension<IconColors>? other, double t) {
    if (other is! IconColors) return this;
    return IconColors(iconColor: Color.lerp(iconColor, other.iconColor, t));
  }
}

class EditeProfileColors extends ThemeExtension<EditeProfileColors> {
  final Color? editeProfileColor;

  const EditeProfileColors({this.editeProfileColor});

  @override
  EditeProfileColors copyWith({Color? editeProfileColor}) {
    return EditeProfileColors(
      editeProfileColor: editeProfileColor ?? this.editeProfileColor,
    );
  }

  @override
  EditeProfileColors lerp(ThemeExtension<EditeProfileColors>? other, double t) {
    if (other is! EditeProfileColors) return this;
    return EditeProfileColors(
      editeProfileColor: Color.lerp(
        editeProfileColor,
        other.editeProfileColor,
        t,
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'iTech',
      // 🎨 Light Theme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3E48DF),
          background: Colors.white,
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        extensions: const [
          NavBarItemColors(navBarItemColor: Color.fromARGB(255, 160, 160, 160)),
          CategoryBorderColors(
            categoryBorderColor: Color.fromARGB(255, 200, 200, 200),
          ),
          IconColors(iconColor: Color.fromARGB(255, 0, 0, 0)),
          EditeProfileColors(editeProfileColor: Color(0xFFEEEEEE)),
        ],
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: const Color(0xFF3E48DF),
          selectionHandleColor: const Color(0xFF3E48DF),
          selectionColor: const Color(0xFF3E48DF).withOpacity(0.2),
        ),
      ),
      // 🌑 Dark Theme
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3E48DF),
          background: Colors.black,
          surface: const Color(0xFF121212),
          brightness: Brightness.dark,
        ),
        extensions: const [
          NavBarItemColors(navBarItemColor: Color.fromARGB(255, 159, 159, 159)),
          CategoryBorderColors(
            categoryBorderColor: Color.fromARGB(255, 62, 62, 62),
          ),
          IconColors(iconColor: Color.fromARGB(255, 255, 255, 255)),
          EditeProfileColors(
            editeProfileColor: Color.fromARGB(255, 20, 20, 20),
          ),
        ],
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: const Color(0xFF3E48DF),
          selectionHandleColor: const Color(0xFF3E48DF),
          selectionColor: const Color(0xFF3E48DF).withOpacity(0.3),
        ),
      ),
      themeMode: themeProvider.themeMode,
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(
            context,
          ).copyWith(overscroll: false, physics: const ClampingScrollPhysics()),
          child: child!,
        );
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US'), Locale('fa', 'IR')],
      home: const AuthCheckPage(),
    );
  }
}
