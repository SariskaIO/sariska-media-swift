#import <Foundation/Foundation.h>

@interface Params : NSObject 

+ (NSDictionary *)createParams;
+ (NSDictionary *)createParams:(NSString *)action;
+ (NSDictionary *)createParams:(NSString *)action fromString: (NSString *) fromString;
+ (NSDictionary *)createParams:(NSString *)action fromInt: (NSNumber *) fromInt;
+ (NSDictionary *)createParams:(NSString *)action fromBool: (BOOL) fromBool;
+ (NSDictionary *)createParams:(NSString *)action fromString1: (NSString *) fromString1  fromString2: (NSString *) fromString2;
+ (NSDictionary *)createParams:(NSString *)action fromString: (NSString *) fromString  fromBool: (BOOL) fromBool;
+ (NSDictionary *)createParams:(NSString *)action fromString:(NSString *) fromString  fromInt: (NSNumber *) fromInt;
+ (NSDictionary *)createParams:(NSString *)action fromInt1:(NSNumber *) fromInt1  fromInt2: (NSNumber *) fromInt2;
+ (NSDictionary *)createParams:(NSString *)action fromInt:(NSNumber *) fromInt  fromBool: (BOOL) fromBool;
+ (NSDictionary *)createParams:(NSString *)action fromInt:(NSNumber *) fromInt  fromString: (NSString *) fromString;
+ (NSDictionary *)createParams:(NSString *)action fromDict: (NSDictionary *) fromDict;
+ (NSDictionary *)createParams:(NSString *)action fromArr: (NSMutableArray *) fromArr;
+ (NSDictionary *)createConnection:(NSString *)token roomName: (NSString *) roomName isNightly:  (BOOL) isNightly;
+ (NSDictionary *)createConference;
+ (NSDictionary *)createConferenceWithParams:(NSDictionary *) options;
+ (NSDictionary *)createTrackParams:(NSDictionary *)param1;

@end
