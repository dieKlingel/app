import 'dart:math';

import 'package:dieklingel_app/rtc/mqtt_rtc_description.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Mqtt Rtc Description Constructor", () {
    group("from json", () {
      test("no  websocket and no ssl param", () {
        String host = "server.dieklingel.com";
        String channel = "debug/test";
        int port = 1883;

        Map<String, dynamic> input = {
          "host": host,
          "port": port,
          "channel": channel
        };

        MqttRtcDescription description = MqttRtcDescription.fromJson(input);
        expect(description.host, host);
        expect(description.channel, channel);
        expect(description.port, port);
        expect(description.ssl, true);
        expect(description.websocket, false);
      });

      test("websocket and ssl param", () {
        String host = "server.dieklingel.com";
        String channel = "debug/test";
        int port = 1883;
        bool ssl = false;
        bool weboscket = true;

        Map<String, dynamic> input = {
          "host": host,
          "port": port,
          "channel": channel,
          "websocket": weboscket,
          "ssl": ssl,
        };

        MqttRtcDescription description = MqttRtcDescription.fromJson(input);
        expect(description.host, host);
        expect(description.channel, channel);
        expect(description.port, port);
        expect(description.ssl, ssl);
        expect(description.websocket, weboscket);
      });
    });
    group("from uri", () {
      test("mqtt", () {
        Uri uri = Uri.parse("mqtt://server.dieklingel.com:1883/hallo/welt");

        MqttRtcDescription description = MqttRtcDescription.parse(uri);

        expect(description.host, "server.dieklingel.com");
        expect(description.channel, "hallo/welt");
        expect(description.port, 1883);
        expect(description.ssl, false);
        expect(description.websocket, false);
      });

      test("mqtts", () {
        Uri uri = Uri.parse("mqtts://server.dieklingel.com:1883/hallo/welt");

        MqttRtcDescription description = MqttRtcDescription.parse(uri);

        expect(description.host, "server.dieklingel.com");
        expect(description.channel, "hallo/welt");
        expect(description.port, 1883);
        expect(description.ssl, true);
        expect(description.websocket, false);
      });

      test("ws", () {
        Uri uri = Uri.parse("ws://server.dieklingel.com:1883/hallo/welt");

        MqttRtcDescription description = MqttRtcDescription.parse(uri);

        expect(description.host, "server.dieklingel.com");
        expect(description.channel, "hallo/welt");
        expect(description.port, 1883);
        expect(description.ssl, false);
        expect(description.websocket, true);
      });

      test("wss", () {
        Uri uri = Uri.parse("wss://server.dieklingel.com:1883/hallo/welt");

        MqttRtcDescription description = MqttRtcDescription.parse(uri);

        expect(description.host, "server.dieklingel.com");
        expect(description.channel, "hallo/welt");
        expect(description.port, 1883);
        expect(description.ssl, true);
        expect(description.websocket, true);
      });

      test("absolute path", () {
        Uri uri = Uri.parse("mqtt://server.dieklingel.com:1883//hallo/welt");

        MqttRtcDescription description = MqttRtcDescription.parse(uri);

        expect(description.channel, "/hallo/welt");
      });
    });
  });
}
