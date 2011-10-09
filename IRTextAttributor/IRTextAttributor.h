//
//  IRTextAttributor.h
//  IRTextAttributor
//
//  Created by Evadne Wu on 10/2/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>


#ifndef __IRTextAttributor__
#define __IRTextAttributor__

typedef void (^IRTextAttributorSubstringDiscoveryCallback) (NSString *substring, NSRange rangeOfSubstring);

typedef void (^IRTextAttributorDiscoveryBlock) (NSString *baseString, IRTextAttributorSubstringDiscoveryCallback callbackOnSubstringDiscovery);

typedef void (^IRTextAttributorAttributeDiscoveryCallback) (NSString *substring, id discoveredAttribute);

typedef void (^IRTextAttributorAttributeDiscoveryBlock) (NSString *potentialSubstring, IRTextAttributorAttributeDiscoveryCallback callbackOnLatentAttributeDiscovery);

#endif


@class IRTextAttributor;
@protocol IRTextAttributorDelegate <NSObject>

- (id) textAttributor:(IRTextAttributor *)attributor replacementAttributeForProposedAttribute:(id)anAttribute forBaseString:(NSString *)aBaseString usingString:(NSString **)usedString attributeName:(NSString **)usedAttributeName;

@end


@interface IRTextAttributor : NSObject

- (void) noteMutableAttributedStringDidChange:(NSMutableAttributedString *)aMutableAttributedString;

- (void) haltDiscovery:(NSMutableAttributedString *)workingAttributedString;

@property (nonatomic, readwrite, assign) id<IRTextAttributorDelegate> delegate;

@property (nonatomic, readwrite, copy) IRTextAttributorDiscoveryBlock potentialSubstringDiscoveryBlock;

//	Generally you’ll want to use NSRegularExpression, in that case I think  enumeration can be done sequentially.  Parallel enumeration is not tested and I have no idea if it would even work at all.

@property (nonatomic, readwrite, copy) IRTextAttributorAttributeDiscoveryBlock substringAttributingBlock;

@end
