//
//  CKCircleMenuView.m
//
//  Created by Christian Klaproth on 31.08.14.
//  Copyright (c) 2014 Christian Klaproth. All rights reserved.
//

#import "CKCircleMenuView.h"

@interface CKCircleMenuView()

@property (nonatomic) NSMutableArray* buttons;
@property (weak, nonatomic) UIGestureRecognizer* recognizer;
@property (nonatomic) int hoverTag;

@property (nonatomic) UIColor* innerViewColor;
@property (nonatomic) UIColor* innerViewActiveColor;
@property (nonatomic) UIColor* borderViewColor;
@property (nonatomic) CGFloat radius;
@property (nonatomic) CGFloat maxAngle;
@property (nonatomic) CGFloat animationDelay;
@property (nonatomic) CGFloat startingAngle;
@property (nonatomic) BOOL depth;
@property (nonatomic) CGFloat buttonRadius;
@property (nonatomic) CGFloat buttonBorderWidth;
@property (nonatomic) BOOL tapMode;
@property (nonatomic) BOOL absurdLineMode;
@property (nonatomic) BOOL visualFxMode;
@property (nonatomic) BOOL buttonTintMode;
@property (nonatomic) BOOL allowAnimationInteraction;
@property (nonatomic) BOOL buttonTitleVisible;
@property (nonatomic) CGFloat buttonTitleFontSize;

@property (nonatomic, weak) UIView* clippingView;

@end

// each button is made up of two views (button image, and background view)
// the buttons get tagged, starting at 1
// components are identified by adding the corresponding offset to the button's logical tag
static int TAG_BUTTON_OFFSET = 100;
static int TAG_INNER_VIEW_OFFSET = 1000;

// constants used for the configuration dictionary
NSString* const CIRCLE_MENU_BUTTON_BACKGROUND_NORMAL = @"kCircleMenuNormal";
NSString* const CIRCLE_MENU_BUTTON_BACKGROUND_ACTIVE = @"kCircleMenuActive";
NSString* const CIRCLE_MENU_BUTTON_BORDER = @"kCircleMenuBorder";
NSString* const CIRCLE_MENU_OPENING_DELAY = @"kCircleMenuDelay";
NSString* const CIRCLE_MENU_RADIUS = @"kCircleMenuRadius";
NSString* const CIRCLE_MENU_MAX_ANGLE = @"kCircleMenuMaxAngle";
NSString* const CIRCLE_MENU_DIRECTION = @"kCircleMenuDirection";
NSString* const CIRCLE_MENU_DEPTH = @"kCircleMenuDepth";
NSString* const CIRCLE_MENU_BUTTON_RADIUS = @"kCircleMenuButtonRadius";
NSString* const CIRCLE_MENU_BUTTON_BORDER_WIDTH = @"kCircleMenuButtonBorderWidth";
NSString* const CIRCLE_MENU_TAP_MODE = @"kCircleMenuTapMode";
NSString* const CIRCLE_MENU_LINE_MODE = @"kCircleMenuLineMode";
NSString* const CIRCLE_MENU_BACKGROUND_BLUR = @"kCircleMenuBackgroundBlur";
NSString* const CIRCLE_MENU_BUTTON_TINT = @"kCircleMenuButtonTint";
NSString* const CIRCLE_MENU_ALLOW_ANIMATION_INTERACTION = @"kCircleMenuAllowAnimationInteraction";
NSString* const CIRCLE_MENU_STARTING_ANGLE = @"kCircleMenuStartingAngle";
NSString* const CIRCLE_MENU_BUTTON_TITLE_VISIBLE = @"kCircleMenuButtonTitleVisible";
NSString* const CIRCLE_MENU_BUTTON_TITLE_FONT_SIZE = @"kCircleMenuButtonTitleFontSize";

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
            // if CIRCLE_MENU_STARTING_ANGLE is set, override startingAngle derived from direction
            if ([anOptionsDictionary valueForKey:CIRCLE_MENU_STARTING_ANGLE]) {
                self.startingAngle = [[anOptionsDictionary valueForKey:CIRCLE_MENU_STARTING_ANGLE] doubleValue];
            }
            self.depth = [[anOptionsDictionary valueForKey:CIRCLE_MENU_DEPTH] boolValue];
            self.buttonRadius = [[anOptionsDictionary valueForKey:CIRCLE_MENU_BUTTON_RADIUS] doubleValue];
            self.buttonBorderWidth = [[anOptionsDictionary valueForKey:CIRCLE_MENU_BUTTON_BORDER_WIDTH] doubleValue];
            self.tapMode = [[anOptionsDictionary valueForKey:CIRCLE_MENU_TAP_MODE] boolValue];
            self.absurdLineMode = [[anOptionsDictionary valueForKey:CIRCLE_MENU_LINE_MODE] boolValue];
            if (self.absurdLineMode) {
                self.startingAngle += 90.0;
            }
            self.visualFxMode = [[anOptionsDictionary valueForKey:CIRCLE_MENU_BACKGROUND_BLUR] boolValue];
            self.buttonTintMode = [[anOptionsDictionary valueForKey:CIRCLE_MENU_BUTTON_TINT] boolValue];
            self.allowAnimationInteraction = [[anOptionsDictionary valueForKey:CIRCLE_MENU_ALLOW_ANIMATION_INTERACTION] boolValue];
            self.buttonTitleVisible = [[anOptionsDictionary valueForKey:CIRCLE_MENU_BUTTON_TITLE_VISIBLE] boolValue];
            self.buttonTitleFontSize = [[anOptionsDictionary valueForKey:CIRCLE_MENU_BUTTON_TITLE_FONT_SIZE] doubleValue];
            if (!self.buttonTitleFontSize) {
                self.buttonTitleFontSize = 11.0;
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
            self.depth = NO;
            self.buttonRadius = 39.0;
            self.buttonBorderWidth = 2.0;
            self.tapMode = NO;
            self.absurdLineMode = NO;
            self.visualFxMode = NO;
            self.buttonTintMode = NO;
            self.allowAnimationInteraction = NO;
            self.buttonTitleVisible = NO;
            self.buttonTitleFontSize = 11.0;
        }
    }
    return self;
}

