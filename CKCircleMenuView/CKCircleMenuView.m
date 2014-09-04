//
//  CKCircleMenuView.m
//
//  Created by Christian Klaproth on 31.08.14.
//  Copyright (c) 2014 Christian Klaproth. All rights reserved.
//

#import "CKCircleMenuView.h"

@interface CKCircleMenuView()

@property (nonatomic) NSMutableArray* buttons;
@property (weak, nonatomic) UILongPressGestureRecognizer* recognizer;
@property (nonatomic) int hoverTag;

@property (nonatomic) UIColor* innerViewColor;
@property (nonatomic) UIColor* innerViewActiveColor;
@property (nonatomic) UIColor* borderViewColor;
@property (nonatomic) CGFloat radius;
@property (nonatomic) CGFloat maxAngle;
@property (nonatomic) CGFloat animationDelay;
@property (nonatomic) CGFloat startingAngle;

@end

// each button is made up of three views (button image, background and border)
// the buttons get tagged, starting at 1
// components are identified by adding the corresponding offset to the button's tag
static int TAG_BUTTON_OFFSET = 100;
static int TAG_INNER_VIEW_OFFSET = 1000;
static int TAG_BORDER_OFFSET = 10000;

// constants used for the configuration dictionary
NSString* const CIRCLE_MENU_BUTTON_BACKGROUND_NORMAL = @"kCircleMenuNormal";
NSString* const CIRCLE_MENU_BUTTON_BACKGROUND_ACTIVE = @"kCircleMenuActive";
NSString* const CIRCLE_MENU_BUTTON_BORDER = @"kCircleMenuBorder";
NSString* const CIRCLE_MENU_OPENING_DELAY = @"kCircleMenuDelay";
NSString* const CIRCLE_MENU_RADIUS = @"kCircleMenuRadius";
NSString* const CIRCLE_MENU_MAX_ANGLE = @"kCircleMenuMaxAngle";
NSString* const CIRCLE_MENU_DIRECTION = @"kCircleMenuDirection";

@implementation CKCircleMenuView

- (id)initWithOptions:(NSDictionary*)anOptionsDictionary
{
    self = [super init];
    if (self) {
        self.buttons = [NSMutableArray new];
        if (anOptionsDictionary) {
            self.innerViewColor = [anOptionsDictionary valueForKey:CIRCLE_MENU_BUTTON_BACKGROUND_NORMAL];
            self.innerViewActiveColor = [anOptionsDictionary valueForKey:CIRCLE_MENU_BUTTON_BACKGROUND_ACTIVE];
            self.borderViewColor = [anOptionsDictionary valueForKey:CIRCLE_MENU_BUTTON_BORDER];
            self.animationDelay = [[anOptionsDictionary valueForKey:CIRCLE_MENU_OPENING_DELAY] doubleValue];
            self.radius = [[anOptionsDictionary valueForKey:CIRCLE_MENU_RADIUS] doubleValue];
            self.maxAngle = [[anOptionsDictionary valueForKey:CIRCLE_MENU_MAX_ANGLE] doubleValue];
            switch ([[anOptionsDictionary valueForKey:CIRCLE_MENU_DIRECTION] integerValue]) {
                case CircleMenuDirectionUp:
                    self.startingAngle = 0.0;
                    break;
                case CircleMenuDirectionRight:
                    self.startingAngle = 90.0;
                    break;
                case CircleMenuDirectionDown:
                    self.startingAngle = 180.0;
                    break;
                case CircleMenuDirectionLeft:
                    self.startingAngle = 270.0;
                    break;
            }
        } else {
            // using some default settings
            self.innerViewColor = [UIColor colorWithRed:0.0 green:0.25 blue:0.5 alpha:1.0];
            self.innerViewActiveColor = [UIColor colorWithRed:0.25 green:0.5 blue:0.75 alpha:1.0];
            self.borderViewColor = [UIColor whiteColor];
            self.animationDelay = 0.0;
            self.radius = 65.0;
            self.maxAngle = 180.0;
            self.startingAngle = 0.0;
        }
    }
    return self;
}

- (id)initAtOrigin:(CGPoint)aPoint usingOptions:(NSDictionary *)anOptionsDictionary withImageArray:(NSArray *)anImageArray
{
    self = [self initWithOptions:anOptionsDictionary];
    if (self) {
        self.frame = CGRectMake(aPoint.x - self.radius - 39.0, aPoint.y - self.radius - 39.0, self.radius * 2 + 78.0, self.radius * 2 + 78.0);
        int tTag = 1;
        for (UIImage* img in anImageArray) {
            UIView* tView = [self createButtonViewWithImage:img andTag:tTag];
            [self.buttons addObject:tView];
            tTag++;
        }
    }
    return self;
}

