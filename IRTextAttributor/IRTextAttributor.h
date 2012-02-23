//
//  IRTextAttributor.h
//  IRTextAttributor
//
//  Created by Evadne Wu on 10/2/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const IRTextAttributorTagAttributeName;


#ifndef __IRTextAttributor__
#define __IRTextAttributor__

typedef void (^IRTextAttributorDiscoveryCallback) (NSRange rangeOfSubstring);
typedef void (^IRTextAttributorAttributionCallback) (id discoveredAttributeOrNil);

typedef void (^IRTextAttributorDiscoveryBlock) (NSString *entireString, IRTextAttributorDiscoveryCallback callback);
typedef void (^IRTextAttributorAttributionBlock) (NSString *attributedString, IRTextAttributorAttributionCallback callback);

#endif


@class IRTextAttributor;
@protocol IRTextAttributorDelegate <NSObject>

- (void) textAttributor:(IRTextAttributor *)attributor willUpdateAttributedString:(NSAttributedString *)attributedString withToken:(NSString *)aToken	range:(NSRange)tokenRange attribute:(id)newAttribute;
- (void) textAttributor:(IRTextAttributor *)attributor didUpdateAttributedString:(NSAttributedString *)attributedString withToken:(NSString *)aToken	range:(NSRange)tokenRange attribute:(id)newAttribute;

@end


@interface IRTextAttributor : NSObject

@property (nonatomic, readwrite, retain) NSMutableAttributedString *attributedContent;
@property (nonatomic, readwrite, assign) id<IRTextAttributorDelegate> delegate;

@property (nonatomic, readwrite, copy) IRTextAttributorDiscoveryBlock discoveryBlock;
@property (nonatomic, readwrite, copy) IRTextAttributorAttributionBlock attributionBlock;

@property (nonatomic, readonly, retain) NSOperationQueue *queue;
//		[something irBind:@"isBusy" toObject:attributor withKeyPath:@"queue.operations" options:nil];

@end

extern IRTextAttributorDiscoveryBlock IRTextAttributorDiscoveryBlockMakeWithRegularExpression (NSRegularExpression *anExpression);
