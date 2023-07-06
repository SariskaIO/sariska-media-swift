#import <Foundation/Foundation.h>


@interface Participant : NSObject

@property (nonatomic)NSString *participantId;
@property (nonatomic)NSString *jid;
@property (nonatomic)NSString *displayName;
@property (nonatomic)BOOL moderator;
@property (nonatomic)BOOL hidden;
@property (nonatomic)BOOL videoMuted;
@property (nonatomic)BOOL audioMuted;
@property (nonatomic)NSString *botType;
@property (nonatomic)NSString *status;
@property (nonatomic)NSString *avatar;
@property (nonatomic)NSString *role;
@property (nonatomic)NSString *email;

- (Participant *)initWithOptions:(NSDictionary *) m;
- (NSString*)getId;
- (NSString*)getDisplayName;
- (NSString*)getRole;
- (NSString*)getJid;
- (NSString*)getAvatar;
- (BOOL)isModerator;
- (BOOL)isHidden;
- (BOOL)isAudioMuted;
- (BOOL)isVideoMuted;
- (NSString*)getBotType;
- (NSString*)getEmail;
- (NSString*)getStatus;

@end
