//
//  ViewController.m
//  CircleMenuDemo
//
//  Created by Christian Klaproth on 03.09.14.
//  Copyright (c) 2014 Christian Klaproth. All rights reserved.
//

#import "ViewController.h"
#import "CKCircleMenuView.h"

@interface ViewController () <CKCircleMenuDelegate>

@property (weak, nonatomic) IBOutlet UISlider *buttonCountSlider;
@property (weak, nonatomic) IBOutlet UISlider *angleSlider;
@property (weak, nonatomic) IBOutlet UISwitch *delaySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *shadowSwitch;
@property (weak, nonatomic) IBOutlet UISlider *radiusSlider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *directionSegmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *demoAreaLabel;
@property (weak, nonatomic) IBOutlet UIButton *demoTapButton;

@property (nonatomic) NSArray* imageArray;
@property (nonatomic) CGFloat angle;
@property (nonatomic) CGFloat delay;
@property (nonatomic) int shadow;
@property (nonatomic) CGFloat radius;
@property (nonatomic) int direction;

@property (nonatomic) CKCircleMenuView* circleMenuView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.demoAreaLabel.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.25];
    
    self.imageArray = @[[UIImage imageNamed:@"Sample Icon"], [UIImage imageNamed:@"Sample Icon"], [UIImage imageNamed:@"Sample Icon"], [UIImage imageNamed:@"Sample Icon"]];
    self.direction = CircleMenuDirectionUp;
    self.delay = 0.0;
    self.shadow = 0;
    self.radius = 65.0;
    self.angle = 180.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonCountChanged:(UISlider *)sender
{
    NSMutableArray* tArray = [NSMutableArray new];
    for (int i=0; i<sender.value; i++) {
        [tArray addObject:[UIImage imageNamed:@"Sample Icon"]];
    }
    self.imageArray = [tArray copy];
}

- (IBAction)angleChanged:(UISlider *)sender
{
    self.angle = sender.value;
}

- (IBAction)delayChanged:(UISwitch *)sender
{
    if (sender.isOn) {
        self.delay = 0.1;
    } else {
        self.delay = 0.0;
    }
}

- (IBAction)shadowChanged:(UISwitch *)sender
{
    if (sender.isOn) {
        self.shadow = 1;
    } else {
        self.shadow = 0;
    }
}

- (IBAction)radiusChanged:(UISlider *)sender
{
    self.radius = sender.value;
}

- (IBAction)directionChanged:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case 0: self.direction = CircleMenuDirectionUp; break;
        case 1: self.direction = CircleMenuDirectionDown; break;
        case 2: self.direction = CircleMenuDirectionLeft; break;
        case 3: self.direction = CircleMenuDirectionRight; break;
    }
}

- (IBAction)longPressGestureRecognized:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        CGPoint tPoint = [sender locationInView:self.demoAreaLabel];
        
        NSMutableDictionary* tOptions = [NSMutableDictionary new];
        [tOptions setValue:[NSDecimalNumber numberWithFloat:self.delay] forKey:CIRCLE_MENU_OPENING_DELAY];
        [tOptions setValue:[NSDecimalNumber numberWithFloat:self.angle] forKey:CIRCLE_MENU_MAX_ANGLE];
        [tOptions setValue:[NSDecimalNumber numberWithFloat:self.radius] forKey:CIRCLE_MENU_RADIUS];
        [tOptions setValue:[NSNumber numberWithInt:self.direction] forKey:CIRCLE_MENU_DIRECTION];
        [tOptions setValue:[UIColor colorWithRed:0.0 green:0.25 blue:0.5 alpha:1.0] forKey:CIRCLE_MENU_BUTTON_BACKGROUND_NORMAL];
        [tOptions setValue:[UIColor colorWithRed:0.25 green:0.5 blue:0.75 alpha:1.0] forKey:CIRCLE_MENU_BUTTON_BACKGROUND_ACTIVE];
        [tOptions setValue:[UIColor whiteColor] forKey:CIRCLE_MENU_BUTTON_BORDER];
        [tOptions setValue:[NSNumber numberWithInt:self.shadow] forKey:CIRCLE_MENU_DEPTH];
        [tOptions setValue:[NSDecimalNumber decimalNumberWithString:@"40.0"] forKey:CIRCLE_MENU_BUTTON_RADIUS];
        [tOptions setValue:[NSDecimalNumber decimalNumberWithString:@"2.5"] forKey:CIRCLE_MENU_BUTTON_BORDER_WIDTH];
        [tOptions setValue:[NSNumber numberWithBool:NO] forKey:CIRCLE_MENU_TAP_MODE];
        [tOptions setValue:[NSNumber numberWithBool:NO] forKey:CIRCLE_MENU_LINE_MODE];
        [tOptions setValue:[NSNumber numberWithBool:NO] forKey:CIRCLE_MENU_BACKGROUND_BLUR];
        [tOptions setValue:[NSNumber numberWithBool:NO] forKey:CIRCLE_MENU_BUTTON_TINT];
        
        CKCircleMenuView* tMenu = [[CKCircleMenuView alloc] initAtOrigin:tPoint usingOptions:tOptions withImageArray:self.imageArray];
        tMenu.delegate = self;
        [self.demoAreaLabel addSubview:tMenu];
        [tMenu openMenuWithRecognizer:sender];
    }
}

