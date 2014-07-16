//
//    MPGNotification.h
//    MPGNotification
//
//    Created by Gaurav Wadhwani on 28/06/14.
//    Copyright (c) 2014 Mappgic. All rights reserved.
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


#import <UIKit/UIKit.h>

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
typedef void (^MPGNotificationButtonHandler)(NSInteger buttonIndex);

////////////////////////////////////////////////////////////////////////////////

@interface MPGNotification : UIView <UIDynamicAnimatorDelegate>

// Public accessors to private properties
@property (nonatomic, readonly) UIButton *firstButton; // to read tag value
@property (nonatomic, readonly) UIButton *secondButton;  // to read tag value
@property (nonatomic, readonly) UIButton *closeButton;  // to read tag value

//To set the title color of the notification
@property (nonatomic, strong) UIColor *titleColor;

//To set the subtitle color of the notification
@property (nonatomic, strong) UIColor *subtitleColor;

// Set this to any positive value to automatically dismiss the Notification after the given duration
@property (nonatomic) NSTimeInterval duration;

//Used to specify the type of animation that the notification should use to enter the screen. Can be one of the types from MPGNotificationAnimationType enum specified above.
@property (nonatomic) MPGNotificationAnimationType animationType;

// Sets the button handler block directly
@property (nonatomic, strong) MPGNotificationButtonHandler buttonHandler;

// Convenience initializer class method (for manual setup, use init)
+ (MPGNotification *)notificationWithTitle:(NSString *)title subtitle:(NSString *)subtitle backgroundColor:(UIColor *)color iconImage:(UIImage *)image;

// Sets the button configuration and button titles for the Notification
- (void)setButtonConfiguration:(MPGNotificationButtonConfigration)configuration withButtonTitles:(NSArray *)buttonTitles;

// Call this method to show the notification on screen. Specify parameters like titleColor and animationType prior to calling this method
- (void)show;
- (void)showWithButtonHandler:(MPGNotificationButtonHandler)completionBlock;

// Call this method to dismiss the notification. The notification will dismiss in the same animation as it appeared on screen. If the 'animated' variable is set NO, the notification will disappear without any animation.
- (void)dismissWithAnimation:(BOOL)animated;

@end