//
//  PLCPlaceTextStorage.m
//  Places
//
//  Created by Jack Flintermann on 7/12/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCPlaceTextStorage.h"

@implementation PLCPlaceTextStorage
{
	NSMutableAttributedString *_imp;
}

- (instancetype)init
{
	self = [super init];
    
	if (self) {
		_imp = [NSMutableAttributedString new];
	}
    
	return self;
}


#pragma mark - Reading Text

- (NSString *)string
{
	return _imp.string;
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
	return [_imp attributesAtIndex:location effectiveRange:range];
}


#pragma mark - Text Editing

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
	[_imp replaceCharactersInRange:range withString:str];
	[self edited:NSTextStorageEditedCharacters range:range changeInLength:(NSInteger)str.length - (NSInteger)range.length];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
	[_imp setAttributes:attrs range:range];
	[self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}


#pragma mark - Syntax highlighting

- (void)processEditing
{
    NSString *title = [[self.string componentsSeparatedByString:@"\n"] firstObject];
    NSUInteger titleLength = [title length];
    
    [self removeAttribute:NSFontAttributeName range:NSMakeRange(0, self.string.length)];
    [self addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-DemiBold" size:18.0f] range:NSMakeRange(0, titleLength)];
    [self addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:18.0f] range:NSMakeRange(titleLength, self.string.length - titleLength)];
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.alignment = NSTextAlignmentCenter;
    style.firstLineHeadIndent = 40;
    style.headIndent = 40;
    style.tailIndent = -40;
    [self addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, titleLength)];

    style = [NSMutableParagraphStyle new];
    style.alignment = NSTextAlignmentCenter;
    [self addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(titleLength, self.string.length - titleLength)];
    
    // Call super *after* changing the attrbutes, as it finalizes the attributes and calls the delegate methods.
    [super processEditing];
}

@end