- (id)initAtOrigin:(CGPoint)aPoint usingOptions:(NSDictionary *)anOptionsDictionary withImages:(UIImage *)anImage, ...
{
    self = [self initWithOptions:anOptionsDictionary];
    if (self) {
        self.frame = CGRectMake(aPoint.x - self.radius - 39.0, aPoint.y - self.radius - 39.0, self.radius * 2 + 78.0, self.radius * 2 + 78.0);
        int tTag = 1;
        va_list args;
        va_start(args, anImage);
        for (UIImage* img = anImage; img != nil; img = va_arg(args, UIImage*)) {
            UIView* tView = [self createButtonViewWithImage:img andTag:tTag];
            [self.buttons addObject:tView];
            tTag++;
        }
        va_end(args);
    }
    return self;
}

/**
 * Convenience method that creates a circle button, consisting of
 * the image, a background and a border.
 * @param anImage image to be used as button's icon
 * @param aTag unique identifier (should be index + 1)
 * @return UIView to be used as button
 */
- (UIView*)createButtonViewWithImage:(UIImage*)anImage andTag:(int)aTag
{
    UIButton* tButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tButton.frame = CGRectMake(21.0, 21.0, 32.0, 32.0);
    [tButton setImage:anImage forState:UIControlStateNormal];
    tButton.tag = aTag + TAG_BUTTON_OFFSET;
    
    UIView* tInnerView = [[CKRoundView alloc] initWithFrame:CGRectMake(2.0, 2.0, 74.0, 74.0)];
    tInnerView.backgroundColor = self.innerViewColor;
    tInnerView.opaque = YES;
    tInnerView.clipsToBounds = YES;
    tInnerView.layer.cornerRadius = 37.0;
    tInnerView.tag = aTag + TAG_INNER_VIEW_OFFSET;
    [tInnerView addSubview:tButton];
    
    UIView* tBorderView = [[CKRoundView alloc] initWithFrame:CGRectMake(0.0, 0.0, 78.0, 78.0)];
    tBorderView.backgroundColor = self.borderViewColor;
    tBorderView.opaque = YES;
    tBorderView.clipsToBounds = YES;
    tBorderView.layer.cornerRadius = 39.0;
    tBorderView.tag = aTag + TAG_BORDER_OFFSET;
    [tBorderView addSubview:tInnerView];
    
    return tBorderView;
}

/**
 * Does the math to put buttons on a circle.
 */
- (void)calculateButtonPositions
{
    int tButtonCount = (int)self.buttons.count;
    CGPoint tOrigin = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    CGFloat tRadius = self.radius;
    int tCounter = 0;
    for (UIView* tView in self.buttons) {
        CGFloat tCurrentWinkel;
        if (tCounter == 0) {
            tCurrentWinkel = self.startingAngle + 0.0;
        } else if (tCounter > 0 && tCounter < tButtonCount) {
            tCurrentWinkel = self.startingAngle + (self.maxAngle / (tButtonCount - 1)) * tCounter;
        } else {
            tCurrentWinkel = self.startingAngle + self.maxAngle;
        }
        CGSize tSize = tView.frame.size;
        CGFloat tX = tOrigin.x - (tRadius * cosf(tCurrentWinkel / 180.0 * M_PI)) - (tSize.width / 2);
        CGFloat tY = tOrigin.y - (tRadius * sinf(tCurrentWinkel / 180.0 * M_PI)) - (tSize.width / 2);
        CGRect tRect = CGRectMake(tX, tY, tSize.width, tSize.height);
        tView.frame = tRect;
        tCounter++;
    }
}

