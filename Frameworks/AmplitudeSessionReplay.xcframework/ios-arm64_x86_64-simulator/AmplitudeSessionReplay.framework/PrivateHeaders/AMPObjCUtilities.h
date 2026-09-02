//
//  AMPObjCUtilities.h
//  AmplitudeSessionReplay
//
//  Created by Chris Leonavicius on 8/30/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^AMPTryBlock)(void);
typedef void (^AMPCatchBlock)(NSException *e);

void AMPObjCTryCatch(AMPTryBlock tryBlock, _Nullable AMPCatchBlock catchBlock);

/// Safely calls value(forKey:) and returns nil if the object throws NSUndefinedKeyException
id _Nullable AMPSafeValueForKey(NSObject *object, NSString *key);

NS_ASSUME_NONNULL_END
