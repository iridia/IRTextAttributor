//
//  IRTextAttributionOperation.h
//  IRTextAttributor
//
//  Created by Evadne Wu on 10/9/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRTextAttributionOperation : NSOperation

@property (nonatomic, readonly, assign, getter=isExecuting) BOOL executing;
@property (nonatomic, readonly, assign, getter=isFinished) BOOL finished;

@property (nonatomic, readwrite, copy) void (^workerBlock)(void(^callbackBlock)(id results));
@property (nonatomic, readwrite, copy) void (^workCompletionBlock)(id results);

@property (nonatomic, readwrite, assign) NSAttributedString *attributedString;

@end