- (id)initAtOrigin:(CGPoint)aPoint usingOptions:(NSDictionary *)anOptionsDictionary withImageArray:(NSArray *)anImageArray
{
    self = [self initAtOrigin:aPoint usingOptions:anOptionsDictionary withImageArray:anImageArray andTitles:@[]];
    return self;
}

- (id)initAtOrigin:(CGPoint)aPoint usingOptions:(NSDictionary*)anOptionsDictionary withImageArray:(NSArray*)anImageArray andTitles:(NSArray*)aTitleArray;
{
    self = [self initWithOptions:anOptionsDictionary];
    if (self) {
        int tTag = 1;
        for (UIImage* img in anImageArray) {
            UIView* tView;
            if ([aTitleArray count] >= tTag) {
                tView = [self createButtonViewWithImage:img andTag:tTag andTitle:aTitleArray[tTag-1]];
            } else {
                tView = [self createButtonViewWithImage:img andTag:tTag andTitle:nil];
            }
            [self.buttons addObject:tView];
            tTag += 1;
        }
        
        self.frame = [self calculateFrameWithOrigin:aPoint];
    }
    return self;
}

- (id)initAtOrigin:(CGPoint)aPoint usingOptions:(NSDictionary *)anOptionsDictionary withImages:(UIImage *)anImage, ...
{
    self = [self initWithOptions:anOptionsDictionary];
    if (self) {
        int tTag = 1;
        va_list args;
        va_start(args, anImage);
        for (UIImage* img = anImage; img != nil; img = va_arg(args, UIImage*)) {
            UIView* tView = [self createButtonViewWithImage:img andTag:tTag andTitle:nil];
            [self.buttons addObject:tView];
            tTag += 1;
        }
        va_end(args);

        self.frame = [self calculateFrameWithOrigin:aPoint];
    }
    return self;
}

