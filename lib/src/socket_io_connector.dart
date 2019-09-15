import 'dart:async';
import 'dart:convert';
import 'package:websocket/websocket.dart';
import 'snapshot_io.dart';

class SocketIOConnector {
  final _controller = StreamController.broadcast();
  final Map<String, SnapshotIO> _snapmap = {};
  bool _isDisconnected = false;
  bool isConnected = false;
  Completer<bool> _onConnect = Completer<bool>();

  final String url;

  SocketIOConnector(this.url) {
    _connect();
  }

  WebSocket _channelPromisse;

  SnapshotIO subscription(String key, {Map<String, dynamic> variables}) {
    if (_snapmap.keys.isEmpty) {
      _connect();
    }

    if (_snapmap.containsKey(key)) {
      return _snapmap[key];
    } else {
      if (isConnected) {
        _channelPromisse.addUtf8Text("2".codeUnits);
      }
      var snap = SnapshotIO(
        key,
        _controller.stream.where((data) => data[0] == key).transform(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(data.length > 1 ? data[1] : true);
            },
          ),
        ),
        () {
          _snapmap.remove(key);
          if (_snapmap.keys.isEmpty) {
            _disconnect();
          }
        },
        conn: this,
      );

      _snapmap[key] = snap;
      return snap;
    }
  }

  _connect() async {
    print(_channelPromisse != null ? "reconnecting..." : "connecting...");

    try {
      var _url = url.replaceFirst("http", "ws");

      if (!_url.contains("/socket.io/?transport=websocket")) {
        _url = _url + "/socket.io/?transport=websocket";
      }

      _channelPromisse = await WebSocket.connect("$_url");

      _channelPromisse.addUtf8Text("2".codeUnits);

      var _sub = _channelPromisse.stream.listen((data) {
        int index = int.parse(data.replaceAll(RegExp(r"[\[{].+"), ""));

        if ("$data" == "$index") {
          return;
        }

        var json = jsonDecode(data.replaceFirst("$index", ""));

        //  print(json);

        if (json[0] is String) {
          _controller.add(json);
        }
      });

      _sub.onError((e) {
        print(e);
      });
      await _channelPromisse.done;
      await _sub.cancel();
      isConnected = false;
      if (!_isDisconnected) {
        await Future.delayed(Duration(milliseconds: 3000));
        if (_onConnect.isCompleted) {
          _onConnect = Completer<bool>();
        }
        _connect();
      }
    } catch (e) {
      print(e);
      if (!_isDisconnected) {
        await Future.delayed(Duration(milliseconds: 3000));

        if (_onConnect.isCompleted) {
          _onConnect = Completer<bool>();
        }
        _connect();
      }
    }
  }

  void _disconnect() {
    print("disconnected hasura");
    _isDisconnected = true;
  }

  void dispose() {
    _disconnect();
    _controller.close();
    _snapmap.clear();
  }

  void send(String method, String data) {
    if (!_isDisconnected) {
      if (_onConnect.isCompleted) {
        _onConnect = Completer<bool>();
      }
      _connect();
      _channelPromisse?.addUtf8Text("42[\"$method\",\"$data\"]"?.codeUnits);
    } else {
      _channelPromisse?.addUtf8Text("42[\"$method\",\"$data\"]"?.codeUnits);
    }
  }
}
