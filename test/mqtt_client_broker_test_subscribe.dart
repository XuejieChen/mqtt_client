/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 11/07/2017
 * Copyright :  S.Hamblett
 */

import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:observable/observable.dart';

Future<int> main() async {
  // Create and connect the client
  final MqttClient client =
  new MqttClient("test.mosquitto.org", "SJHMQTTClient");
  client.logging(true);
  await client.connect();
  if (client.connectionState == ConnectionState.connected) {
    print("Mosquitto client connected");
  } else {
    print(
        "ERROR Mosquitto client connection failed - disconnecting, state is ${client
            .connectionState}");
    client.disconnect();
  }
  // Subscribe to a known topic
  final String topic = "test/hw";
  final ChangeNotifier<MqttReceivedMessage> cn =
  client.listenTo(topic, MqttQos.exactlyOnce);
  cn.changes.listen((List<MqttReceivedMessage> c) {
    final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
    final String pt =
    MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    print("Change notification:: payload is <$pt> for topic <$topic>");
  });
  print("Sleeping....");
  await MqttUtilities.asyncSleep(90);
  print("Unsubscribing");
  client.unsubscribe(topic);
  print("Disconnecting");
  client.disconnect();
  return 0;
}