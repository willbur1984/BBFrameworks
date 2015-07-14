//
//  BBTokenTextView.m
//  BBFrameworks
//
//  Created by William Towe on 7/6/15.
//  Copyright (c) 2015 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "BBTokenTextView.h"
#import "BBTokenDefaultTextAttachment.h"
#import "BBTokenCompletionDefaultTableViewCell.h"

#import <MobileCoreServices/MobileCoreServices.h>

@interface _BBTokenTextViewInternalDelegate : NSObject <BBTokenTextViewDelegate>
@property (weak,nonatomic) id<BBTokenTextViewDelegate> delegate;
@end

@implementation _BBTokenTextViewInternalDelegate

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [self.delegate respondsToSelector:aSelector] || [super respondsToSelector:aSelector];
}
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    [anInvocation invokeWithTarget:self.delegate];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL retval = [(id<UITextViewDelegate>)textView textView:textView shouldChangeTextInRange:range replacementText:text];
    
    if (retval &&
        [self.delegate respondsToSelector:_cmd]) {
        
        retval = [self.delegate textView:textView shouldChangeTextInRange:range replacementText:text];
    }
    
    return retval;
}
- (void)textViewDidChangeSelection:(UITextView *)textView {
    [(id<UITextViewDelegate>)textView textViewDidChangeSelection:textView];
    
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate textViewDidChangeSelection:textView];
    }
}
- (void)textViewDidChange:(UITextView *)textView {
    [(id<UITextViewDelegate>)textView textViewDidChange:textView];
    
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate textViewDidChange:textView];
    }
}

@end

static NSString *const kTypingFontKey = @"typingFont";
static NSString *const kTypingTextColorKey = @"typingTextColor";

static void *kObservingContext = &kObservingContext;

@interface BBTokenTextView () <BBTokenTextViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic) _BBTokenTextViewInternalDelegate *internalDelegate;

@property (strong,nonatomic) UITableView *tableView;
@property (copy,nonatomic) NSArray *completions;

@property (strong,nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

- (void)_BBTokenTextViewInit;

- (void)_showCompletionsTableView;
- (void)_hideCompletionsTableViewAndSelectCompletion:(id<BBTokenCompletion>)completion;

- (NSRange)_completionRangeForRange:(NSRange)range;
- (BBTokenDefaultTextAttachment *)_tokenTextAttachmentForRange:(NSRange)range index:(NSInteger *)index;

+ (NSCharacterSet *)_defaultTokenizingCharacterSet;
+ (NSTimeInterval)_defaultCompletionDelay;
+ (Class)_defaultCompletionTableViewCellClass;
+ (Class)_defaultTokenTextAttachmentClass;
+ (UIFont *)_defaultTypingFont;
+ (UIColor *)_defaultTypingTextColor;
@end

@implementation BBTokenTextView
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
    [self removeObserver:self forKeyPath:kTypingFontKey context:kObservingContext];
    [self removeObserver:self forKeyPath:kTypingTextColorKey context:kObservingContext];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    [self _BBTokenTextViewInit];
    
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder]))
        return nil;
    
    [self _BBTokenTextViewInit];
    
    return self;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(cut:) ||
        action == @selector(copy:)) {
        return NO;
    }
    return [super canPerformAction:action withSender:sender];
}

@dynamic delegate;
- (void)setDelegate:(id<BBTokenTextViewDelegate>)delegate {
    [self.internalDelegate setDelegate:delegate];
    
    [super setDelegate:self.internalDelegate];
}

