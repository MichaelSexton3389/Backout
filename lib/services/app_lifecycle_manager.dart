import 'package:flutter/material.dart';

class AppLifecycleManager extends StatefulWidget {
  final Widget child;
  
  const AppLifecycleManager({
    Key? key,
    required this.child,
  }) : super(key: key);
  
  @override
  AppLifecycleManagerState createState() => AppLifecycleManagerState();
}

class AppLifecycleManagerState extends State<AppLifecycleManager> with WidgetsBindingObserver {
  static bool isAppInForeground = true;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    isAppInForeground = state == AppLifecycleState.resumed;
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}