- (CGRect)calculateFrameWithOrigin:(CGPoint)aPoint {

    CGRect tFrame;

    if (self.absurdLineMode) {

        // calculate maximum bounding box, independent of actual direction
        CGFloat tMaximumButtonDistance = (2 * self.buttonRadius + 8.0) * self.buttons.count;
        tFrame = CGRectMake(aPoint.x - self.radius - tMaximumButtonDistance,
                            aPoint.y - self.radius - tMaximumButtonDistance,
                            self.radius * 2 + tMaximumButtonDistance * 2,
                            self.radius * 2 + tMaximumButtonDistance * 2);

    } else {

        tFrame = CGRectMake(aPoint.x - self.radius - self.buttonRadius,
                            aPoint.y - self.radius - self.buttonRadius,
                            self.radius * 2 + self.buttonRadius * 2,
                            self.radius * 2 + self.buttonRadius * 2);
    }

    return tFrame;
}

/**
 * Convenience method that creates a circle button, consisting of
 * the image, a background and a border.
 * @param anImage image to be used as button's icon
 * @param aTag unique identifier (should be index + 1)
 * @return UIView to be used as button
 */
- (UIView*)createButtonViewWithImage:(UIImage*)anImage andTag:(int)aTag andTitle:(NSString*)aTitle
{
    UIButton* tButton;
    if (self.buttonTintMode) {
        tButton = [UIButton buttonWithType:UIButtonTypeSystem];
    } else {
        tButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }

    if (self.absurdLineMode) {
        tButton.frame = CGRectMake(0.0, 0.0, self.buttonRadius * 2, self.buttonRadius * 2);
    } else {
        CGFloat tButtonViewX = self.buttonRadius - anImage.size.width / 2;
        CGFloat tButtonViewY = self.buttonRadius - anImage.size.height / 2;
        tButton.frame = CGRectMake(tButtonViewX, tButtonViewY, anImage.size.width, anImage.size.height);
    }

    [tButton setImage:anImage forState:UIControlStateNormal];
    tButton.tag = aTag + TAG_BUTTON_OFFSET;

    UIView* tInnerView = [[CKRoundView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.buttonRadius * 2, self.buttonRadius * 2)];
    tInnerView.backgroundColor = self.innerViewColor;
    tInnerView.opaque = YES;
    tInnerView.clipsToBounds = NO;
    tInnerView.layer.cornerRadius = self.buttonRadius;
    tInnerView.layer.borderColor = [self.borderViewColor CGColor];
    tInnerView.layer.borderWidth = self.buttonBorderWidth;

    if (self.depth) {
        [self applyInactiveDepthToButtonView:tInnerView];
    }

    // Support for displaying button titles
    if (self.buttonTitleVisible && aTitle) {
        UILabel* tLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, self.buttonRadius * 2 - self.buttonTitleFontSize * 2.15, self.buttonRadius * 2, self.buttonTitleFontSize + 2.0)];
        tLabel.textAlignment = NSTextAlignmentCenter;
        tLabel.font = [UIFont systemFontOfSize:self.buttonTitleFontSize];
        tLabel.textColor = self.borderViewColor;
        tLabel.text = aTitle;
        tLabel.userInteractionEnabled = NO;
        [tInnerView addSubview:tLabel];
        
        // Make some space for label below button
        tButton.layer.affineTransform = CGAffineTransformMakeTranslation(0.0, -self.buttonTitleFontSize / 1.9);
    }

    tInnerView.tag = aTag + TAG_INNER_VIEW_OFFSET;
    [tInnerView addSubview:tButton];

    if (self.tapMode) {
        [tButton addTarget:self action:@selector(circleButtonTapped:) forControlEvents:UIControlEventTouchDown];
        UITapGestureRecognizer* temporaryRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:temporaryRecognizer];
    }

    if (self.visualFxMode) {
        UIVisualEffectView* tEffectsView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        tEffectsView.frame = CGRectMake(0.0, 0.0, self.buttonRadius * 2, self.buttonRadius * 2);
        tInnerView.backgroundColor = [UIColor clearColor];
        [tEffectsView.contentView addSubview:tInnerView];
        tEffectsView.clipsToBounds = YES;
        tEffectsView.layer.cornerRadius = self.buttonRadius;
        return tEffectsView;
    }

    return tInnerView;
}

