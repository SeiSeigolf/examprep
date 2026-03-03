import 'package:flutter/material.dart';
import 'shared/theme/app_theme.dart';
import 'shared/widgets/app_shell.dart';

class ExamOsApp extends StatelessWidget {
  const ExamOsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExamOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AppShell(),
    );
  }
}
