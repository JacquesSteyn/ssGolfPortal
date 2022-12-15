import 'package:flutter/material.dart';
import 'package:smartgolfportal/widgets/navigation.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NavigationWidget(
            activePage: "Dashboard", child: const Text("test")));
  }
}
