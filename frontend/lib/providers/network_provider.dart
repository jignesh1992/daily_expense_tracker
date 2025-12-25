import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkState {
  final bool isOnline;
  final ConnectivityResult connectivityResult;

  NetworkState({
    this.isOnline = true,
    this.connectivityResult = ConnectivityResult.none,
  });

  NetworkState copyWith({
    bool? isOnline,
    ConnectivityResult? connectivityResult,
  }) {
    return NetworkState(
      isOnline: isOnline ?? this.isOnline,
      connectivityResult: connectivityResult ?? this.connectivityResult,
    );
  }
}

class NetworkNotifier extends StateNotifier<NetworkState> {
  NetworkNotifier() : super(NetworkState()) {
    _init();
  }

  final _connectivity = Connectivity();

  Future<void> _init() async {
    final result = await _connectivity.checkConnectivity();
    state = state.copyWith(
      connectivityResult: result,
      isOnline: result != ConnectivityResult.none,
    );

    _connectivity.onConnectivityChanged.listen((result) {
      state = state.copyWith(
        connectivityResult: result,
        isOnline: result != ConnectivityResult.none,
      );
    });
  }
}

final networkProvider = StateNotifierProvider<NetworkNotifier, NetworkState>((ref) {
  return NetworkNotifier();
});
