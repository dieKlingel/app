import 'package:dieklingel_app/messaging/mclient_topic_message.dart';
import 'package:flutter/material.dart';

class MClientSubscribtion {
  final String topic;
  final void Function(MClientTopicMessage message) listener;

  MClientSubscribtion(this.topic, {required this.listener});
}
