class DisconnectMessage {
  final String topic;
  final String message;
  final bool retain;

  const DisconnectMessage(
    this.topic,
    this.message, {
    this.retain = false,
  });
}
