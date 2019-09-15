class SocketIOError implements Exception {
  final String message;
  final Extensions extensions;

  SocketIOError(this.message, this.extensions);

  factory SocketIOError.fromJson(Map json) {
    return SocketIOError(
        json["message"], Extensions.fromJson(json["extensions"]));
  }

  @override
  String toString() {
    return "Error: $message";
  }
}

class Extensions {
  final dynamic path;
  final dynamic code;

  Extensions(this.path, this.code);

  factory Extensions.fromJson(Map json) {
    return Extensions(json["path"], json["code"]);
  }

  @override
  String toString() {
    return "path: $path, code: $code";
  }
}