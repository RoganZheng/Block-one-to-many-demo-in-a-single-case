//
//  SingleInstance.h
//  BlockDemo
//
//  Created by drogan Zheng on 2019/8/26.
//  Copyright © 2019 drogan Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^multiObserverBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface SingleInstance : NSObject

+ (instancetype)sharedInstance;

- (void)addObserver:(id)observer callback:(multiObserverBlock)callback;

- (void)runBlockMethod;

@end

@interface DeallocWatcher : NSObject

@property (nonatomic, copy) dispatch_block_t deallocCallback;

- (instancetype)initWithDeallocCallback:(dispatch_block_t)callback;

@end


NS_ASSUME_NONNULL_END
