import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NetworkStatus { online, offline, unknown }

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<NetworkStatus> get statusStream;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  @override
  Stream<NetworkStatus> get statusStream {
    return _connectivity.onConnectivityChanged.map((result) {
      if (result == ConnectivityResult.none) {
        return NetworkStatus.offline;
      } else {
        return NetworkStatus.online;
      }
    });
  }
}

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(Connectivity());
});

final networkStatusProvider = StreamProvider<NetworkStatus>((ref) {
  return ref.watch(networkInfoProvider).statusStream;
});
