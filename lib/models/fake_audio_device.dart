import 'dart:ffi';

import 'package:flutter_liblinphone/flutter_liblinphone.dart';
import 'package:flutter_liblinphone/gen/flutter_linphone_wrapper.g.dart';

class FakeAudioDevice implements AudioDevice {
  final String deviceName;
  final String driverName;
  final String id;
  final AudioDeviceType type;
  final int capabilities;

  const FakeAudioDevice({
    this.deviceName = "",
    this.driverName = "",
    this.id = "",
    this.type = AudioDeviceType.unknown,
    this.capabilities = 0,
  });

  @override
  Pointer<LinphoneAudioDevice> get cPtr => nullptr;

  @override
  int getCapabilities() => capabilities;

  @override
  String getDeviceName() => deviceName;

  @override
  String getDriverName() => driverName;

  @override
  String getId() => id;

  @override
  AudioDeviceType getType() => type;

  @override
  bool hasCapability(AudioDeviceCapabilities capability) {
    return false;
  }

  @override
  operator ==(Object other) {
    if (other is FakeAudioDevice) {
      return other.deviceName == deviceName &&
          other.driverName == driverName &&
          other.id == id &&
          other.type == type &&
          other.capabilities == capabilities;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(
        deviceName,
        driverName,
        id,
        type,
        capabilities,
      );
}
