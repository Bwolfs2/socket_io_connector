import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:example/src/app_widget.dart';
import 'package:example/src/app_bloc.dart';
import 'package:socket_io_connector/socket_io_connector.dart';

class AppModule extends ModuleWidget {
  @override
  List<Bloc> get blocs => [
        Bloc((i) => AppBloc()),
      ];

  @override
  List<Dependency> get dependencies => [
    Dependency((i)=>SocketIOConnector("ws://198.11.241.21:5000/socket.io/?transport=websocket"))
  ];

  @override
  Widget get view => AppWidget();

  static Inject get to => Inject<AppModule>.of();
}
