import 'package:flutter/material.dart';
import 'package:socket_io_connector/socket_io_connector.dart';

import '../app_module.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SocketIOConnector socketIO = AppModule.to.getDependency();

  SnapshotIO snap;

  @override
  void initState() {
    super.initState();

    snap = socketIO.subscription("new message");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream: snap?.stream,
              builder: (_, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return Text("Teste ${snapshot.data}");
              },
            ),
          ),
          RaisedButton(
            onPressed: () {
              socketIO.send("send message", "Mensagem de teste");
            },
            child: Text("Enviar Mensagem"),
          ),
        ],
      ),
    );
  }
}
