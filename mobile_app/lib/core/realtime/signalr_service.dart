import 'dart:async';
import 'package:signalr_core/signalr_core.dart';
import '../constants/api_endpoints.dart';
import '../network/dio_client.dart';

class LocationUpdateEvent {
  final int bookingId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  LocationUpdateEvent({
    required this.bookingId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });
}

class BookingStatusEvent {
  final int bookingId;
  final String status;
  final DateTime timestamp;

  BookingStatusEvent({
    required this.bookingId,
    required this.status,
    required this.timestamp,
  });
}

class SignalRService {
  final DioClient dioClient;
  final String hubUrl;
  HubConnection? _hubConnection;

  // Stream controllers for real-time telemetry
  final _locationStreamController = StreamController<LocationUpdateEvent>.broadcast();
  final _bookingStatusStreamController = StreamController<BookingStatusEvent>.broadcast();
  final _incomingJobStreamController = StreamController<Map<String, dynamic>>.broadcast();
  final _partsApprovalStreamController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<LocationUpdateEvent> get onLocationUpdate => _locationStreamController.stream;
  Stream<BookingStatusEvent> get onBookingStatusChanged => _bookingStatusStreamController.stream;
  Stream<Map<String, dynamic>> get onIncomingJob => _incomingJobStreamController.stream;
  Stream<Map<String, dynamic>> get onPartUpdate => _partsApprovalStreamController.stream;

  SignalRService({
    required this.dioClient,
    String? customHubUrl,
  }) : hubUrl = customHubUrl ??
            '${ApiEndpoints.defaultBaseUrl}${ApiEndpoints.signalRBookingHub}';

  Future<void> connect() async {
    if (_hubConnection != null &&
        _hubConnection!.state == HubConnectionState.connected) {
      return;
    }

    // BUG-012 FIX: Use a live factory closure instead of capturing a stale token snapshot.
    // The factory is called on each reconnect, ensuring refreshed tokens are always used.
    _hubConnection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          HttpConnectionOptions(
            accessTokenFactory: () => dioClient.getAccessToken().then((t) => t ?? ''),
            transport: HttpTransportType.webSockets,
          ),
        )
        .withAutomaticReconnect()
        .build();

    // Register event listeners
    void handleLocation(arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        int bookingId = 0;
        double lat = 0.0;
        double lng = 0.0;
        if (arguments[0] is Map) {
          final map = arguments[0] as Map;
          bookingId = int.tryParse(map['bookingId']?.toString() ?? '0') ?? 0;
          lat = (map['latitude'] as num?)?.toDouble() ?? 0.0;
          lng = (map['longitude'] as num?)?.toDouble() ?? 0.0;
        } else if (arguments.length >= 3) {
          bookingId = arguments[0] is int ? arguments[0] as int : int.tryParse(arguments[0].toString()) ?? 0;
          lat = (arguments[1] as num).toDouble();
          lng = (arguments[2] as num).toDouble();
        }
        _locationStreamController.add(
          LocationUpdateEvent(
            bookingId: bookingId,
            latitude: lat,
            longitude: lng,
            timestamp: DateTime.now(),
          ),
        );
      }
    }

    void handleStatus(arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        int bookingId = 0;
        String status = '';
        if (arguments[0] is Map) {
          final map = arguments[0] as Map;
          bookingId = int.tryParse(map['bookingId']?.toString() ?? '0') ?? 0;
          status = map['status']?.toString() ?? '';
        } else if (arguments.length >= 2) {
          bookingId = arguments[0] is int ? arguments[0] as int : int.tryParse(arguments[0].toString()) ?? 0;
          status = arguments[1].toString();
        }
        _bookingStatusStreamController.add(
          BookingStatusEvent(
            bookingId: bookingId,
            status: status,
            timestamp: DateTime.now(),
          ),
        );
      }
    }

    _hubConnection!.on('ProviderLocationUpdated', handleLocation);
    _hubConnection!.on('OnLocationUpdated', handleLocation);

    _hubConnection!.on('BookingStatusChanged', handleStatus);
    _hubConnection!.on('OnStatusChanged', handleStatus);

    _hubConnection!.on('DirectRequestReceived', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        _incomingJobStreamController.add({
          'type': 'DirectRequest',
          'payload': arguments[0],
        });
      }
    });

    _hubConnection!.on('OnNewBookingRequest', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        _incomingJobStreamController.add({
          'type': 'NewBooking',
          'payload': arguments[0],
        });
      }
    });

    void handlePart(arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        _partsApprovalStreamController.add({
          'type': 'PartAdded',
          'payload': arguments[0],
        });
      }
    }

    _hubConnection!.on('PartAdded', handlePart);
    _hubConnection!.on('OnPartAdded', handlePart);

    _hubConnection!.on('PartDecided', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        _partsApprovalStreamController.add({
          'type': 'PartDecided',
          'payload': arguments[0],
        });
      }
    });

    try {
      await _hubConnection!.start();
    } catch (_) {
      // Graceful fallback for offline / mock testing
    }
  }

  // Group Membership Management
  Future<void> joinBookingGroup(int bookingId) async {
    if (_hubConnection != null &&
        _hubConnection!.state == HubConnectionState.connected) {
      try {
        await _hubConnection!.invoke('JoinBookingGroup', args: [bookingId.toString()]);
      } catch (_) {}
    }
  }

  Future<void> leaveBookingGroup(int bookingId) async {
    if (_hubConnection != null &&
        _hubConnection!.state == HubConnectionState.connected) {
      try {
        await _hubConnection!.invoke('LeaveBookingGroup', args: [bookingId.toString()]);
      } catch (_) {}
    }
  }

  // Provider telemetry emitter: broadcasts live GPS coordinates while OnTheWay
  Future<void> sendLocation({
    required int bookingId,
    required double latitude,
    required double longitude,
  }) async {
    if (_hubConnection != null &&
        _hubConnection!.state == HubConnectionState.connected) {
      try {
        await _hubConnection!.invoke('SendLocationUpdate', args: [bookingId.toString(), latitude, longitude]);
      } catch (_) {
        // Fallback to legacy invocation if needed
        try {
          await _hubConnection!.invoke('SendLocation', args: [bookingId, latitude, longitude]);
        } catch (_) {}
      }
    } else {
      // Local broadcast simulation if disconnected
      _locationStreamController.add(
        LocationUpdateEvent(
          bookingId: bookingId,
          latitude: latitude,
          longitude: longitude,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  // Provider / System Status emitter
  Future<void> sendStatusUpdate({
    required int bookingId,
    required String status,
  }) async {
    if (_hubConnection != null &&
        _hubConnection!.state == HubConnectionState.connected) {
      try {
        await _hubConnection!.invoke('SendStatusUpdate', args: [bookingId.toString(), status]);
      } catch (_) {}
    } else {
      _bookingStatusStreamController.add(
        BookingStatusEvent(
          bookingId: bookingId,
          status: status,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  Future<void> disconnect() async {
    await _hubConnection?.stop();
  }

  void dispose() {
    _locationStreamController.close();
    _bookingStatusStreamController.close();
    _incomingJobStreamController.close();
    _partsApprovalStreamController.close();
  }
}

