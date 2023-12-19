class ErrorMessage{
  dynamic code;
  dynamic message;
  dynamic status;

  ErrorMessage({
    required this.code,
    required this.message,
    required this.status
  });

  factory ErrorMessage.fromJson(Map<String, dynamic> json) {
    return ErrorMessage(
      code: json["error_code"],
      message: json["message"],
      status: json["status"],
    );
  }
}