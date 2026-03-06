import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../models/destination.dart';
import '../providers/trip_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/activity_tile.dart';

class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({super.key});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final Map<String, bool> _expandedDestinations = {};

  @override
  Widget build(BuildContext context) {
    final tripId = ModalRoute.of(context)!.settings.arguments as String;

    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        final trip = tripProvider.getTripById(tripId);

        if (trip == null) {
          return Scaffold(
            body: GradientBackground(
              child: Center(
                child: Text(
                  'Trip not found',
                  style: TextStyle(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: GradientBackground(
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(context, trip)),
                  SliverToBoxAdapter(child: _buildProgressSection(trip)),
                  SliverToBoxAdapter(
                    child: _buildDestinationsHeader(context, trip),
                  ),
                  if (trip.destinations.isEmpty)
                    SliverToBoxAdapter(child: _buildEmptyDestinations())
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final destination = trip.destinations[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          child: _buildDestinationCard(
                            context,
                            trip.id,
                            destination,
                          ),
                        );
                      }, childCount: trip.destinations.length),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
          floatingActionButton: _buildFAB(context, trip.id),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Trip trip) {
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    CupertinoIcons.back,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
              ),
              const Spacer(),
              Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  return IconButton(
                    onPressed: () => settings.toggleTheme(),
                    icon: Icon(
                      settings.isDarkMode
                          ? CupertinoIcons.sun_max
                          : CupertinoIcons.moon,
                      size: 24,
                      color: AppTheme.getTextPrimaryColor(context),
                    ),
                  );
                },
              ),
              PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    CupertinoIcons.ellipsis,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.pushNamed(
                      context,
                      '/edit-trip',
                      arguments: trip.id,
                    );
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(context, trip.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.pencil, size: 20),
                        SizedBox(width: 12),
                        Text('Edit Trip'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.trash, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text(
                          'Delete Trip',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Hero(
            tag: 'trip_${trip.id}',
            child: Material(
              color: Colors.transparent,
              child: Text(
                trip.name,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                CupertinoIcons.calendar,
                size: 18,
                color: AppTheme.primaryTeal,
              ),
              const SizedBox(width: 8),
              Text(
                '${dateFormat.format(trip.startDate)} - ${dateFormat.format(trip.endDate)}',
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.getTextSecondaryColor(
                    context,
                  ).withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          if (trip.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              trip.description,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.getTextSecondaryColor(
                  context,
                ).withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressSection(Trip trip) {
    final percent = (trip.completionPercentage * 100).toInt();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            'Completion',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: trip.completionPercentage,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.lerp(
                  AppTheme.primaryBlue,
                  AppTheme.primaryTeal,
                  trip.completionPercentage,
                )!,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$percent%',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.getTextSecondaryColor(context).withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationsHeader(BuildContext context, Trip trip) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(top: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Destinations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.plus),
            color: AppTheme.primaryBlue,
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/add-destination',
                arguments: trip.id,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDestinations() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Text(
          'No destinations yet. Tap the + button to add one!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.getTextSecondaryColor(context),
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationCard(
    BuildContext context,
    String tripId,
    Destination dest,
  ) {
    final expanded = _expandedDestinations[dest.id] ?? false;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  dest.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  expanded
                      ? CupertinoIcons.chevron_up
                      : CupertinoIcons.chevron_down,
                ),
                onPressed: () {
                  setState(() {
                    _expandedDestinations[dest.id] = !expanded;
                  });
                },
              ),
            ],
          ),
          if (expanded) ...[
            const SizedBox(height: 12),
            ...dest.activities.map(
              (a) => ActivityTile(
                activity: a,
                onToggle: () {
                  Provider.of<TripProvider>(
                    context,
                    listen: false,
                  ).toggleActivityCompletion(
                    tripId: tripId,
                    destinationId: dest.id,
                    activityId: a.id,
                  );
                },
                onDelete: () {
                  Provider.of<TripProvider>(
                    context,
                    listen: false,
                  ).deleteActivity(
                    tripId: tripId,
                    destinationId: dest.id,
                    activityId: a.id,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/add-activity',
                    arguments: {'tripId': tripId, 'destinationId': dest.id},
                  );
                },
                child: const Text('Add activity'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context, String tripId) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, '/add-destination', arguments: tripId);
      },
      child: const Icon(CupertinoIcons.plus),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String tripId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete trip?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<TripProvider>(
                context,
                listen: false,
              ).deleteTrip(tripId);
              Navigator.popUntil(ctx, ModalRoute.withName('/'));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