- (void)openMenuWithRecognizer:(UILongPressGestureRecognizer*)aRecognizer
{
    self.recognizer = aRecognizer;
    // use target action to get notified upon gesture changes
    [aRecognizer addTarget:self action:@selector(gestureChanged:)];
    
    CGPoint tOrigin = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    [self calculateButtonPositions];
    for (UIView* tButtonView in self.buttons) {
        [self addSubview:tButtonView];
        tButtonView.alpha = 0.0;
        CGFloat tDiffX = tOrigin.x - tButtonView.frame.origin.x - 39.0;
        CGFloat tDiffY = tOrigin.y - tButtonView.frame.origin.y - 39.0;
        tButtonView.transform = CGAffineTransformMakeTranslation(tDiffX, tDiffY);
    }

    CGFloat tDelay = 0.0;
    for (UIView* tButtonView in self.buttons) {
        tDelay = tDelay + self.animationDelay;
        [UIView animateWithDuration:0.6 delay:tDelay usingSpringWithDamping:0.5 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveEaseOut animations:^{
            tButtonView.alpha = 1.0;
            tButtonView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
        
        }];
    }
}

/**
 * Performs the closing animation.
 */
- (void)closeMenu
{
    [self.recognizer removeTarget:self action:@selector(gestureChanged:)];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        for (UIView* tButtonView in self.buttons) {
            if (self.hoverTag > 0 && self.hoverTag == [self bareTagOfView:tButtonView]) {
                tButtonView.transform = CGAffineTransformMakeScale(1.8, 1.8);
            }
            tButtonView.alpha = 0.0;
        }
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (self.delegate && [self.delegate respondsToSelector:@selector(circleMenuClosed)]) {
            [self.delegate circleMenuClosed];
        }
    }];
}

- (void)gestureMovedToPoint:(CGPoint)aPoint
{
    UIView* tView = [self hitTest:aPoint withEvent:nil];
    int tTag = [self bareTagOfView:tView];
    if (tTag > 0) {
        if (tTag == self.hoverTag) {
            // this button is already the active one
            return;
        }
        
        self.hoverTag = tTag;
        
        // display all (other) buttons in normal state
        for (int i = 1; i <= self.buttons.count; i++) {
            UIView* tView = [self viewWithTag:i + TAG_INNER_VIEW_OFFSET];
            tView.backgroundColor = self.innerViewColor;
        }
        
        // display this button in active color
        tTag = tTag + TAG_INNER_VIEW_OFFSET;
        UIView* tInnerView = [self viewWithTag:tTag];
        tInnerView.backgroundColor = self.innerViewActiveColor;
    } else {
        // the view "hit" is none of the buttons -> display all in normal state
        for (int i = 1; i <= self.buttons.count; i++) {
            UIView* tView = [self viewWithTag:i + TAG_INNER_VIEW_OFFSET];
            tView.backgroundColor = self.innerViewColor;
        }
        
        self.hoverTag = 0;
    }
}

/**
 * Target action method that gets called when the gesture used to open
 * the CKCircleMenuView changes.
 */
- (void)gestureChanged:(UILongPressGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint tPoint = [sender locationInView:self];
        [self gestureMovedToPoint:tPoint];
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        // determine wether a button was hit when the gesture ended
        CGPoint tPoint = [sender locationInView:self];
        UIView* tView = [self hitTest:tPoint withEvent:nil];
        int tTag = [self bareTagOfView:tView];
        if (tTag > 0) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(circleMenuActivatedButtonWithIndex:)]) {
                [self.delegate circleMenuActivatedButtonWithIndex:tTag-1];
            }
        }
        [self closeMenu];
    }
}

/**
 * Return the 'virtual' tag of the button, no matter which of its components
 * (image, background, border) is passed as argument.
 * @param aView view to be examined
 * @return 'virtual' tag without offsets
 */
- (int)bareTagOfView:(UIView*)aView
{
    int tTag = (int)aView.tag;
    if (tTag > 0) {
        if (tTag >= TAG_BORDER_OFFSET) {
            tTag = tTag - TAG_BORDER_OFFSET;
        }
        if (tTag >= TAG_INNER_VIEW_OFFSET) {
            tTag = tTag - TAG_INNER_VIEW_OFFSET;
        }
        if (tTag >= TAG_BUTTON_OFFSET) {
            tTag = tTag - TAG_BUTTON_OFFSET;
        }
    }
    return tTag;
}

@end

@implementation CKRoundView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    // Pythagoras a^2 + b^2 = c^2
    CGFloat tDiffX = 39.0 - point.x;
    CGFloat tDiffY = 39.0 - point.y;
    CGFloat tDeltaX = tDiffX * tDiffX;
    CGFloat tDeltaY = tDiffY * tDiffY;
    CGFloat tDistanceSquared = tDeltaX + tDeltaY;
    CGFloat tRadiusSquared = 39.0 * 39.0;
    return tDistanceSquared < tRadiusSquared;
}

@end
