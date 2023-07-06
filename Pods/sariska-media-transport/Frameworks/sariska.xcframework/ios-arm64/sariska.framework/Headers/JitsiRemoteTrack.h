#import <Foundation/Foundation.h>
#import "RTCVideoView.h"

NS_ASSUME_NONNULL_BEGIN
@interface JitsiRemoteTrack : NSObject

@property (nonatomic)NSString *trackId;
@property (nonatomic)NSString *type;
@property (nonatomic)BOOL muted;
@property (nonatomic)NSString *streamURL;
@property (nonatomic)NSString *participantId;

- (JitsiRemoteTrack *)initWithOptions:(NSDictionary *) m;
- (NSString*)getParticipantId;
- (NSString*)getType;
- (NSString*)getStreamURL;
- (NSString*)getId;
- (BOOL)isMuted;
- (void)setMuted:(BOOL)mute;
- (BOOL)isLocal;
- (void)dispose;
- (RTCVideoView *) render;

@end
NS_ASSUME_NONNULL_END
