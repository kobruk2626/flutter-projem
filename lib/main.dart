import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_momento/core/services/firebase_service.dart';
import 'package:photo_momento/core/theme/app_theme.dart';
import 'package:photo_momento/presentation/providers/auth_provider.dart';
import 'package:photo_momento/presentation/providers/cart_provider.dart';
import 'package:photo_momento/presentation/providers/product_provider.dart';
import 'package:photo_momento/presentation/providers/order_provider.dart';
import 'package:photo_momento/domain/repositories/auth_repository.dart';
import 'package:photo_momento/data/repositories/auth_repository_impl.dart';
import 'package:photo_momento/domain/repositories/product_repository.dart';
import 'package:photo_momento/data/repositories/product_repository_impl.dart';
import 'package:photo_momento/domain/repositories/order_repository.dart';
import 'package:photo_momento/data/repositories/order_repository_impl.dart';
import 'package:photo_momento/presentation/routers/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await FirebaseService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            authRepository: AuthRepositoryImpl(),
          )..initialize(),
        ),

        // Cart Provider
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),

        // Product Provider
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => ProductProvider(
            productRepository: ProductRepositoryImpl(),
          ),
        ),

        // Order Provider
        ChangeNotifierProvider<OrderProvider>(
          create: (_) => OrderProvider(
            orderRepository: OrderRepositoryImpl(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Photo Momento',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
      ),
    );
  }
}