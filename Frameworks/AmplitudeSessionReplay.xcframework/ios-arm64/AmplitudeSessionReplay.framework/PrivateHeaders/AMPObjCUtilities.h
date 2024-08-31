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

NS_ASSUME_NONNULL_END
