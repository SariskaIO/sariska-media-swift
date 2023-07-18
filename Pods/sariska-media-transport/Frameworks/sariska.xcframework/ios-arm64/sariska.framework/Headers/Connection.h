#import <Foundation/Foundation.h>
#import "Conference.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^ConnectionCallback)(void);
 
@interface Connection: NSObject

@property (class) NSMutableDictionary *bindingsDel;
- (Conference *)jitsiConference  NS_SWIFT_NAME(initJitsiConference());
- (Conference *)jitsiConference: (NSDictionary *)options  NS_SWIFT_NAME(initJitsiConference());
- (Connection *)initWithToken:(NSString *)token roomName: (NSString *) roomName isNightly:  (BOOL) isNightly;
- (void)addEventListener:(NSString *)event callback: (ConnectionCallback)callback;
- (void)removeEventListener:(NSString *)event;
- (void)connect;
- (void)disconnect;
- (void)addFeature:(NSDictionary *)featureFlags;
- (void)removeFeature:(NSDictionary *)featureFlags;
- (void)setToken:(NSString *)token;
- (void)newConnectionMessage:(NSString *)action;
@end
 
NS_ASSUME_NONNULL_END

