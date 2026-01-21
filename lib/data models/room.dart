class Room {
  String roomName, _password = '', hostIp;

  Room({required this.roomName, required this.hostIp});

  set password(String value) {
    _password = value;
  }

  String get password => _password;
}
