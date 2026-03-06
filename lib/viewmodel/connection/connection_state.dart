import 'package:equatable/equatable.dart';

abstract class ConnectionState extends Equatable {
  const ConnectionState();
  @override
  List<Object> get props => [];
}

class ConnectionInitial extends ConnectionState {}

class ConnectionConnected extends ConnectionState {}

class ConnectionDisconnected extends ConnectionState {}
