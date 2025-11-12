// main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import '../event/event_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Event Manager Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // --- Thêm cấu hình Localization cho Syncfusion Calendar ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        // Delegate của Syncfusion để hiển thị ngôn ngữ Việt
        SfGlobalLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('vi', ''), // Vietnamese
      ],
      // Đặt ngôn ngữ mặc định là Tiếng Việt
      locale: const Locale('vi'),
      // ------------------------------------------------------------
      home: const EventView(),
    );
  }
}
