// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'repositories/auth_repository.dart';
import 'repositories/product_repository.dart';

// BLoC imports
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/product/product_bloc.dart';

import 'ui/screens/login_screen.dart';
import 'ui/screens/products_screen.dart';
import 'utils/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = AuthRepository();
    final productRepo = ProductRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepo),
        RepositoryProvider.value(value: productRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AuthBloc(authRepository: authRepo)
              ..add(AuthCheckRequested()), // <--- AuthCheckRequested is defined in auth_event.dart
          ),
          BlocProvider(
            create: (_) => ProductBloc(productRepository: productRepo),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Machine Test App',
          theme: AppTheme.lightTheme,
          home: const RootPage(),
        ),
      ),
    );
  }
}

class RootPage extends StatelessWidget {
  const RootPage({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Authenticated & Unauthenticated are defined in auth_state.dart
        if (state is Authenticated) {
          return const ProductsScreen();
        } else if (state is AuthInitial) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else {
          // Unauthenticated, AuthLoading, or AuthFailure -> Show LoginScreen
          // LoginScreen handles the loading state (AuthLoading) internally on the button.
          // LoginScreen handles AuthFailure via SnackBar.
          return const LoginScreen();
        }
      },
    );
  }
}
