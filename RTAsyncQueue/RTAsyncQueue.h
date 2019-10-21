//
//  RTAsyncQueue.h
//  AsyncObject
//
//  Created by lvwang2002 on 15/7/16.
//  Copyright (c) 2015年 lvwang2002. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RTAsyncCell;
typedef void (^MethodBlock)(NSDictionary *info,RTAsyncCell *asyncCell);
typedef  void (^FinishBlock)(NSError *error,NSDictionary *info);
@interface RTAsyncQueue : NSObject
+(RTAsyncQueue *)shareAsyncQueue;
-(BOOL)addMethods:(NSArray *)methods WithFinishBlock:(FinishBlock)finishBlock;
@end

@interface RTAsyncCell : NSObject

@property(strong,nonatomic)NSArray *methods;
@property NSUInteger index;
@property(weak,nonatomic)MethodBlock activityMethod;
@property(strong,nonatomic)FinishBlock finishBlock;
/** 进入下一个事件 */
-(void)nextWithError:(NSError *)error Infos:(NSDictionary *)info;

/** 结束队列 */
-(void)stopWithError:(NSError *)error Infos:(NSDictionary *)info;
@end