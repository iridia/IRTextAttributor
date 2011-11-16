//
//  IRTextAttributor.m
//  IRTextAttributor
//
//  Created by Evadne Wu on 10/2/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import "IRTextAttributor.h"
#import "IRTextAttributionOperation.h"


static NSString * const kIRTextAttributorTag = @"_IRTextAttributorTag";


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

	[attributedContent release];
	[discoveryBlock release];
	[attributionBlock release];
	
	[queue cancelAllOperations];
	[queue waitUntilAllOperationsAreFinished];
	[queue release];
	
	[cache release];
	
	[super dealloc];

}

- (void) setAttributedContent:(NSMutableAttributedString *)newAttributedContent {

	if (attributedContent == newAttributedContent)
		return;
	
	[attributedContent release];
	attributedContent = [newAttributedContent retain];

	[self performGlobalDiscovery];

}

- (void) performGlobalDiscovery {

	__block __typeof__(self) nrSelf = self;
	
	NSMutableAttributedString *capturedAttributedContent = self.attributedContent;
	
	NSString *baseString = [capturedAttributedContent string];
	
	self.discoveryBlock(baseString, ^ (NSRange aRange) {
	
		NSString *substring = [baseString substringWithRange:aRange];
		
		//	If the discovered range already has a tag, bail
		
		NSRange currentTagRange = (NSRange){ 0, 0 };
		id currentAttribute = [capturedAttributedContent attribute:kIRTextAttributorTag atIndex:aRange.location effectiveRange:&currentTagRange];
	
		if (currentAttribute) {
			NSLog(@"tag already exists at range %@", NSStringFromRange(aRange));
			return;
		}
		
		
		//	If the discovered range already has a cached attribute,
		//	set it and then bail
		
		id cachedAttribute = [nrSelf.cache objectForKey:substring];
		if (cachedAttribute) {
		
			[nrSelf willLoadAttribute:cachedAttribute forToken:substring inAttributedString:capturedAttributedContent withSubstringRange:aRange];
			
			[capturedAttributedContent addAttribute:kIRTextAttributorTag value:cachedAttribute range:aRange];
			
			[nrSelf didLoadAttribute:cachedAttribute forToken:substring inAttributedString:capturedAttributedContent withSubstringRange:aRange];
			
			return;
		
		}
		
		
		//	Go and fetch.
		
		__block IRTextAttributionOperation *operation = [IRTextAttributionOperation operationWithWorkerBlock:^(void(^callbackBlock)(id results)) {
		
			nrSelf.attributionBlock(substring, ^ (id attribute) {
				
				callbackBlock(attribute);
				
			});
			
		} completionBlock: ^ (id results) {
		
			[[operation retain] autorelease];
			
			[capturedAttributedContent removeAttribute:kIRTextAttributorTag range:aRange];
			
			if (results) {	
				
				[nrSelf willLoadAttribute:results forToken:substring inAttributedString:capturedAttributedContent withSubstringRange:aRange];
				
				[nrSelf.cache setObject:results forKey:substring];
				[capturedAttributedContent addAttribute:kIRTextAttributorTag value:results range:aRange];

				[nrSelf didLoadAttribute:results forToken:substring inAttributedString:capturedAttributedContent withSubstringRange:aRange];

			}
			
		}];
		
		[capturedAttributedContent addAttribute:kIRTextAttributorTag value:operation range:aRange];
		
		[self.queue addOperation:operation];
		
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

	return [[ ^ (NSString *entireString, IRTextAttributorDiscoveryCallback callback) {
	
		NSRange entireRange = (NSRange){ 0, [entireString length] };
	
		[anExpression enumerateMatchesInString:entireString options:0 range:entireRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		
			callback(result.range);
			
		}];
	
	} copy] autorelease];

}
