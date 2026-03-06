import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/trip_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'screens/trip_details_screen.dart';
import 'screens/add_edit_trip_screen.dart';
import 'screens/add_edit_destination_screen.dart';
import 'screens/add_edit_activity_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const TravelMateApp());
}

class TravelMateApp extends StatelessWidget {
  const TravelMateApp({super.key});

  Route<dynamic>? _onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case '/':
        return _buildPageRoute(const HomeScreen(), routeSettings);
      case '/trip-details':
        return _buildPageRoute(const TripDetailsScreen(), routeSettings);
      case '/add-trip':
        return _buildPageRoute(const AddEditTripScreen(), routeSettings);
      case '/edit-trip':
        return _buildPageRoute(
          const AddEditTripScreen(isEditing: true),
          routeSettings,
        );
      case '/add-destination':
        return _buildPageRoute(const AddEditDestinationScreen(), routeSettings);
      case '/edit-destination':
        return _buildPageRoute(
          const AddEditDestinationScreen(isEditing: true),
          routeSettings,
        );
      case '/add-activity':
        return _buildPageRoute(const AddEditActivityScreen(), routeSettings);
      case '/edit-activity':
        return _buildPageRoute(
          const AddEditActivityScreen(isEditing: true),
          routeSettings,
        );
      default:
        return _buildPageRoute(const HomeScreen(), routeSettings);
    }
  }

  PageRoute<dynamic> _buildPageRoute(Widget page, RouteSettings settings) {
    return CupertinoPageRoute(settings: settings, builder: (context) => page);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TripProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'TravelMate',
            debugShowCheckedModeBanner: false,
            theme: settings.isDarkMode
                ? AppTheme.darkTheme
                : AppTheme.lightTheme,
            initialRoute: '/',
            onGenerateRoute: _onGenerateRoute,
          );
        },
      ),
    );
  } // End of TravelMateApp
}
