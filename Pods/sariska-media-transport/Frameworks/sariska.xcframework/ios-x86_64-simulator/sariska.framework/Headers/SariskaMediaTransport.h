#import <Foundation/Foundation.h>
#import "Connection.h"
#import "JitsiLocalTrack.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^LocalTrackCallback)(NSMutableArray * tracks);
@interface SariskaMediaTransport: NSObject
@property (class) LocalTrackCallback callback;

+ (void)initializeSdk;
+ (Connection *)JitsiConnection:(NSString *)token roomName: (NSString *) roomName isNightly: (BOOL) isNightly NS_SWIFT_NAME(JitsiConnection(token:));
+ (void)createLocalTracks: (NSDictionary *) options callback: (LocalTrackCallback) callback;
+ (void)sendEvent: (NSString * )eventName  payload: (NSDictionary *) payload;
+ (NSMutableArray <JitsiLocalTrack*> *)getLocalTracks;
- (void)newSariskaMediaTransportMessage: (NSString *) action m: (NSDictionary *) m;
- (void)newLocalTrackMessage: (NSString * )action  m: (NSArray *) m;
+ (void)setLogLevel: ( NSString *) logLevel;

@end
NS_ASSUME_NONNULL_END
