import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final config = {
    'NODE_SERVER_IP': Platform.environment['NODE_SERVER_IP'],
  };

  final filename = 'example/integration_test/.env.dart';
  await File(filename)
      .writeAsString('final environment = ${json.encode(config)};');
}
