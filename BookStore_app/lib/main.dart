import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:GOSY/Page/EditProfile.dart';
import 'package:GOSY/Page/SignUpPage.dart';
import 'package:http/http.dart' as http;
import 'package:GOSY/AppConfig.dart';
import 'package:GOSY/Page/AccountPage.dart';
import 'package:GOSY/Page/CartPage.dart';
import 'package:GOSY/Page/HomePage.dart';
import 'package:GOSY/Page/PaymentResult.dart';
import 'package:GOSY/Page/welcomePage.dart';
import 'package:GOSY/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<dynamic> products = [];
  List<dynamic> categories = [];
  bool isLoading = false;
   bool isLoadingCate = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchCategories();
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/Products'));
      if (response.statusCode == 200) {
        setState(() {
          products = jsonDecode(response.body);
        });
        print('Products at home: ${response.body}');
      } else {
        print('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCategories() async {
    setState(() {
      isLoadingCate = true;
    });
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/Categories'));
      if (response.statusCode == 200) {
        setState(() {
          categories = jsonDecode(response.body);
        });
        print('Categories: ${response.body}');
      } else {
        print('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    } finally {
      setState(() {
        isLoadingCate = false;
      });
    }
  }

  late final GoRouter router = GoRouter(
    routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Homepage(products: products, categories: categories),
          ),
          GoRoute(
            path: '/cartPage',
            builder: (context, state) => Cartpage(products: products),
          ),
          GoRoute(
            path: '/paymentResult',
            builder: (context, state) => PaymentResult(products: products),
          ),
          GoRoute(
            path: '/welcomePage',
            builder: (context, state) => const WelcomePage(),
          ),
          GoRoute(
            path: '/account',
            builder: (context, state) => AccountWidget(products: products),
          ),
           GoRoute(
            path: '/profile',
            builder: (context, state) => ProfilePage(),
          ),
             GoRoute(
            path: '/signUp',
            builder: (context, state) => SignupPage(),
          ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    if (isLoading || isLoadingCate) {
      return MaterialApp(
        home: Scaffold(
          body: Container(
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: 'GOSY STORE',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
