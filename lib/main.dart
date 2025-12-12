import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/customer/customer_home_screen.dart';
import 'screens/provider/provider_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'ServiceGO',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<void> _userDataFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the user data loading future once to avoid repeated calls
    // on every rebuild.
    final authProvider = context.read<AuthProvider>();
    _userDataFuture = authProvider.loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return StreamBuilder(
          stream: authProvider.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasData) {
              return FutureBuilder(
                future: _userDataFuture,
                builder: (context, userSnapshot) {
                  // Once the future completes (whether success or error),
                  // render the appropriate home screen based on the current
                  // authProvider.currentUser.userType. We don't wait for the
                  // future to finish before showing the screen; we show based
                  // on the current user model.
                  if (authProvider.currentUser?.userType == 'customer') {
                    return const CustomerHomeScreen();
                  } else if (authProvider.currentUser?.userType == 'provider') {
                    return const ProviderDashboardScreen();
                  }

                  // If userType is empty or null, still loading or user is
                  // not fully initialized. Show a brief loading screen.
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  return const WelcomeScreen();
                },
              );
            }

            return const WelcomeScreen();
          },
        );
      },
    );
  }
}
