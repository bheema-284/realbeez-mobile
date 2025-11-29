class BookingModel {
  final String id;
  final String bookingId;
  final String vehicleType;
  final String carModel;
  final int passengerCount;
  final String bookingDate;
  final String bookingTime;
  final String pickupLocation;
  final String dropLocation;
  final String status;
  final RescheduleInfo reschedule;
  final CancelInfo cancel;

  BookingModel({
    required this.id,
    required this.bookingId,
    required this.vehicleType,
    required this.carModel,
    required this.passengerCount,
    required this.bookingDate,
    required this.bookingTime,
    required this.pickupLocation,
    required this.dropLocation,
    required this.status,
    required this.reschedule,
    required this.cancel,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'] ?? '',
      bookingId: json['booking_id'] ?? '',
      vehicleType: json['vehicle_type'] ?? '',
      carModel: json['car_model'] ?? '',
      passengerCount: json['passenger_count'] ?? 0,
      bookingDate: json['booking_date'] ?? '',
      bookingTime: json['booking_time'] ?? '',
      pickupLocation: json['pickup_location'] ?? '',
      dropLocation: json['drop_location'] ?? '',
      status: json['status'] ?? 'booked',
      reschedule: RescheduleInfo.fromJson(json['reschedule'] ?? {}),
      cancel: CancelInfo.fromJson(json['cancel'] ?? {}),
    );
  }
}

class RescheduleInfo {
  final bool isRescheduled;
  final String reason;
  final String? newBookingDate;
  final String? newBookingTime;

  RescheduleInfo({
    required this.isRescheduled,
    required this.reason,
    this.newBookingDate,
    this.newBookingTime,
  });

  factory RescheduleInfo.fromJson(Map<String, dynamic> json) {
    return RescheduleInfo(
      isRescheduled: json['isRescheduled'] ?? false,
      reason: json['reason'] ?? '',
      newBookingDate: json['new_booking_date'],
      newBookingTime: json['new_booking_time'],
    );
  }
}

class CancelInfo {
  final bool isCancelled;
  final String reason;

  CancelInfo({
    required this.isCancelled,
    required this.reason,
  });

  factory CancelInfo.fromJson(Map<String, dynamic> json) {
    return CancelInfo(
      isCancelled: json['isCancelled'] ?? false,
      reason: json['reason'] ?? '',
    );
  }
}