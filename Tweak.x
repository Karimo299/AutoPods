#import <UIKit/UIKit.h>
#import <MediaRemote/MediaRemote.h>
#import <HBLog.h>
#import <notify.h>

@interface BCBatteryDevice : NSObject
@property (assign,getter=isCharging,nonatomic) BOOL charging;
@property (nonatomic,copy) NSString * identifier;
-(void) getChargingStatus;
@end

@interface CUBluetoothClient : NSObject
@property (assign,nonatomic) unsigned statusFlags; 
@end


%hook CUBluetoothClient
-(void)updateStatusFlags {
	%orig;
	if (self.statusFlags == 14) {
		notify_post("com.karimo299.autopods-disconnected");
	} else if (self.statusFlags == 15) {
		notify_post("com.karimo299.autopods-connected");
	}
}
%end


%hook BCBatteryDevice 
BOOL leftEarCharging;
BOOL rightEarCharging;
BOOL connected;
int token;

-(void)setCharging:(BOOL)arg1 {
	notify_register_dispatch("com.karimo299.autopods-disconnected", &token, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(int token) {
		connected = NO;
	});
	notify_register_dispatch("com.karimo299.autopods-connected", &token, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(int token) {
		connected = YES;
	});
	[self getChargingStatus];
	return %orig;
}

	%new
	-(void)getChargingStatus {
		if (connected) {
			if  ([self.identifier containsString:@"Left"]){
				leftEarCharging = self.charging;
			} else if ([self.identifier containsString:@"Right"]){
				rightEarCharging = self.charging;
			}

			if (rightEarCharging == 1 || leftEarCharging == 1) {
				MRMediaRemoteSendCommand(MRMediaRemoteCommandPlay, nil);
			}
		}
	}
%end	