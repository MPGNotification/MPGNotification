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

//Animation types to allow different animation entrance options for the notification.
typedef enum {
    MPGNotificationAnimationTypeLinear = 0,
    MPGNotificationAnimationTypeDrop,
    MPGNotificationAnimationTypeSnap
} MPGNotificationAnimationType;

@protocol MPGNotificationDelegate;

@interface MPGNotification : UIView <UIDynamicAnimatorDelegate>

//Private property declarations.
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, weak) id <MPGNotificationDelegate> delegate;

//Optional parameters to allow customisation of the notification UI.

//To set the title color of the notification
@property (nonatomic) UIColor *titleColor;

//To set the subtitle color of the notification
@property (nonatomic) UIColor *subtitleColor;

//Used to specify the type of animation that the notification should use to enter the screen. Can be one of the types from MPGNotificationAnimationType enum specified above.
@property (nonatomic) MPGNotificationAnimationType animationType;

@property (nonatomic) NSTimeInterval duration;

//Initilisation method for the notification. Please note that -initWithFrame: will not properly initiliase the notification. Use this method instead. Pass the values that you need in the notification ('title' is mandatory, all other parameters are optional)
- (id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image backgroundColor:(UIColor *)color andButtonTitles:(NSArray *)buttonTitles;

//Call this method to show the notification on screen. Specify parameters like titleColor and animationType prior to calling this method
- (void)show;

//Call this method to dismiss the notification. The notification will dismiss in the same animation as it appeared on screen. If the 'animated' variable is set NO, the notification will disappear without any animation.
- (void)dismissWithAnimation:(BOOL)animated;

@end

@protocol MPGNotificationDelegate <NSObject>

//Delegate method to inform that the notification was dismissed by the user and which button index was tapped to the caller.
- (void)notificationView:(MPGNotification *)notification didDismissWithButtonIndex:(NSInteger)buttonIndex;

@end