- (void)paste:(id)sender {
    [self.textStorage replaceCharactersInRange:self.selectedRange withAttributedString:[[NSAttributedString alloc] initWithString:[[UIPasteboard generalPasteboard] valueForPasteboardType:(__bridge NSString *)kUTTypePlainText] attributes:@{NSFontAttributeName: self.typingFont, NSForegroundColorAttributeName: self.typingTextColor}]];
}
#pragma mark NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == kObservingContext) {
        if ([keyPath isEqualToString:kTypingFontKey] ||
            [keyPath isEqualToString:kTypingTextColorKey]) {
            
            [self setTypingAttributes:@{NSFontAttributeName: self.typingFont, NSForegroundColorAttributeName: self.typingTextColor}];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#pragma mark UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // tokenize character set
    // return
    if ([text rangeOfCharacterFromSet:self.tokenizingCharacterSet].length > 0 ||
        [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].length > 0) {
        
        NSRange tokenRange = [self _completionRangeForRange:range];
        
        if (tokenRange.length > 0) {
            NSString *tokenText = [[self.text substringWithRange:tokenRange] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            id representedObject = tokenText;
            
            if ([self.delegate respondsToSelector:@selector(tokenTextView:representedObjectForEditingText:)]) {
                representedObject = [self.delegate tokenTextView:self representedObjectForEditingText:tokenText];
            }
            
            NSArray *representedObjects = @[representedObject];
            NSInteger index;
            [self _tokenTextAttachmentForRange:range index:&index];
            
            if ([self.delegate respondsToSelector:@selector(tokenTextView:shouldAddRepresentedObjects:atIndex:)]) {
                representedObjects = [self.delegate tokenTextView:self shouldAddRepresentedObjects:representedObjects atIndex:index];
            }
            
            if (representedObjects.count > 0) {
                NSMutableAttributedString *temp = [[NSMutableAttributedString alloc] initWithString:@"" attributes:@{NSFontAttributeName: self.typingFont, NSForegroundColorAttributeName: self.typingTextColor}];
                
                for (id obj in representedObjects) {
                    NSString *displayText = [obj description];
                    
                    if ([self.delegate respondsToSelector:@selector(tokenTextView:displayTextForRepresentedObject:)]) {
                        displayText = [self.delegate tokenTextView:self displayTextForRepresentedObject:obj];
                    }
                    
                    [temp appendAttributedString:[NSAttributedString attributedStringWithAttachment:[[self.tokenTextAttachmentClass alloc] initWithRepresentedObject:obj text:displayText tokenTextView:self]]];
                }

                [self.textStorage replaceCharactersInRange:tokenRange withAttributedString:temp];
                
                [self setSelectedRange:NSMakeRange(tokenRange.location + 1, 0)];
                
                [self _hideCompletionsTableViewAndSelectCompletion:nil];
            }
        }
        
        return NO;
    }
    // delete
    else if (text.length == 0) {
        if (self.text.length > 0) {
            NSMutableArray *representedObjects = [[NSMutableArray alloc] init];
            
            [self.textStorage enumerateAttribute:NSAttachmentAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(BBTokenDefaultTextAttachment *value, NSRange range, BOOL *stop) {
                if (value) {
                    [representedObjects addObject:value.representedObject];
                }
            }];
            
            if (representedObjects.count > 0) {
                if ([self.delegate respondsToSelector:@selector(tokenTextView:didRemoveRepresentedObjects:atIndex:)]) {
                    NSInteger index;
                    [self _tokenTextAttachmentForRange:range index:&index];
                    
                    [self.delegate tokenTextView:self didRemoveRepresentedObjects:representedObjects atIndex:index];
                }
            }
        }
    }
    return YES;
}
- (void)textViewDidChangeSelection:(UITextView *)textView {
    [self setTypingAttributes:@{NSFontAttributeName: self.typingFont, NSForegroundColorAttributeName: self.typingTextColor}];
    
    __block BOOL shouldInvalidate = NO;
    
    [self.textStorage enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.textStorage.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value) {
            shouldInvalidate = YES;
            *stop = YES;
        }
    }];
    
    if (shouldInvalidate) {
        [self.layoutManager invalidateDisplayForCharacterRange:NSMakeRange(0, self.textStorage.length)];
    }
}
- (void)textViewDidChange:(UITextView *)textView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_showCompletionsTableView) object:nil];
    
    [self performSelector:@selector(_showCompletionsTableView) withObject:nil afterDelay:self.completionDelay];
}
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.completions.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell<BBTokenCompletionTableViewCell> *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.completionTableViewCellClass)];
    
    if (!cell) {
        cell = [[self.completionTableViewCellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(self.completionTableViewCellClass)];
    }
    
    [cell setCompletion:self.completions[indexPath.row]];
    
    return cell;
}
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self _hideCompletionsTableViewAndSelectCompletion:self.completions[indexPath.row]];
}
#pragma mark *** Public Methods ***
#pragma mark Properties
@dynamic representedObjects;
- (NSArray *)representedObjects {
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    
    [self.textStorage enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.textStorage.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(BBTokenDefaultTextAttachment *value, NSRange range, BOOL *stop) {
        if (value) {
            [retval addObject:value.representedObject];
        }
    }];
    
    return retval;
}
- (void)setRepresentedObjects:(NSArray *)representedObjects {
    NSMutableAttributedString *temp = [[NSMutableAttributedString alloc] initWithString:@"" attributes:@{}];
    
    for (id representedObject in self.representedObjects) {
        NSString *text = [representedObject description];
        
        if ([self.delegate respondsToSelector:@selector(tokenTextView:displayTextForRepresentedObject:)]) {
            text = [self.delegate tokenTextView:self displayTextForRepresentedObject:representedObject];
        }
        
        [temp appendAttributedString:[NSAttributedString attributedStringWithAttachment:[[[self tokenTextAttachmentClass] alloc] initWithRepresentedObject:representedObject text:text tokenTextView:self]]];
    }
    
    [self.textStorage setAttributedString:temp];
}

