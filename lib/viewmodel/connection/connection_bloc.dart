import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/network_checker.dart';
import 'connection_event.dart';
import 'connection_state.dart';

class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  final NetworkChecker _networkChecker;
  StreamSubscription? _subscription;

  ConnectionBloc({required NetworkChecker networkChecker})
      : _networkChecker = networkChecker,
        super(ConnectionInitial()) {
    on<ConnectionChanged>((event, emit) {
      if (event.isConnected) {
        emit(ConnectionConnected());
      } else {
        emit(ConnectionDisconnected());
      }
    });

    _subscription = _networkChecker.connectionStream.listen((isConnected) {
      add(ConnectionChanged(isConnected));
    });
    
    // Check initial state
    _checkInitial();
  }

  Future<void> _checkInitial() async {
    final connected = await _networkChecker.hasConnection;
    add(ConnectionChanged(connected));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
