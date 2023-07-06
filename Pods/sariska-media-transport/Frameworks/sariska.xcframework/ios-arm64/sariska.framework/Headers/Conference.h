#import <Foundation/Foundation.h>
#import "JitsiLocalTrack.h"
#import "JitsiRemoteTrack.h"
#import "Participant.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ConferenceCallbackParam0)(void);
typedef void(^ConferenceCallbackParam1)(id);
typedef void(^ConferenceCallbackParam2)(id,id);
typedef void(^ConferenceCallbackParam3)(id,id,id);
typedef void(^ConferenceCallbackParam4)(id,id,id,id);

@interface Conference: NSObject

@property (class) NSMutableDictionary *bindingsDel;
@property (class) BOOL hidden;
@property (class) NSString * userId;
@property (class) NSString * role;
@property (class) NSString * name;
@property (class) NSString * email;
@property (class) NSString * avatar;
@property (class) BOOL dtmf;
@property (class) NSString * phoneNumber;
@property (class) NSString * phonePin;
@property (class) BOOL membersOnly;
@property (class) BOOL joined;


- (Conference *)init;
- (Conference *)initWithParams:(NSDictionary *)options;
- (BOOL)isHidden;
- (BOOL)isDTMFSupported;
- (NSString *)getUserId;
- (NSString *)getUserRole;
- (NSString *)getUserEmail;
- (NSString *)getUserAvatar;
- (NSString *)getUserName;
- (NSString *)getPhoneNumber;
- (NSString *)getPhonePin;
- (BOOL)isMembersOnly;
- (BOOL)isJoined;
- (void)join;
- (void)join: (NSString *) password;
- (void)grantOwner:(NSString *) id;
- (void)setStartMutedPolicy:(NSDictionary *)policy;
- (void)setReceiverVideoConstraint:(NSNumber *)resolution;
- (void)setSenderVideoConstraint:(NSNumber *)resolution;
- (void)sendMessage:(NSString *)message;
- (void)sendMessage:(NSString *)message to: (NSString *) to;
- (void)setLastN:(NSNumber *)num;
- (void)muteParticipant:(NSString * ) id;
- (void)muteParticipant:(NSString * ) id mediaType: (NSString *) mediaType;
- (void)setDisplayName:(NSString *)name;
- (void)selectParticipant:(NSString *) id;
- (void)addTrack:(JitsiLocalTrack *) track  NS_SWIFT_NAME(addTrack(track:));
- (void)removeTrack:(JitsiLocalTrack *) track NS_SWIFT_NAME(removeTrack(track:));
- (void)replaceTrack:(JitsiLocalTrack *) oldTrack newTrack: (JitsiLocalTrack *) newTrack NS_SWIFT_NAME(replaceTrack(oldTrack:newTrack));
- (void)lock:(NSString *)password;
- (void)setSubject:(NSString *)subject;
- (void)unlock;
- (void)kickParticipant:(NSString *) id;
- (void)kickParticipant:(NSString * ) id reason:(NSString *) reason;
- (void)startSIPVideoCall:(NSString * ) sipAddress room:(NSString *) room;
- (void)stopSIPVideoCall:(NSString * ) sipAddress;
- (void)pinParticipant:(NSString *) id;
- (void)stopTranscriber;
- (void)startTranscriber;
- (void)startP2PSession;
- (void)stopP2PSession;
- (void)revokeOwner:(NSString *) id;
- (void)startRecording:(NSDictionary *)options;
- (void)stopRecording:(NSString *) sessionId;
- (void)setLocalParticipantProperty:(NSString *) propertyKey propertyValue:(NSString *) propertyValue;
- (void)removeLocalParticipantProperty:(NSString *) name;
- (void)sendFeedback:(NSString *) overallFeedback detailedFeedback:(NSString *) detailedFeedback;
- (void)leave;
- (void)dial:(NSNumber *) number;
- (void)selectParticipants: (NSMutableArray *) participantIds;
- (Participant *) findParticipant: (NSString *) participantId;
- (JitsiRemoteTrack *) findTrack: (NSString *) trackId;
- (NSNumber *) getParticipantCount: (BOOL) hidden;
- (NSMutableArray <Participant*> *) getParticipants;
- (NSMutableArray <JitsiLocalTrack*> *) getLocalTracks;
- (NSMutableArray <JitsiRemoteTrack*> *) getRemoteTracks;
- (void)addEventListener: (NSString * ) event callback0: (ConferenceCallbackParam0) callback0;
- (void)addEventListener: (NSString *) event callback1: (ConferenceCallbackParam1) callback1;
- (void)addEventListener: (NSString *) event callback2: (ConferenceCallbackParam2) callback2;
- (void)addEventListener: (NSString *) event callback3: (ConferenceCallbackParam3) callback3;
- (void)addEventListener: (NSString *) event callback4: (ConferenceCallbackParam4) callback4;
- (void)removeEventListener: (NSString *) event;
- (void)newConferenceMessage:(NSString *) action m:(NSDictionary *) m;
@end
NS_ASSUME_NONNULL_END
