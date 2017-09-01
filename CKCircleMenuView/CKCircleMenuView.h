//
//  CKCircleMenuView.h
//
//  Created by Christian Klaproth on 31.08.14.
//  Copyright (c) 2014 Christian Klaproth. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CKCircleMenuDelegate <NSObject>

@optional

/**
 * Gets called when the CircleMenu has shown up.
 */
- (void)circleMenuOpened;
/**
 * Informs the delegate that the menu is going to be closed with
 * the button specified by the index being activated.
 */
- (void)circleMenuActivatedButtonWithIndex:(int)anIndex;
/**
 * Gets called when the CircleMenu has been closed. This is usually
 * sent immediately after circleMenuActivatedButtonWithIndex:.
 */
- (void)circleMenuClosed;

@end

// Constants used for the configuration dictionary
extern NSString* const CIRCLE_MENU_BUTTON_BACKGROUND_NORMAL;
extern NSString* const CIRCLE_MENU_BUTTON_BACKGROUND_ACTIVE;
extern NSString* const CIRCLE_MENU_BUTTON_BORDER;
extern NSString* const CIRCLE_MENU_OPENING_DELAY;
extern NSString* const CIRCLE_MENU_RADIUS;
extern NSString* const CIRCLE_MENU_MAX_ANGLE;
extern NSString* const CIRCLE_MENU_DIRECTION;
extern NSString* const CIRCLE_MENU_DEPTH;
extern NSString* const CIRCLE_MENU_BUTTON_RADIUS;
extern NSString* const CIRCLE_MENU_BUTTON_BORDER_WIDTH;
extern NSString* const CIRCLE_MENU_TAP_MODE;
extern NSString* const CIRCLE_MENU_LINE_MODE;
extern NSString* const CIRCLE_MENU_BACKGROUND_BLUR;
extern NSString* const CIRCLE_MENU_BUTTON_TINT;
extern NSString* const CIRCLE_MENU_ALLOW_ANIMATION_INTERACTION;
extern NSString* const CIRCLE_MENU_STARTING_ANGLE;
extern NSString* const CIRCLE_MENU_BUTTON_TITLE_VISIBLE;
extern NSString* const CIRCLE_MENU_BUTTON_TITLE_FONT_SIZE;

typedef enum {
    CircleMenuDirectionUp = 1,
    CircleMenuDirectionRight,
    CircleMenuDirectionDown,
    CircleMenuDirectionLeft
} CircleMenuDirection;

@interface CKCircleMenuView : UIView

@property (weak, nonatomic) id<CKCircleMenuDelegate> delegate;

/**
 * Initializes the CKCircleMenuView.
 * @param aPoint the center of the menu's circle
 * @param anOptionsDictionary optional configuration, may be nil
 * @param anImage dynamic list of images (nil-terminated!) to be
 *                used for the buttons, currently icon images should
 *                be 32x32 points (64x64 px for retina)
 */
- (id)initAtOrigin:(CGPoint)aPoint usingOptions:(NSDictionary*)anOptionsDictionary withImages:(UIImage*)anImage, ... NS_REQUIRES_NIL_TERMINATION;

/**
 * Initializes the CKCircleMenuView.
 * @param aPoint the center of the menu's circle
 * @param anOptionsDictionary optional configuration, may be nil
 * @param anImageArray array of images to be used for the buttons,
 *                     currently icon images should be 32x32 points
 *                     (64x64 px for retina)
 */
- (id)initAtOrigin:(CGPoint)aPoint usingOptions:(NSDictionary*)anOptionsDictionary withImageArray:(NSArray*)anImageArray;

/**
 * Initializes the CKCircleMenuView.
 * @param aPoint the center of the menu's circle
 * @param anOptionsDictionary optional configuration, may be nil
 * @param anImageArray array of images to be used for the buttons,
 *                     currently icon images should be 32x32 points
 *                     (64x64 px for retina)
 * @param aTitleArray array of strings with titles that are displayed
 *                    below the button icons
 */
- (id)initAtOrigin:(CGPoint)aPoint usingOptions:(NSDictionary*)anOptionsDictionary withImageArray:(NSArray*)anImageArray andTitles:(NSArray*)aTitleArray;

/**
 * Opens the menu with the buttons and settings specified in the
 * initializer.
 * @param aRecognizer the UILongPressGestureRecognizer that has been
 *                    used to detect the long press. This recognizer
 *                    will be used to track further drag gestures to
 *                    select a button and to close the menu, once the
 *                    gesture ends.
 */
- (void)openMenuWithRecognizer:(UIGestureRecognizer*)aRecognizer;

/**
 * Opens the menu with the buttons and settings specified in the
 * initializer. Use this method if the menu is not triggered by
 * a gesture recognizer but via tap e.g.
 */
- (void)openMenu;

/**
 * Offers the possibility to close the menu externally.
 */
- (void)closeMenu;

@end

@interface CKRoundView : UIView

@end
