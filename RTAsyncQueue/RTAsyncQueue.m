//
//  RTAsyncQueue.m
//  AsyncObject
//
//  Created by lvwang2002 on 15/7/16.
//  Copyright (c) 2015年 lvwang2002. All rights reserved.
//

#import "RTAsyncQueue.h"
static NSString *RTAsyncNotification = @"RTAsyncNotification";
@implementation RTAsyncQueue{
    NSMutableArray *_asyncCells;
    
}


+(RTAsyncQueue *)shareAsyncQueue{
    static RTAsyncQueue *asyncQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        asyncQueue = [[RTAsyncQueue alloc]init];
    });
    
    return asyncQueue;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        _asyncCells = [[NSMutableArray alloc]initWithCapacity:10];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(asyncNotification:) name:RTAsyncNotification object:nil];

    }
    return self;
}

-(BOOL)addMethods:(NSArray *)methods WithFinishBlock:(FinishBlock)finishBlock{
    if (!methods.count) {
        return NO;
    }
    
    
    MethodBlock method = [methods objectAtIndex:0];
    
    RTAsyncCell *asyncCell = [[RTAsyncCell alloc]init];
    asyncCell.methods = methods;
    asyncCell.index = 0;
    asyncCell.activityMethod = method;
    asyncCell.finishBlock = finishBlock;
    [_asyncCells addObject:asyncCell];

    method(nil,asyncCell);
    return YES;
}

-(void)asyncNotification:(NSNotification *)notification{
    //结束的话,在数据库中把该记录清除掉.
    RTAsyncCell *asyncCell = [notification.userInfo valueForKey:@"asyncCell"];
    [_asyncCells removeObject:asyncCell];
}
//-(void)waterfallWithMethods:(NSArray *)methods WithCallback:
@end

@implementation RTAsyncCell{

    

}

-(void)nextWithError:(NSError *)error Infos:(NSDictionary *)info{
    if (error) {
        _finishBlock(error,nil);
        [[NSNotificationCenter defaultCenter]postNotificationName:RTAsyncNotification object:self userInfo:@{@"asyncCell":self,@"error":error}];
        return;
    }
    
    _index = _index+1;
    if (_index==_methods.count) {
        //如果相等,说明方法已经执行完成,执行最后的 完成函数
        _finishBlock(nil,info);
        [[NSNotificationCenter defaultCenter]postNotificationName:RTAsyncNotification object:self userInfo:@{@"asyncCell":self,@"error":[NSNull null],@"info":info}];

        return;
        
    }
    
    _activityMethod = [_methods objectAtIndex:_index];
    
    _activityMethod(info,self);
}

-(void)stopWithError:(NSError *)error Infos:(NSDictionary *)info{
    if (error) {
        _finishBlock(error,nil);
        [[NSNotificationCenter defaultCenter]postNotificationName:RTAsyncNotification object:self userInfo:@{@"asyncCell":self,
                                       @"error":error}];
        return;
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:RTAsyncNotification object:self userInfo:@{@"asyncCell":self,
                                   @"error":[NSNull null],
                                    @"info":info}];

    
}
@end