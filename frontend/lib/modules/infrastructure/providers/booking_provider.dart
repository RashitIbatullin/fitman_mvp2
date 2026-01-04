import 'package:fitman_app/modules/infrastructure/models/booking/equipment_booking.model.dart';
import 'package:fitman_app/modules/infrastructure/services/booking_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookingServiceProvider = Provider<BookingService>((ref) {
  return BookingService();
});

final allBookingsProvider = FutureProvider<List<EquipmentBooking>>((ref) {
  final bookingService = ref.watch(bookingServiceProvider);
  return bookingService.getAllBookings();
});
