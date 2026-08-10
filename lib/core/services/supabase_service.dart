import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/app_config.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    _isInitialized = true;
  }

  SupabaseClient get client => Supabase.instance.client;

  // Realtime subscription to live driver location changes
  RealtimeChannel subscribeToDriverLocation(String rideId, Function(Map<String, dynamic>) onLocationUpdate) {
    final channelName = 'driver_location_$rideId';
    return client
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'driver_locations',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'ride_id',
            value: rideId,
          ),
          callback: (payload) {
            if (payload.newRecord.isNotEmpty) {
              onLocationUpdate(payload.newRecord);
            }
          },
        )
        .subscribe();
  }
}
