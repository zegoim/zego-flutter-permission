#import "ZegoPermissionPlugin.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

static const int STATUS_GRANTED = 0;
static const int STATUS_RESTRICTED = 1;
static const int STATUS_DENIED = 2;
static const int STATUS_NOT_DETERMINED = 3;
static const int STATUS_UNKNOWN = 4;

static const int CAMERA = 0;
static const int MICROPHONE = 1;
static const int PHOTOS = 2;

@implementation ZegoPermissionPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"plugins.zego.im/zego_permission"
            binaryMessenger:[registrar messenger]];
  ZegoPermissionPlugin* instance = [[ZegoPermissionPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    NSDictionary *args = call.arguments;
  if ([@"getPermissions" isEqualToString:call.method]) {
      NSArray *permissionList = args[@"list"];
      NSMutableArray *statusList = [[NSMutableArray alloc] init];
      
      for (NSNumber *permission in permissionList) {
          switch ([permission intValue]) {
              case CAMERA:
                  [self getCameraPermission:statusList];
                  break;
                  
              case MICROPHONE:
                  [self getMicrophonePermission:statusList];
                  break;
                  
              case PHOTOS:
                  [self getPhotosPermission:statusList];
                  break;
                  
              default:
                  break;
          }
      }
      
      result(statusList);
  } 
  else if([@"requestPermission" isEqualToString:call.method]) {
      NSNumber *type = args[@"type"];
      switch ([type intValue]) {
          case CAMERA:
              [self requestCameraPermission:result];
              break;
          case MICROPHONE:
              [self requestMicrophonePermission:result];
              break;
          case PHOTOS:
              [self requestPhotosPermission:result];
              break;
          default:
              result(nil);
              break;
      }
  }
  else if([@"openAppSettings" isEqualToString:call.method]) {
      NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
      if([[UIApplication sharedApplication] canOpenURL:url]) {
          [[UIApplication sharedApplication] openURL:url];
      }
      
      result(nil);
  }
  else {
    result(FlutterMethodNotImplemented);
  }
}

-(void) getCameraPermission:(NSMutableArray *)array {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined:
            //没有询问是否开启相机
            [array addObject:@(STATUS_NOT_DETERMINED)];
            break;
        case AVAuthorizationStatusRestricted:
            //未授权，家长限制
            [array addObject:@(STATUS_RESTRICTED)];
            break;
        case AVAuthorizationStatusDenied:
            //未授权
            [array addObject:@(STATUS_DENIED)];
            break;
        case AVAuthorizationStatusAuthorized:
            //玩家授权
            [array addObject:@(STATUS_GRANTED)];
            break;
        default:
            [array addObject:@(STATUS_UNKNOWN)];
            break;
    }
}

-(void) getMicrophonePermission:(NSMutableArray *)array {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined:
            //没有询问是否开启相机
            [array addObject:@(STATUS_NOT_DETERMINED)];
            break;
        case AVAuthorizationStatusRestricted:
            //未授权，家长限制
            [array addObject:@(STATUS_RESTRICTED)];
            break;
        case AVAuthorizationStatusDenied:
            //未授权
            [array addObject:@(STATUS_DENIED)];
            break;
        case AVAuthorizationStatusAuthorized:
            //玩家授权
            [array addObject:@(STATUS_GRANTED)];
            break;
        default:
            [array addObject:@(STATUS_UNKNOWN)];
            break;
    }
}

-(void) getPhotosPermission:(NSMutableArray *)array {
    PHAuthorizationStatus photoAuthorStatus = [PHPhotoLibrary authorizationStatus];
    switch (photoAuthorStatus) {
        case PHAuthorizationStatusAuthorized:
            [array addObject:@(STATUS_GRANTED)];
            break;
        case PHAuthorizationStatusDenied:
            [array addObject:@(STATUS_DENIED)];
            break;
        case PHAuthorizationStatusNotDetermined:
            [array addObject:@(STATUS_NOT_DETERMINED)];
            break;
        case PHAuthorizationStatusRestricted:
            [array addObject:@(STATUS_RESTRICTED)];
            break;
        default:
            [array addObject:@(STATUS_UNKNOWN)];
            break;
    }
    
}

-(void) requestCameraPermission:(FlutterResult)result {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        result(@(granted));
    }];
}

-(void) requestMicrophonePermission:(FlutterResult)result {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        result(@(granted));
    }];
}

-(void) requestPhotosPermission:(FlutterResult)result {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if(status == PHAuthorizationStatusAuthorized) {
            result(@(YES));
        } else {
            result(@(NO));
        }
    }];
}

@end
