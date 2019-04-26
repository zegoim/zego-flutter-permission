package com.zego.zegopermission;

import android.Manifest;
import android.content.ComponentName;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;

import java.util.ArrayList;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static android.content.pm.PackageManager.PERMISSION_DENIED;
import static android.content.pm.PackageManager.PERMISSION_GRANTED;
import static android.service.notification.Condition.SCHEME;

/** ZegoPermissionPlugin */
public class ZegoPermissionPlugin implements MethodCallHandler, PluginRegistry.RequestPermissionsResultListener {

  static final int STATUS_GRANTED = 0;
  static final int STATUS_DENIED = 2;
  static final int STATUS_UNKNOWN = 4;

  static final int CAMERA = 0;
  static final int MICROPHONE = 1;
  static final int PHOTOS = 2;

  final int REQ_CODE = 7777;

  private Registrar mRegistrar = null;
  private Result mResult = null;

  ZegoPermissionPlugin(Registrar registrar) {
    this.mRegistrar = registrar;
    this.mRegistrar.addRequestPermissionsResultListener(this);
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "plugins.zego.im/zego_permission");
    channel.setMethodCallHandler(new ZegoPermissionPlugin(registrar));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getPermissions")) {
      if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        ArrayList<Integer> permissionList = call.argument("list");
        ArrayList<Integer> statusList = new ArrayList<>();
        for (Integer permission : permissionList) {
          switch (permission.intValue()) {
            case CAMERA:
              getPermission(statusList, Manifest.permission.CAMERA);
              break;
            case MICROPHONE:
              getPermission(statusList, Manifest.permission.RECORD_AUDIO);
              break;
            case PHOTOS:
              getPermission(statusList, Manifest.permission.WRITE_EXTERNAL_STORAGE);
              break;
            default:
              result.success(null);
              break;
          }
        }
        result.success(statusList);
      } else {
        //兼容Android 6.0 以下系统
        result.success(null);
      }

    } else if(call.method.equals("requestPermission")) {
      if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        int type = call.argument("type");
        mResult = result;
        switch (type) {
          case CAMERA:
            String[] cameraPermission = {Manifest.permission.CAMERA};
            requestPermission(cameraPermission, REQ_CODE);
            break;
          case MICROPHONE:
            String[] micPermission = {Manifest.permission.RECORD_AUDIO};
            requestPermission(micPermission, REQ_CODE);
            break;
          case PHOTOS:
            String[] photoPermission = {Manifest.permission.WRITE_EXTERNAL_STORAGE};
            requestPermission(photoPermission, REQ_CODE);
            break;
          default:
            mResult.success(null);
            break;
        }
      } else {
        mResult.success(null);
      }

    } else if(call.method.equals("openAppSettings")) {
      try {
        //这里需要根据主流厂商做不同的逻辑
          try {
            Intent settingsIntent = new Intent();
            settingsIntent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
            Uri uri = Uri.fromParts(SCHEME, mRegistrar.context().getPackageName(), null);
            settingsIntent.setData(uri);

            mRegistrar.context().startActivity(settingsIntent);
          } catch (Exception e) {

            e.printStackTrace();
            mRegistrar.context().startActivity(new Intent(Settings.ACTION_SETTINGS));
          }

      }catch (Exception e) {
        e.printStackTrace();
      }
    } else {
      result.notImplemented();
    }
  }

  private void getPermission(ArrayList<Integer> array, String type) {
    if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      int status = mRegistrar.context().checkSelfPermission(type);
      System.out.println("platform output status: " + status);
      switch (status) {
        case PERMISSION_GRANTED:
          array.add(Integer.valueOf(STATUS_GRANTED));
          break;
        case PERMISSION_DENIED:
          array.add(Integer.valueOf(STATUS_DENIED));
          break;
        default:
          array.add(Integer.valueOf(STATUS_UNKNOWN));
          break;
      }
    }
  }

  private void requestPermission(String[] permissions, int code) {
    if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      mRegistrar.activity().requestPermissions(permissions, code);
    }
  }

  @Override
  public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
    if(requestCode == REQ_CODE) {
      for(int i = 0; i < permissions.length; i++) {

        if(grantResults[i] == PERMISSION_GRANTED) {
          mResult.success(true);
        } else {
          mResult.success(false);
        }
      }
      return true;
    }

    return false;
  }
}