/**
 * Does the math to put buttons on a circle.
 */
- (void)calculateButtonPositions
{
    if (!self.clippingView) {
        // climb view hierarchy up, until first view with clipToBounds = YES
        self.clippingView = [self clippingViewOfChild:self];
    }
    CGFloat tMaxX = self.frame.size.width - self.buttonRadius;
    CGFloat tMinX = self.buttonRadius;
    CGFloat tMaxY = self.frame.size.height - self.buttonRadius;
    CGFloat tMinY = self.buttonRadius;
    if (self.clippingView) {
        CGRect tClippingFrame = [self.clippingView convertRect:self.clippingView.bounds toView:self];
        tMaxX = tClippingFrame.size.width + tClippingFrame.origin.x - self.buttonRadius * 2;
        tMinX = tClippingFrame.origin.x;
        tMaxY = tClippingFrame.size.height + tClippingFrame.origin.y - self.buttonRadius * 2;
        tMinY = tClippingFrame.origin.y;
    }

    int tCounter = 0;
    // issue #1 - align buttons perfectly on circle of max angle is 360.0
    if (self.maxAngle == 360.0) {
        self.maxAngle = 360.0 - 360.0 / self.buttons.count;
    }

    for (UIView* tView in self.buttons) {

        CGSize tSize = tView.frame.size;
        CGPoint tPoint = [self calculateButtonPositionAtIndex:tCounter];

        CGFloat tX = tPoint.x;
        CGFloat tY = tPoint.y;

        if (tX > tMaxX) tX = tMaxX;
        if (tX < tMinX) tX = tMinX;
        if (tY > tMaxY) tY = tMaxY;
        if (tY < tMinY) tY = tMinY;

        CGRect tRect = CGRectMake(tX, tY, tSize.width, tSize.height);
        tView.frame = tRect;
        tCounter++;
    }
}

- (CGPoint)calculateButtonPositionAtIndex:(int)index
{
    if (self.absurdLineMode) {
        // Align button positions along a line starting at origin with startingAngle
        CGSize tSize = [self.buttons[index] frame].size;
        CGPoint tOrigin = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        CGFloat tDistance = self.radius + (index * (2 * self.buttonRadius + 8.0));
        CGFloat tX = tOrigin.x - (tDistance * cosf(self.startingAngle / 180.0 * M_PI)) - (tSize.width / 2);
        CGFloat tY = tOrigin.y - (tDistance * sinf(self.startingAngle / 180.0 * M_PI)) - (tSize.width / 2);
        return CGPointMake(tX, tY);
    } else {
        CGFloat tCurrentAngle;
        if (self.buttons.count < 2) {
            // #7 special (center) alignment, if there is only one button
            tCurrentAngle = self.startingAngle + self.maxAngle / 2;
        } else {
            tCurrentAngle = self.startingAngle + (self.maxAngle / (self.buttons.count - 1)) * index;
        }
        CGSize tSize = [self.buttons[index] frame].size;
        CGPoint tOrigin = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        CGFloat tX = tOrigin.x - (self.radius * cosf(tCurrentAngle / 180.0 * M_PI)) - (tSize.width / 2);
        CGFloat tY = tOrigin.y - (self.radius * sinf(tCurrentAngle / 180.0 * M_PI)) - (tSize.width / 2);
        return CGPointMake(tX, tY);
    }
}

/**
 * Climbs up the view hierarchy to find the first which has clipToBounds = YES.
 * Returns the topmost view if no view has clipsToBound set to YES.
 * @return UIView with clipToBounds = YES
 */
- (UIView*)clippingViewOfChild:(UIView*)aView
{
    UIView* tView = [aView superview];
    if (tView) {
        if (tView.clipsToBounds) {
            return tView;
        } else {
            return [self clippingViewOfChild:tView];
        }
    } else {
        return aView;
    }
}

