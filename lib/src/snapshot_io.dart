import 'dart:async';
import 'startwith_stream_transformer.dart';
import 'socket_io_connector.dart';

class SnapshotIO<T> {
  final Function _close;
  final String key;

  T value;

  SocketIOConnector _conn;

  StreamController<T> _controller;

  final Stream<T> _streamInit;

  Stream<T> get stream => _controller.stream
      .transform(StartWithStreamTransformer(value))
      .where((v) => value != null);

  SnapshotIO(this.key, this._streamInit, this._close,
      {StreamController<T> controllerTest,
      SocketIOConnector conn,
      this.value}) {
    _conn = conn;

    if (controllerTest == null) {
      _controller = StreamController<T>.broadcast();
    } else {
      _controller = controllerTest;
    }

    _streamInit.listen((data) {
      value = data;
      _controller.add(data);
    });
  }

  SnapshotIO<S> _copyWith<S>(
      {String key,
      String query,
      Map<String, dynamic> variables,
      Stream streamInit,
      Function close,
      StreamController<S> controller,
      SocketIOConnector conn,
      S value,
      Function(SnapshotIO) renew}) {
    return SnapshotIO<S>(
        key ?? this.key, streamInit ?? this._streamInit, close ?? this.close,
        conn: conn ?? this._conn,
        value: value,
        controllerTest: controller ?? this._controller);
  }

  SnapshotIO<S> map<S>(S Function(dynamic) convert) {
    var valueParse = this.value != null ? convert(this.value) : null;

    var v = _copyWith<S>(
      streamInit: _streamInit.map<S>(convert),
      controller: StreamController<S>.broadcast(),
      value: valueParse,
    );
    return v;
  }

  close() {
    _controller.close();
    _close();
  }
}
