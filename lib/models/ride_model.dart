class RideModel {
  final String id;
  final String driverId;
  final String fromAddress;
  final double fromLat;
  final double fromLng;
  final String toAddress;
  final double toLat;
  final double toLng;
  final int totalSeats;
  final int availableSeats;
  final int coinPerSeat;
  final String timeType; // 'now', 'scheduled', 'recurring'
  final String? departTime;
  final String rideStatus; // 'posted', 'started', 'in_progress', 'completed'
  final double? matchScore;

  RideModel({
    required this.id,
    required this.driverId,
    required this.fromAddress,
    required this.fromLat,
    required this.fromLng,
    required this.toAddress,
    required this.toLat,
    required this.toLng,
    required this.totalSeats,
    required this.availableSeats,
    required this.coinPerSeat,
    required this.timeType,
    this.departTime,
    required this.rideStatus,
    this.matchScore,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id'] ?? '',
      driverId: json['driver_id'] ?? '',
      fromAddress: json['from_address'] ?? '',
      fromLat: (json['from_lat'] ?? 0.0).toDouble(),
      fromLng: (json['from_lng'] ?? 0.0).toDouble(),
      toAddress: json['to_address'] ?? '',
      toLat: (json['to_lat'] ?? 0.0).toDouble(),
      toLng: (json['to_lng'] ?? 0.0).toDouble(),
      totalSeats: json['total_seats'] ?? 3,
      availableSeats: json['available_seats'] ?? 3,
      coinPerSeat: json['coin_per_seat'] ?? 10,
      timeType: json['time_type'] ?? 'now',
      departTime: json['depart_time'],
      rideStatus: json['ride_status'] ?? 'posted',
      matchScore: json['_match_score'] != null ? (json['_match_score']).toDouble() : null,
    );
  }
}
