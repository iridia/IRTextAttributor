//
//  IRTextAttributor.m
//  IRTextAttributor
//
//  Created by Evadne Wu on 10/2/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import "IRTextAttributor.h"
#import "IRTextAttributionOperation.h"


static NSString * const kIRTextAttributorTaggingAttributeName = @"_IRTextAttributorTag";


@interface IRTextAttributor ()

@property (nonatomic, readwrite, retain) NSOperationQueue *queue;

@end


@implementation IRTextAttributor

@synthesize delegate, potentialSubstringDiscoveryBlock, substringAttributingBlock;
@synthesize queue;

- (id) init {

	self = [super init];
	if (!self)
		return nil;
	
	queue = [[NSOperationQueue alloc] init];
	
	return self;

}

- (void) dealloc {

	[potentialSubstringDiscoveryBlock release];
	[substringAttributingBlock release];
	[queue release];
	
	[super dealloc];

}

- (void) haltDiscovery:(NSMutableAttributedString *)workingAttributedString {

	[[self.queue.operations filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(IRTextAttributionOperation *anOperation, NSDictionary *bindings) {
	
		return anOperation.attributedString == workingAttributedString;
	
	}]] enumerateObjectsUsingBlock:^(NSOperation *anOperation, NSUInteger idx, BOOL *stop) {
		
		[anOperation cancel];
		
	}];

}

- (void) noteMutableAttributedStringDidChange:(NSMutableAttributedString *)aMutableAttributedString {

	NSParameterAssert(self.potentialSubstringDiscoveryBlock);
	
	[aMutableAttributedString retain];
	NSString *baseString = [aMutableAttributedString string];
	
	self.potentialSubstringDiscoveryBlock(baseString, ^ (NSString *substring, NSRange rangeOfSubstring) {
	
		NSLog(@"found a potential attribute backing string %@ at %@", substring, NSStringFromRange(rangeOfSubstring));
		
		NSRange usedRange = rangeOfSubstring;
		NSDictionary *attributesAtIndex = [aMutableAttributedString attributesAtIndex:rangeOfSubstring.location effectiveRange:&usedRange];
		
		NSLog(@"discovered are %@", attributesAtIndex);
		
		if (![attributesAtIndex objectForKey:kIRTextAttributorTaggingAttributeName]) {
		
			IRTextAttributionOperation *operation = [[[IRTextAttributionOperation alloc] init] autorelease];
			
			operation.workerBlock = ^ (void(^aCallback)(id)) {
			
				self.substringAttributingBlock(substring, ^ (NSString *substring, id discoveredAttribute){
			
					NSLog(@"for %@, found %@", substring, discoveredAttribute);
					
					if (aCallback)
						aCallback(discoveredAttribute);
				
				});
			
			};
		
			//	TBD kick off an operation for the specific attribute, and then stitch it to the string
			
			[aMutableAttributedString addAttribute:kIRTextAttributorTaggingAttributeName value:nil range:usedRange];
		
		}
	
	});

}

@end
