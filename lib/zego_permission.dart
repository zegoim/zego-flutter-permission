import 'dart:async';

import 'package:flutter/services.dart';

enum PermissionType {
  Camera,
  MicroPhone,
  Photos
}

enum PermissionStatus {
  /// Permission to access the requested feature is granted by the user.
  granted,
  /// The user granted restricted access to the requested feature (only on iOS).
  restricted,
  /// Permission to access the requested feature is denied by the user.
  denied,
  /// Permission is not request
  not_determited,
  /// Permission is in an unknown state
  unknown,
  /// The feature is disabled (or not available) on the device.
  disabled
}

class Permission {
  final PermissionType permissionType;
  final PermissionStatus permissionStatus;

  Permission(this.permissionType, this.permissionStatus);
}

class ZegoPermission {
  static const MethodChannel _channel =
      const MethodChannel('plugins.zego.im/zego_permission');

  static Future<List<Permission>> getPermissions(List<PermissionType> list) async {

    List<int> indexList = [];
    for(PermissionType type in list) {
      indexList.add(type.index);
    }

    final List<dynamic> statusList = await _channel.invokeMethod('getPermissions', {'list': indexList});
    if(statusList == null)
      return null;

    List<Permission> pList = [];
    for(int i = 0; i < statusList.length; i++) {
      Permission permission = new Permission(list[i], PermissionStatus.values[statusList[i]]);
      pList.add(permission);
    }

    return pList;
  }

  static Future<bool> requestPermission(PermissionType type) async {
    final bool status = await _channel.invokeMethod('requestPermission', {'type': type.index});
    return status;
  }

  static Future<Null> openAppSettings() async {
    final result = await _channel.invokeMethod('openAppSettings');
    return result;
  }
}
