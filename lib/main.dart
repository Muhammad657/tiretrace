import 'package:flutter/material.dart';
import 'package:tiretrace/HomeScreen.dart';
import 'package:tiretrace/HotpotScreen.dart';
import 'package:tiretrace/SearchScreen.dart';
import 'package:tiretrace/ImpactScreen.dart';
import 'package:tiretrace/LoadingScreen.dart';
import 'package:tiretrace/MapScreen.dart';
import 'package:tiretrace/PetitionScreen.dart';
import 'package:tiretrace/TireGuide.dart';
import 'package:tiretrace/fakeData.dart';

void main() {
  runApp(const TireTraceApp());
}

class TireTraceApp extends StatelessWidget {
  const TireTraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TireTrace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A6BB5)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/search':
            return MaterialPageRoute(builder: (_) => const SearchScreen());
          case '/impact':
            final location = settings.arguments as Location;
            return MaterialPageRoute(
                builder: (_) => ImpactScreen(location: location));
          case '/loading':
            final location = settings.arguments as Location;
            return MaterialPageRoute(
                builder: (_) => LoadingScreen(location: location));
          case '/map':
            final location = settings.arguments as Location;
            return MaterialPageRoute(
                builder: (_) => MapScreen(location: location));
          case '/hotspots':
            return MaterialPageRoute(builder: (_) => const HotspotScreen());
          case '/tires':
            return MaterialPageRoute(builder: (_) => const TireGuideScreen());
          case '/petition':
            return MaterialPageRoute(builder: (_) => const PetitionScreen());
          default:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
      },
    );
  }
}