- (void)openMenuWithRecognizer:(UIGestureRecognizer*)aRecognizer
{
    self.recognizer = aRecognizer;

    // use target action to get notified upon gesture changes
    [self.recognizer addTarget:self action:@selector(gestureChanged:)];

    [self openMenu];
}

- (void)openMenu
{
    CGPoint tOrigin = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    [self calculateButtonPositions];
    for (UIView* tButtonView in self.buttons) {
        [self addSubview:tButtonView];
        tButtonView.alpha = 0.0;
        CGFloat tDiffX = tOrigin.x - tButtonView.frame.origin.x - self.buttonRadius;
        CGFloat tDiffY = tOrigin.y - tButtonView.frame.origin.y - self.buttonRadius;
        tButtonView.transform = CGAffineTransformMakeTranslation(tDiffX, tDiffY);
    }

    CGFloat tDelay = 0.0;
    for (UIView* tButtonView in self.buttons) {
        tDelay = tDelay + self.animationDelay;
        [UIView animateWithDuration:0.6 delay:tDelay usingSpringWithDamping:0.5 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveEaseOut|(self.allowAnimationInteraction ? UIViewAnimationOptionAllowUserInteraction : 0) animations:^{
            tButtonView.alpha = 1.0;
            tButtonView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {

        }];
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(circleMenuOpened)]) {
        [self.delegate circleMenuOpened];
    }
}

/**
 * Performs the closing animation.
 */
- (void)closeMenu
{
    if (!self.tapMode) {
        [self.recognizer removeTarget:self action:@selector(gestureChanged:)];
    }

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
        [self resetButtonState];

        // display this button in active color
        tTag = tTag + TAG_INNER_VIEW_OFFSET;
        UIView* tInnerView = [self viewWithTag:tTag];
        tInnerView.backgroundColor = self.innerViewActiveColor;
        if (self.depth) {
            [self applyActiveDepthToButtonView:tInnerView];
        }
    } else {
        // the view "hit" is none of the buttons -> display all in normal state
        [self resetButtonState];
        self.hoverTag = 0;
    }
}

- (void)resetButtonState
{
    for (int i = 1; i <= self.buttons.count; i++) {
        UIView* tView = [self viewWithTag:i + TAG_INNER_VIEW_OFFSET];
        tView.backgroundColor = self.innerViewColor;
        if (self.depth) {
            [self applyInactiveDepthToButtonView:tView];
        }
    }
}

- (void)applyInactiveDepthToButtonView:(UIView*)aView
{
    aView.layer.shadowColor = [[UIColor blackColor] CGColor];
    aView.layer.shadowOffset = CGSizeMake(4,2);
    aView.layer.shadowRadius = 8;
    aView.layer.shadowOpacity = 0.35;
    aView.layer.affineTransform = CGAffineTransformMakeScale(1.0, 1.0);
}

- (void)applyActiveDepthToButtonView:(UIView*)aView
{
    aView.layer.shadowColor = [[UIColor blackColor] CGColor];
    aView.layer.shadowOffset = CGSizeMake(2,1);
    aView.layer.shadowRadius = 5;
    aView.layer.shadowOpacity = 0.42;
    aView.layer.affineTransform = CGAffineTransformMakeScale(0.985, 0.985);
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

- (void)handleTap:(UITapGestureRecognizer*)sender
{
    [self closeMenu];
}

- (void)circleButtonTapped:(UIButton*)sender
{
    int tTag = [self bareTagOfView:sender];
    if (tTag > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(circleMenuActivatedButtonWithIndex:)]) {
            [self.delegate circleMenuActivatedButtonWithIndex:tTag-1];
        }
        // set as hover tag for activation animation
        self.hoverTag = tTag;
    }
    [self closeMenu];
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
    CGFloat tRadius = self.bounds.size.width / 2;
    CGFloat tDiffX = tRadius - point.x;
    CGFloat tDiffY = tRadius - point.y;
    CGFloat tDistanceSquared = tDiffX * tDiffX + tDiffY * tDiffY;
    CGFloat tRadiusSquared = tRadius * tRadius;
    return tDistanceSquared < tRadiusSquared;
}

@end
