import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartgolfportal/screens/login_screen.dart';
import 'package:smartgolfportal/screens/user_screen.dart';
import 'package:smartgolfportal/services/auth_service.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "SmartGolfPortal",
      theme: ThemeData(
          primaryColor: Colors.black,
          colorScheme:
              ColorScheme.fromSwatch(accentColor: Colors.blue.shade800),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(primary: Colors.blue.shade800))),
      home: const AuthWidget(),
      routes: AppRoutes.routes,
    );
  }
}

class AuthWidget extends ConsumerWidget {
  const AuthWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateChanges = ref.watch(authStateChangesProvider);

    return authStateChanges.when(
      data: (User? user) => _data(context, ref, user),
      loading: () => loadingScaffold(),
      error: (_, __) => const Center(child: Text('TODO ERROR PAGE')),
    );
  }

  Widget _data(BuildContext context, WidgetRef ref, User? user) {
    //print('BUILD DATA AUTH STATE CHANGES: ' + user.toString());
    if (user != null) {
      // Authenticated
      ref.read(userStateProvider.notifier).initUser(user);
      return const UserScreen();
    }
    // Not authenticated
    return const LoginScreen();
  }

  Widget loadingScaffold() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
