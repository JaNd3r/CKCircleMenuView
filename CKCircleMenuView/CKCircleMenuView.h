//
//  CKCircleMenuView.h
//
//  Created by Christian Klaproth on 31.08.14.
//  Copyright (c) 2014 Christian Klaproth. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CKCircleMenuDelegate <NSObject>

@optional

- (void)circleMenuOpened;
- (void)circleMenuActivatedButtonWithIndex:(int)anIndex;
- (void)circleMenuClosed;

@end

extern NSString* const CIRCLE_MENU_BUTTON_BACKGROUND_NORMAL;
extern NSString* const CIRCLE_MENU_BUTTON_BACKGROUND_ACTIVE;
extern NSString* const CIRCLE_MENU_BUTTON_BORDER;
extern NSString* const CIRCLE_MENU_OPENING_DELAY;
extern NSString* const CIRCLE_MENU_RADIUS;
extern NSString* const CIRCLE_MENU_MAX_ANGLE;
extern NSString* const CIRCLE_MENU_DIRECTION;

typedef enum {
    CircleMenuDirectionUp = 1,
    CircleMenuDirectionRight,
    CircleMenuDirectionDown,
    CircleMenuDirectionLeft
} CircleMenuDirection;

@interface CKCircleMenuView : UIView

@property (weak, nonatomic) id<CKCircleMenuDelegate> delegate;

- (id)initAtOrigin:(CGPoint)aPoint usingOptions:(NSDictionary*)anOptionsDictionary withImages:(UIImage*)anImage, ... NS_REQUIRES_NIL_TERMINATION;
- (id)initAtOrigin:(CGPoint)aPoint usingOptions:(NSDictionary*)anOptionsDictionary withImageArray:(NSArray*)anImageArray;
- (void)openMenuWithRecognizer:(UILongPressGestureRecognizer*)aRecognizer;
- (void)closeMenu;

@end
