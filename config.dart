import 'dart:convert';

class config {
  static const String _encoded =
      "aHR0cHM6Ly9kZXRlY3Qucm9ib2Zsb3cuY29tL3NpZ24tbGFuZ3VhZ2UtZGV0ZWN0aW9uLTdjZHBqLzI/YXBpX2tleT1GS2RMQTh5WEFpZE5DdWVmN2NoTQ==";

  static String get api => utf8.decode(base64Decode(_encoded));
}
