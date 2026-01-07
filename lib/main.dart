// import 'package:flutter/material.dart';
// import 'package:personal_expense_tracker/register_page.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'login_page.dart';
// import 'home_page.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await Supabase.initialize(
//     url: 'https://rjvqmggtcrkosgswgdsp.supabase.co',
//     anonKey: 'sb_publishable_XKHV0X8vSm9Rv4nOzg8nkA_ukvRuAar',
//   );
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Expense Tracker',
//       home: Supabase.instance.client.auth.currentUser == null
//           ? const LoginPage()
//           : const HomePage(),
//
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'splash_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rjvqmggtcrkosgswgdsp.supabase.co',
    anonKey: 'sb_publishable_XKHV0X8vSm9Rv4nOzg8nkA_ukvRuAar',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      home: const SplashScreen(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = supabase.auth.currentSession;

        if (session != null) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}


