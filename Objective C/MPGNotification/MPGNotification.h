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

typedef enum {
    MPGNotificationAnimationTypeLinear = 0,
    MPGNotificationAnimationTypeDrop,
    MPGNotificationAnimationTypeSnap
} MPGNotificationAnimationType;

@protocol MPGNotificationDelegate;

@interface MPGNotification : UIView <UIDynamicAnimatorDelegate>

@property (nonatomic, strong) UIDynamicAnimator *animator;

@property (nonatomic, weak) id <MPGNotificationDelegate> delegate;
@property (nonatomic) UIColor *titleColor;
@property (nonatomic) UIColor *subtitleColor;
@property (nonatomic) MPGNotificationAnimationType animationType;

- (id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image backgroundColor:(UIColor *)color andButtonTitles:(NSArray *)buttonTitles;

- (void)show;
- (void)dismissWithAnimation:(BOOL)animated;

@end

@protocol MPGNotificationDelegate <NSObject>

- (void)notificationView:(MPGNotification *)notification didDismissWithButtonIndex:(NSInteger)buttonIndex;

@end
