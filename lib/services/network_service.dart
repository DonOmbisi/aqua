import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _internetChecker =
      InternetConnectionChecker.createInstance();

  StreamController<bool> _connectionChangeController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionChange => _connectionChangeController.stream;

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  late StreamSubscription _connectivitySubscription;
  late StreamSubscription _internetConnectionSubscription;

  Future<void> initialize() async {
    _isOnline = await _internetChecker.hasConnection;

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        await _updateConnectionStatus();
      },
    );

    // Listen to internet connection changes
    _internetConnectionSubscription = _internetChecker.onStatusChange.listen(
      (InternetConnectionStatus status) {
        _isOnline = status == InternetConnectionStatus.connected;
        _connectionChangeController.add(_isOnline);
      },
    );
  }

  Future<void> _updateConnectionStatus() async {
    bool isConnected = await _internetChecker.hasConnection;
    if (_isOnline != isConnected) {
      _isOnline = isConnected;
      _connectionChangeController.add(_isOnline);
    }
  }

  Future<bool> checkConnection() async {
    _isOnline = await _internetChecker.hasConnection;
    return _isOnline;
  }

  void dispose() {
    _connectivitySubscription.cancel();
    _internetConnectionSubscription.cancel();
    _connectionChangeController.close();
  }
}
