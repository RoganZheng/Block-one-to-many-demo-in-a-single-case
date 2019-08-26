//
//  SingleInstance.m
//  BlockDemo
//
//  Created by drogan Zheng on 2019/8/26.
//  Copyright © 2019 drogan Zheng. All rights reserved.
//

#import "SingleInstance.h"
#import <objc/runtime.h>

@interface SingleInstance ()

@property (nonatomic, strong) NSMapTable *blockTable;

@end

@implementation SingleInstance


#pragma mark ==========  shareInstance Life init  =========
+ (instancetype)sharedInstance{
    static SingleInstance *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] initPrivate];
    });
    return instance;
}

- (instancetype)init
{
    return [[self class] sharedInstance];
}

- (instancetype)initPrivate{
    self = [super init];
    if (self) {
        // key为 observer 注册对象，用 weak 属性表示不持有 observer，仅指向 observer
        // value 为 observer 注册的 block 回调，使用 strong 属性意味着映射表要持有 block
        self.blockTable = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory capacity:1];
    }
    return self;
}

#pragma mark ========= multiBlock ========

- (void)addObserver:(id)observer callback:(multiObserverBlock)callback {
    //将block进行判空处理，防止存储时为nil造成crash
    if (callback == nil) {
        return;
    }
    // 这里要打破循环引用，因为关联代码中 watch 被 observer 持有，而 watch 中的 callback 去调用了 observer
    __weak typeof (observer) weakObserver = observer;
    DeallocWatcher *watch = [[DeallocWatcher alloc] initWithDeallocCallback:^{
        __strong typeof (observer) strongObserver = weakObserver;
        [self removeObserver:strongObserver];
    }];
    [self.blockTable setObject:callback forKey:observer];
    // 将 observer 与 watch 进行绑定关联，key 则使用 observer 的打印地址
    objc_setAssociatedObject(observer, [[NSString stringWithFormat:@"%p", &observer] UTF8String], watch, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.blockTable objectForKey:observer];
    
}

- (void)removeObserver:(id)observer {
    [self.blockTable removeObjectForKey:observer];
    objc_setAssociatedObject(observer, [[NSString stringWithFormat:@"%p", &observer] UTF8String], nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)runBlockMethod {
    // 当需要去执行映射表中的block代码块时，遍历映射表并执行已有的block块
    [[[self.blockTable objectEnumerator] allObjects] enumerateObjectsUsingBlock:^(multiObserverBlock callback, NSUInteger idx, BOOL * _Nonnull stop) {
        callback();
    }];
}

@end


@implementation DeallocWatcher

- (instancetype)initWithDeallocCallback:(dispatch_block_t)callback {
    self = [super init];
    if (self) {
        self.deallocCallback = callback;
    }
    return self;
}

- (void)dealloc
{
    // 关键代码，当该对象释放触发 dealloc 方法时，会去执行 callback 回调
    if (self.deallocCallback) {
        self.deallocCallback();
    }
}

@end
