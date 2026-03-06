import 'package:equatable/equatable.dart';

abstract class ConnectionEvent extends Equatable {
  const ConnectionEvent();
  @override
  List<Object> get props => [];
}

class ConnectionChanged extends ConnectionEvent {
  final bool isConnected;
  const ConnectionChanged(this.isConnected);

  @override
  List<Object> get props => [isConnected];
}
