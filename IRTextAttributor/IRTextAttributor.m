//
//  IRTextAttributor.m
//  IRTextAttributor
//
//  Created by Evadne Wu on 10/2/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import "IRTextAttributor.h"
#import "IRTextAttributionOperation.h"


NSString * const IRTextAttributorTagAttributeName = @"_IRTextAttributorTag";


@interface IRTextAttributor ()

@property (nonatomic, readwrite, retain) NSOperationQueue *queue;
@property (nonatomic, readwrite, retain) NSCache *cache;

- (void) performGlobalDiscovery;

- (void) willLoadAttribute:(id)anAttribute forToken:(NSString *)aString inAttributedString:(NSAttributedString *)hostingAttributedString withSubstringRange:(NSRange)aRange;
- (void) didLoadAttribute:(id)anAttribute forToken:(NSString *)aString inAttributedString:(NSAttributedString *)hostingAttributedString withSubstringRange:(NSRange)aRange;

@end


@implementation IRTextAttributor

@synthesize attributedContent;
@synthesize delegate, discoveryBlock, attributionBlock;
@synthesize queue, cache;

- (id) init {

	self = [super init];
	if (!self)
		return nil;
	
	queue = [[NSOperationQueue alloc] init];
	cache = [[NSCache alloc] init];
	
	return self;

}

- (void) dealloc {

	[queue cancelAllOperations];

}

- (void) setAttributedContent:(NSMutableAttributedString *)newAttributedContent {

	if (attributedContent == newAttributedContent)
		return;
	
	attributedContent = newAttributedContent;

	[self performGlobalDiscovery];

}

- (void) performGlobalDiscovery {

	__weak IRTextAttributor *wSelf = self;
	
	NSMutableAttributedString *capturedAttributedContent = self.attributedContent;
	
	NSString *baseString = [capturedAttributedContent string];
	
	self.discoveryBlock(baseString, ^ (NSRange aRange) {
	
		if (!wSelf)
			return;
	
		NSString *substring = [baseString substringWithRange:aRange];
		
		//	If the discovered range already has a tag, bail
		
		NSRange currentTagRange = (NSRange){ 0, 0 };
		id currentAttribute = [capturedAttributedContent attribute:IRTextAttributorTagAttributeName atIndex:aRange.location effectiveRange:&currentTagRange];
	
		if (currentAttribute) {
			NSLog(@"tag already exists at range %@", NSStringFromRange(aRange));
			return;
		}
		
		//	If the discovered range already has a cached attribute,
		//	set it and then bail
		
		id cachedAttribute = [wSelf.cache objectForKey:substring];
		if (cachedAttribute) {
		
			[wSelf willLoadAttribute:cachedAttribute forToken:substring inAttributedString:capturedAttributedContent withSubstringRange:aRange];
			
			[capturedAttributedContent addAttribute:IRTextAttributorTagAttributeName value:cachedAttribute range:aRange];
			
			[wSelf didLoadAttribute:cachedAttribute forToken:substring inAttributedString:capturedAttributedContent withSubstringRange:aRange];
			
			return;
		
		}
		
		
		//	Go and fetch.
		
		__block IRTextAttributionOperation *operation = [IRTextAttributionOperation operationWithWorkerBlock:^(void(^callbackBlock)(id results)) {
		
			wSelf.attributionBlock(substring, ^ (id attribute) {
				
				callbackBlock(attribute);
				
			});
			
		} completionBlock: ^ (id results) {
			
			[capturedAttributedContent removeAttribute:IRTextAttributorTagAttributeName range:aRange];
			
			if (results) {	
				
				[wSelf willLoadAttribute:results forToken:substring inAttributedString:capturedAttributedContent withSubstringRange:aRange];
				
				[wSelf.cache setObject:results forKey:substring];
				[capturedAttributedContent addAttribute:IRTextAttributorTagAttributeName value:results range:aRange];

				[wSelf didLoadAttribute:results forToken:substring inAttributedString:capturedAttributedContent withSubstringRange:aRange];

			}
			
			operation = nil;
			
		}];
		
		[capturedAttributedContent addAttribute:IRTextAttributorTagAttributeName value:operation range:aRange];
		
		[wSelf.queue addOperation:operation];
		
	});

}

- (void) willLoadAttribute:(id)anAttribute forToken:(NSString *)aString inAttributedString:(NSAttributedString *)hostingAttributedString withSubstringRange:(NSRange)aRange {

	if (hostingAttributedString != self.attributedContent)
		return;
	
	[self.delegate textAttributor:self willUpdateAttributedString:self.attributedContent withToken:aString range:aRange attribute:anAttribute];

}

- (void) didLoadAttribute:(id)anAttribute forToken:(NSString *)aString inAttributedString:(NSAttributedString *)hostingAttributedString withSubstringRange:(NSRange)aRange {

	if (hostingAttributedString != self.attributedContent)
		return;
	
	[self.delegate textAttributor:self didUpdateAttributedString:self.attributedContent withToken:aString range:aRange attribute:anAttribute];

}

@end

IRTextAttributorDiscoveryBlock IRTextAttributorDiscoveryBlockMakeWithRegularExpression (NSRegularExpression *anExpression) {

	return [ ^ (NSString *entireString, IRTextAttributorDiscoveryCallback callback) {
	
		NSRange entireRange = (NSRange){ 0, [entireString length] };
	
		[anExpression enumerateMatchesInString:entireString options:0 range:entireRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		
			callback(result.range);
			
		}];
	
	} copy];

}