- (IBAction)demoTapButtonTouchUpInside:(UIButton *)sender
{
    if (self.circleMenuView) {
        
        [self.circleMenuView closeMenu];
        self.circleMenuView = nil;
        [self.demoTapButton setTitle:@"Open" forState:UIControlStateNormal];
        
    } else {
        
        CGPoint tPoint = CGPointMake(CGRectGetMidX(sender.bounds), CGRectGetMidY(sender.bounds));
        tPoint = [self.view convertPoint:tPoint fromView:sender];

        NSMutableDictionary* tOptions = [NSMutableDictionary new];
        [tOptions setValue:[NSDecimalNumber numberWithFloat:self.delay] forKey:CIRCLE_MENU_OPENING_DELAY];
        [tOptions setValue:[NSDecimalNumber numberWithFloat:self.angle] forKey:CIRCLE_MENU_MAX_ANGLE];
        [tOptions setValue:[NSDecimalNumber numberWithFloat:self.radius] forKey:CIRCLE_MENU_RADIUS];
        [tOptions setValue:[NSNumber numberWithInt:self.direction] forKey:CIRCLE_MENU_DIRECTION];
        [tOptions setValue:[UIColor colorWithRed:0.0 green:0.25 blue:0.5 alpha:1.0] forKey:CIRCLE_MENU_BUTTON_BACKGROUND_NORMAL];
        [tOptions setValue:[UIColor colorWithRed:0.25 green:0.5 blue:0.75 alpha:1.0] forKey:CIRCLE_MENU_BUTTON_BACKGROUND_ACTIVE];
        [tOptions setValue:[UIColor whiteColor] forKey:CIRCLE_MENU_BUTTON_BORDER];
        [tOptions setValue:[NSNumber numberWithInt:self.shadow] forKey:CIRCLE_MENU_DEPTH];
        [tOptions setValue:[NSDecimalNumber decimalNumberWithString:@"40.0"] forKey:CIRCLE_MENU_BUTTON_RADIUS];
        [tOptions setValue:[NSDecimalNumber decimalNumberWithString:@"2.5"] forKey:CIRCLE_MENU_BUTTON_BORDER_WIDTH];
        [tOptions setValue:[NSNumber numberWithBool:YES] forKey:CIRCLE_MENU_TAP_MODE];
        [tOptions setValue:[NSNumber numberWithBool:YES] forKey:CIRCLE_MENU_LINE_MODE];
        [tOptions setValue:[NSNumber numberWithBool:YES] forKey:CIRCLE_MENU_BACKGROUND_BLUR];
        [tOptions setValue:[NSNumber numberWithBool:YES] forKey:CIRCLE_MENU_BUTTON_TINT];
        
        CKCircleMenuView* tMenu = [[CKCircleMenuView alloc] initAtOrigin:tPoint usingOptions:tOptions withImageArray:self.imageArray];
        tMenu.delegate = self;
        [self.view addSubview:tMenu];
        [tMenu openMenu];
        self.circleMenuView = tMenu;
    }
}

- (void)circleMenuActivatedButtonWithIndex:(int)anIndex
{
    UIAlertController* tController = [UIAlertController alertControllerWithTitle:@"Circle Menu Action" message:[NSString stringWithFormat:@"Button pressed at index %i.", anIndex] preferredStyle:UIAlertControllerStyleAlert];
    [tController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:tController animated:YES completion:^{
        self.circleMenuView = nil;
        [self.demoTapButton setTitle:@"Open" forState:UIControlStateNormal];
    }];
}

- (void)circleMenuClosed
{
    if (self.circleMenuView) {
        [self.circleMenuView closeMenu];
        self.circleMenuView = nil;
    }
    [self.demoTapButton setTitle:@"Open" forState:UIControlStateNormal];
}

- (void)circleMenuOpened
{
    [self.demoTapButton setTitle:@"Close" forState:UIControlStateNormal];
}

@end
