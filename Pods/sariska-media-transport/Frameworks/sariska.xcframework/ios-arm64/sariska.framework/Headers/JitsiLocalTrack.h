#import <Foundation/Foundation.h>
#import "RTCVideoView.h"

NS_ASSUME_NONNULL_BEGIN
@interface JitsiLocalTrack : NSObject

@property (nonatomic)NSString *trackId;
@property (nonatomic)NSString *type;
@property (nonatomic)BOOL muted;
@property (nonatomic)NSString *streamURL;
@property (nonatomic)NSString *deviceId;
@property (nonatomic)NSString *participantId;

- (JitsiLocalTrack *)initWithOptions:(NSDictionary *) m;
- (NSString*)getDeviceId;
- (NSString*)getType;
- (NSString*)getStreamURL;
- (NSString*)getId;
- (NSString*)getParticipantId;
- (void)switchCamera;
- (BOOL)isMuted;
- (BOOL)isLocal;
- (void)mute;
- (void)unmute;
- (void)dispose;
- (RTCVideoView *)render;

@end
NS_ASSUME_NONNULL_END
