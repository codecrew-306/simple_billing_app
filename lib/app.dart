import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

class SimpleBillApp extends StatelessWidget {
  const SimpleBillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SimpleBill',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      getPages: AppRoutes.pages,
      debugShowCheckedModeBanner: false,
    );
  }
}
