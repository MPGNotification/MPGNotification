//
//  MPGNotification.h
//  MPGNotification
//
//  Created by Gaurav Wadhwani on 28/06/14.
//  Copyright (c) 2014 Mappgic. All rights reserved.
//
//    The MIT License (MIT)
//
//    Copyright (c) 2014 Gaurav Wadhwani
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.
//
//  https://github.com/MPGNotification/MPGNotification

#import <UIKit/UIKit.h>

@class MPGNotification;

////////////////////////////////////////////////////////////////////////////////

//Animation types to allow different animation entrance options for the notification.
typedef NS_ENUM(NSInteger, MPGNotificationAnimationType) {
    MPGNotificationAnimationTypeLinear = 0,
    MPGNotificationAnimationTypeDrop,
    MPGNotificationAnimationTypeSnap
};

// Sets the UI configuration of buttons.
typedef NS_ENUM(NSInteger, MPGNotificationButtonConfigration) {
    MPGNotificationButtonConfigrationZeroButtons    = 0,
    MPGNotificationButtonConfigrationOneButton,
    MPGNotificationButtonConfigrationTwoButton,
    MPGNotificationButtonConfigrationCloseButton
};

// Block to handle button presses
typedef void (^MPGNotificationButtonHandler)(MPGNotification *notification, NSInteger buttonIndex);

// Block to handle Notification auto dismiss
typedef void (^MPGNotificationDismissHandler)(MPGNotification *notification);

////////////////////////////////////////////////////////////////////////////////

@interface MPGNotification : UIScrollView <UIScrollViewDelegate, UIDynamicAnimatorDelegate>

// Public accessors to private properties
@property (nonatomic, readonly) UIView *backgroundView; // to read tag value
@property (nonatomic, readonly) UIButton *firstButton; // to read tag value
@property (nonatomic, readonly) UIButton *secondButton;  // to read tag value
@property (nonatomic, readonly) UIButton *closeButton;  // to read tag value

// Properties used for basic styling
@property (nonatomic, strong) NSString *title; // required
@property (nonatomic, strong) NSString *subtitle; // optional
@property (nonatomic, strong) UIImage *iconImage; // optional
@property (nonatomic, strong) UIColor *backgroundColor; // optional

// Optional property specifying the view controller that displays the Notification. Defaults to nil; if nil, the current UIWindow's windowLevel value is used to cache and restore the state of the application.
@property (nonatomic, weak) UIViewController *hostViewController;

// Allows actions and dismissal when the background of the Notification is tapped. Defaults to YES.
@property (nonatomic) BOOL backgroundTapsEnabled;

// Allows 'swipe to dismiss' action on the Notification. Defaults to YES.
@property (nonatomic) BOOL swipeToDismissEnabled;

// Allows full-screen messages on iPad. Defaults to NO, similar to iOS Push Notifications.
@property (nonatomic) BOOL fullWidthMessages;

// To set the title color of the notification. Defaults to [UIColor whiteColor].
@property (nonatomic, strong) UIColor *titleColor;

// To set the subtitle color of the notification. Defaults to [UIColor whiteColor].
@property (nonatomic, strong) UIColor *subtitleColor;

// Set this to any positive value to automatically dismiss the Notification after the given duration. Defaults to 0.0;
@property (nonatomic) NSTimeInterval duration;

// Used to specify the type of animation that the notification should use to show and dismiss.
@property (nonatomic) MPGNotificationAnimationType animationType;

// Sets the button handler block directly; is also be set indirectly by calling showWithButtonHandler:
@property (nonatomic, copy) MPGNotificationButtonHandler buttonHandler;

// Sets the dismiss hanlder block directly;
@property (nonatomic, copy) MPGNotificationDismissHandler dismissHandler;

// Convenience initializer class methods (for manual setup, use init)
+ (MPGNotification *)notificationWithTitle:(NSString *)title subtitle:(NSString *)subtitle backgroundColor:(UIColor *)color iconImage:(UIImage *)image;
+ (MPGNotification *)notificationWithHostViewController:(UIViewController *)hostViewController title:(NSString *)title subtitle:(NSString *)subtitle backgroundColor:(UIColor *)color iconImage:(UIImage *)image;

// Sets the configuration and titles for the Notification's visible buttons. The number of buttonTitles supplied must match the configuration.
- (void)setButtonConfiguration:(MPGNotificationButtonConfigration)configuration withButtonTitles:(NSArray *)buttonTitles;

// Shows the notification on screen, optionally with a button handler completion block.
- (void)show;
- (void)showWithButtonHandler:(MPGNotificationButtonHandler)completionBlock;

// Dismiss the notification. Occurs automatically if any enabled button is pressed.
- (void)dismissWithAnimation:(BOOL)animated;

@end