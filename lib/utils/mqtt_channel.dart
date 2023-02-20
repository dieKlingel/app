// TODO(KoiFresh): move class to dieklingel_core_shared
class MqttChannel {
  late final List<String> _topics;

  MqttChannel(String channel) {
    List<String> channels = channel.split("/");
    channels.removeWhere((element) => element.trim().isEmpty);

    _topics = channels;
  }

  factory MqttChannel.fromList(List<String> channel) {
    return MqttChannel(channel.join("/"));
  }

  MqttChannel append(String topic) {
    String channel = toString();

    return MqttChannel("$channel/$topic");
  }

  MqttChannel remove(MqttChannel other) {
    List<String> topics = _topics.toList();

    topics.removeWhere((element) => other.toList().contains(element));

    return MqttChannel(topics.join("/"));
  }

  List<String> toList() {
    return _topics.toList();
  }

  @override
  String toString() {
    return _topics.join("/");
  }
}