- (void)setTokenizingCharacterSet:(NSCharacterSet *)tokenizingCharacterSet {
    _tokenizingCharacterSet = tokenizingCharacterSet ?: [self.class _defaultTokenizingCharacterSet];
}

- (void)setCompletionDelay:(NSTimeInterval)completionDelay {
    _completionDelay = completionDelay < 0.0 ? [self.class _defaultCompletionDelay] : completionDelay;
}
- (void)setCompletionTableViewCellClass:(Class)completionTableViewCellClass {
    _completionTableViewCellClass = completionTableViewCellClass ?: [self.class _defaultCompletionTableViewCellClass];
}

- (void)setTokenTextAttachmentClass:(Class)tokenTextAttachmentClass {
    _tokenTextAttachmentClass = tokenTextAttachmentClass ?: [self.class _defaultTokenTextAttachmentClass];
}

- (void)setTypingFont:(UIFont *)typingFont {
    _typingFont = typingFont ?: [self.class _defaultTypingFont];
}
- (void)setTypingTextColor:(UIColor *)typingTextColor {
    _typingTextColor = typingTextColor ?: [self.class _defaultTypingTextColor];
}
#pragma mark *** Private Methods ***
- (void)_BBTokenTextViewInit; {
    _tokenizingCharacterSet = [self.class _defaultTokenizingCharacterSet];
    _completionDelay = [self.class _defaultCompletionDelay];
    _completionTableViewCellClass = [self.class _defaultCompletionTableViewCellClass];
    _tokenTextAttachmentClass = [self.class _defaultTokenTextAttachmentClass];
    _typingFont = [self.class _defaultTypingFont];
    _typingTextColor = [self.class _defaultTypingTextColor];
    
    [self setContentInset:UIEdgeInsetsZero];
    [self setTextContainerInset:UIEdgeInsetsZero];
    [self.textContainer setLineFragmentPadding:0];
    
    [self setInternalDelegate:[[_BBTokenTextViewInternalDelegate alloc] init]];
    [self setDelegate:nil];
    
    [self addObserver:self forKeyPath:kTypingFontKey options:NSKeyValueObservingOptionInitial context:kObservingContext];
    [self addObserver:self forKeyPath:kTypingTextColorKey options:NSKeyValueObservingOptionInitial context:kObservingContext];
    
    [self setTapGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapGestureRecognizerAction:)]];
    [self.tapGestureRecognizer setNumberOfTapsRequired:1];
    [self.tapGestureRecognizer setNumberOfTouchesRequired:1];
    [self addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)_showCompletionsTableView; {
    if ([self _completionRangeForRange:self.selectedRange].length == 0) {
        [self _hideCompletionsTableViewAndSelectCompletion:nil];
        return;
    }
    
    if (!self.tableView) {
        if ([self.delegate respondsToSelector:@selector(tokenTextView:showCompletionsTableView:)]) {
            [self setTableView:[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain]];
            [self.tableView setRowHeight:[self.completionTableViewCellClass respondsToSelector:@selector(rowHeight)] ? [self.completionTableViewCellClass rowHeight] : [BBTokenCompletionDefaultTableViewCell rowHeight]];
            [self.tableView setDataSource:self];
            [self.tableView setDelegate:self];
            
            [self.delegate tokenTextView:self showCompletionsTableView:self.tableView];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(tokenTextView:completionsForSubstring:indexOfRepresentedObject:completion:)] ||
        [self.delegate respondsToSelector:@selector(tokenTextView:completionsForSubstring:indexOfRepresentedObject:)]) {
        
        NSInteger index;
        [self _tokenTextAttachmentForRange:self.selectedRange index:&index];
        
        NSRange range = [self _completionRangeForRange:self.selectedRange];
        
        if ([self.delegate respondsToSelector:@selector(tokenTextView:completionsForSubstring:indexOfRepresentedObject:completion:)]) {
            [self.delegate tokenTextView:self completionsForSubstring:[self.text substringWithRange:range] indexOfRepresentedObject:index completion:^(NSArray *completions) {
                [self setCompletions:completions];
            }];
        }
        else {
            [self setCompletions:[self.delegate tokenTextView:self completionsForSubstring:[self.text substringWithRange:range] indexOfRepresentedObject:index]];
        }
    }
}
- (void)_hideCompletionsTableViewAndSelectCompletion:(id<BBTokenCompletion>)completion; {
    if ([self.delegate respondsToSelector:@selector(tokenTextView:hideCompletionsTableView:)]) {
        if (completion) {
            id representedObject = [self.delegate tokenTextView:self representedObjectForEditingText:[completion tokenCompletionTitle]];
            NSString *text = [self.delegate tokenTextView:self displayTextForRepresentedObject:representedObject];
            NSTextAttachment *attachment = [[self.tokenTextAttachmentClass alloc] initWithRepresentedObject:representedObject text:text tokenTextView:self];
            
            [self.textStorage replaceCharactersInRange:[self _completionRangeForRange:self.selectedRange] withAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        }
        
        [self.delegate tokenTextView:self hideCompletionsTableView:self.tableView];
        
        [self setTableView:nil];
    }
}

- (NSRange)_completionRangeForRange:(NSRange)range; {
    NSRange searchRange = NSMakeRange(0, range.location);
    // take the inverted set of our tokenizing set
    NSMutableCharacterSet *characterSet = [self.tokenizingCharacterSet.invertedSet mutableCopy];
    // remove the NSAttachmentCharacter from our inverted character set, we don't want to match against tokens
    [characterSet removeCharactersInString:[NSString stringWithFormat:@"%C",(unichar)NSAttachmentCharacter]];
    
    NSRange foundRange = [self.text rangeOfCharacterFromSet:characterSet options:NSBackwardsSearch range:searchRange];
    NSRange retval = foundRange;
    
    // first search backwards until we hit either a token or end of text
    while (foundRange.length > 0) {
        retval = NSUnionRange(retval, foundRange);
        
        searchRange = NSMakeRange(0, foundRange.location);
        foundRange = [self.text rangeOfCharacterFromSet:characterSet options:NSBackwardsSearch range:searchRange];
    }
    
    // then search forwards until we hit either a token or end of text
    searchRange = NSMakeRange(range.location, self.text.length - range.location);
    foundRange = [self.text rangeOfCharacterFromSet:characterSet options:0 range:searchRange];
    
    while (foundRange.length > 0) {
        retval = NSUnionRange(retval, foundRange);
        
        searchRange = NSMakeRange(NSMaxRange(foundRange), self.text.length - NSMaxRange(foundRange));
        foundRange = [self.text rangeOfCharacterFromSet:characterSet options:0 range:searchRange];
    }
    
    // this ensures that strings like Joh| Smith will match John Smith
    
    return retval;
}
- (BBTokenDefaultTextAttachment *)_tokenTextAttachmentForRange:(NSRange)range index:(NSInteger *)index; {
    // if we don't have any text, the attachment is nil, otherwise search for an attachment clamped to the passed in range.location and the end of our text - 1
    BBTokenDefaultTextAttachment *retval = self.text.length == 0 ? nil : [self.attributedText attribute:NSAttachmentAttributeName atIndex:MIN(range.location, self.attributedText.length - 1) effectiveRange:NULL];
    
    if (index) {
        NSInteger outIndex = [self.representedObjects indexOfObject:retval.representedObject];
        
        if (outIndex == NSNotFound) {
            outIndex = self.representedObjects.count;
        }
        
        *index = outIndex;
    }
    
    return retval;
}

+ (NSCharacterSet *)_defaultTokenizingCharacterSet; {
    return [NSCharacterSet characterSetWithCharactersInString:@","];
}
+ (NSTimeInterval)_defaultCompletionDelay; {
    return 0.0;
}
+ (Class)_defaultCompletionTableViewCellClass {
    return [BBTokenCompletionDefaultTableViewCell class];
}
+ (Class)_defaultTokenTextAttachmentClass {
    return [BBTokenDefaultTextAttachment class];
}
+ (UIFont *)_defaultTypingFont; {
    return [UIFont systemFontOfSize:14.0];
}
+ (UIColor *)_defaultTypingTextColor; {
    return [UIColor blackColor];
}
#pragma mark Properties
- (void)setTableView:(UITableView *)tableView {
    _tableView = tableView;
    
    if (!_tableView) {
        [self setCompletions:nil];
    }
}
- (void)setCompletions:(NSArray *)completions {
    _completions = completions;
    
    [self.tableView reloadData];
}
#pragma mark Actions
- (IBAction)_tapGestureRecognizerAction:(id)sender {
    CGPoint location = [self.tapGestureRecognizer locationInView:self];
    
    // adjust the location by the text container insets
    location.x -= self.textContainerInset.left;
    location.y -= self.textContainerInset.top;
    
    // ask the layout manager for character index corresponding to the tapped location
    NSInteger index = [self.layoutManager characterIndexForPoint:location inTextContainer:self.textContainer fractionOfDistanceBetweenInsertionPoints:NULL];
    
    // if the index is within our text
    if (index < self.text.length) {
        // get the effective range for the token at index
        NSRange range;
        id value = [self.textStorage attribute:NSAttachmentAttributeName atIndex:index effectiveRange:&range];
        
        // if there is a token
        if (value) {
            // if our selection is zero length, select the entire range of the token
            if (self.selectedRange.length == 0) {
                [self setSelectedRange:range];
            }
            // otherwise set the selected range as zero length after the token
            else {
                [self setSelectedRange:NSMakeRange(NSMaxRange(range), 0)];
            }
        }
    }
}

@end