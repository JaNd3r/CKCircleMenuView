CKCircleMenuView
================

Well, it's a circle menu. Kind of. For iOS.

[![Version](https://cocoapod-badges.herokuapp.com/v/CKCircleMenuView/badge.png)](http://cocoadocs.org/docsets/CKCircleMenuView)
[![Platform](https://cocoapod-badges.herokuapp.com/p/CKCircleMenuView/badge.png)](http://cocoadocs.org/docsets/CKCircleMenuView)

The idea is to keep your UI simple and clean and show buttons to the user when they are needed. The following screenshot is taken from the demo app I have provided in this repository. Simply clone this repo and call `pod install` within the CircleViewDemo folder. The circle menu is opened via a `UILongPressGesture`. As long as the user holds down his finger, the menu will remain open. Buttons are selected via dragging on the button and releasing the finger.

![](CircleMenuDemo1.gif) &nbsp; ![](CircleMenuDemo2.gif)

The following animation shows a depth effect (sorry for the poor gif quality, you have to see this in the demo app!). You can configure a mellow drop shadow to be rendered, which will transform slightly when the button is activated. At the same time, the button will be scaled a bit down, resulting in a super-subtle 3D effect.

![](CircleMenuDemoDepth.gif)

If you prefer not to spawn the menu out of nowehere (your users have to know where to long press in order to see the menu) but want to offer a menu button, you can use the `CKCircleMenuView` in _tap mode_. Once opened, the menu stays open until the user selects an option or closes the menu by tapping somewhere else.

![circlemenutapmode](https://cloud.githubusercontent.com/assets/7301252/11380734/32504124-92f8-11e5-97dc-6959e506cfe8.gif)

The CKCircleMenuView is designed for easy integration and usage. Spawning the menu and reacting on button activations is as easy as to use an ~~UIAlertView~~ (deprecated) UIAlertController.

## Features

There are several options that can be adjusted before presenting the menu.

* Number of buttons (either provided as an array of images or as a dynamic parameter list of images)
* Button's normal color
* Button's active (or say hover) color
* Button's border color
* Angle to be used for button placement (default = 180 degrees)
* Direction of the angle's center (default = `CircleMenuDirectionUp`)
* Radius of the button alignment (default = 65)
* Button's radius (half the width, default = 39)
* Button's border width (default = 2)
* Delay between button animations (default = 0.0 ms)
* Depth effect by using drop shadow and scaling (default = NO)
* Tap mode (default = NO)
* Line mode (default = NO)
* Tint mode uses the provided button image as an alpha mask, just like `UIButtonType.System` does (default = NO)
* Background blur mode ignores the background color and uses a `UIVisualEffectsView` as the button's background (default = NO)

## Installation

### CocoaPods

Add `pod 'CKCircleMenuView'` to your `Podfile`, run `pod install` and you are ready to go.

### Swift

If you are using the `CKCircleMenuView` in a Swift project, add the following line to your Objective-C bridging header.

```objc
#import <CKCircleMenuView/CKCircleMenuView.h>
```

In the Swift class you want to use the `CKCircleMenuView` add the following import statement.

```swift
import CKCircleMenuView
```
## Usage

Please take a look at the demo app included in this repo to see a fully working example on how the `CKCircleMenuView` is used.

Basically what you have to do is: In your Storyboard add a gesture recognizer for long presses on the view, that should spawn the `CKCircleMenuView` and connect it to an action method within your view controller. Alternatively - if you want to use the menu in tap mode - add a `UIButton` and connect its touch-up-inside event to an action method in your view controller. There are a few things that you need to implement.

* Determine the point where the triggering event occured (center of the `UIButton`'s frame or location of the long press gesture in your view). This will be used as the origin (center) of the `CKCircleMenuView`.
```swift
let tPoint = CGPointMake(CGRectGetMidX(button.frame), CGRectGetMidY(button.frame))
let tOrigin = self.view.convertPoint(tPoint, fromView: sender)
```
* Create an array of images which will be used to populate your menu with buttons (e.g. in `viewDidLoad`, if the menu's content isn't dynamic).
```swift
var circleMenuImageArray = Array<UIImage>()

override func viewDidLoad() {
  super.viewDidLoad()

  // ...
  self.circleMenuImageArray.append(UIImage(named: "InfoChartButton")!)
  self.circleMenuImageArray.append(UIImage(named: "CircleChartButton")!)
  self.circleMenuImageArray.append(UIImage(named: "BarChartButton")!)
  self.circleMenuImageArray.append(UIImage(named: "RealtimeButton")!)
  self.circleMenuImageArray.append(UIImage(named: "LineChartButton")!)
}
```
* Create a dictionary containing the configuration parameters for the menu.
```swift
var tOptions = Dictionary<String, AnyObject>()
tOptions[CIRCLE_MENU_OPENING_DELAY] = 0.1
tOptions[CIRCLE_MENU_MAX_ANGLE] = 180.0
tOptions[CIRCLE_MENU_RADIUS] = 105.0
tOptions[CIRCLE_MENU_DIRECTION] = Int(CircleMenuDirectionUp.rawValue)
tOptions[CIRCLE_MENU_BUTTON_BACKGROUND_NORMAL] = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
tOptions[CIRCLE_MENU_BUTTON_BACKGROUND_ACTIVE] = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
tOptions[CIRCLE_MENU_BUTTON_BORDER] = UIColor.whiteColor()
tOptions[CIRCLE_MENU_DEPTH] = 2.0
tOptions[CIRCLE_MENU_BUTTON_RADIUS] = 35.0
tOptions[CIRCLE_MENU_BUTTON_BORDER_WIDTH] = 2.0
tOptions[CIRCLE_MENU_TAP_MODE] = true
tOptions[CIRCLE_MENU_LINE_MODE] = false
tOptions[CIRCLE_MENU_BUTTON_TINT] = false
tOptions[CIRCLE_MENU_BACKGROUND_BLUR] = false
```
* Dispay the menu as follows (don't forget to add the `CKCircleMenuDelegate' as protocol).
```swift
self.circleMenuView = CKCircleMenuView(atOrigin: tOrigin, usingOptions: tOptions, withImageArray: self.circleMenuImageArray)
self.view.addSubview(self.circleMenuView!)
self.circleMenuView!.delegate = self
self.circleMenuView!.openMenu()
```
* Implement the methods of the `CKCircleMenuDelegate` protocol to react to menu events.
```swift
// MARK: Circle Menu Delegate

func circleMenuActivatedButtonWithIndex(anIndex: Int32) {
  // ...
}

func circleMenuOpened() {
  // ...
}

func circleMenuClosed() {
  // ...
}
```

## Author

Christian Klaproth, [@JaNd3r](http://twitter.com/JaNd3r)

## License

CKCircleMenuView is available under the MIT license. See the LICENSE file for more info.
