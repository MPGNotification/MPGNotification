//
//  MPGNotification.m
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

#import "MPGNotification.h"

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kNotificationHeight = 64;
static const CGFloat kIconImageSize = 32.0;
static const NSTimeInterval kLinearAnimationTime = 0.25;

static const NSString *kTitleFontName = @"HelveticaNeue-Bold";
static const CGFloat kTitleFontSize = 17.0;

static const NSString *kSubtitleFontName = @"HelveticaNeue";
static const CGFloat kSubtitleFontSize = 14.0;

static const CGFloat kButtonFontSize = 13.0;
static const CGFloat kButtonCornerRadius = 3.0;

static const CGFloat kColorAdjustmentDark = -0.15;
static const CGFloat kColorAdjustmentLight = 0.35;

static const NSInteger kBackgroundButtonTag = 4145153;

////////////////////////////////////////////////////////////////////////////////

@interface MPGNotification ()

// required for system interaction
@property (nonatomic) UIWindowLevel windowLevel; // ensures the system status bar does not overlap the notification

// always built
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UILabel *titleLabel;

// optionally built
@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) UILabel *subtitleLabel;

@property (nonatomic, readwrite) UIButton *backgroundButton;
@property (nonatomic, readwrite) UIButton *firstButton;
@property (nonatomic, readwrite) UIButton *secondButton;
@property (nonatomic, readwrite) UIButton *closeButton;

// other
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic) MPGNotificationButtonConfigration buttonConfiguration;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation MPGNotification

// designated initializer
- (instancetype)init
{
    // If the App has a keyWindow, get it, else get the 'top'-most window in the App's hierarchy.
    UIWindow *window = [self _topAppWindow];

    // Now get the 'top'-most object in that window and use its width for the Notification.
    UIView *topSubview = [[window subviews] lastObject];
    CGRect notificationFrame = CGRectMake(0, 0, CGRectGetWidth(topSubview.bounds), kNotificationHeight);
    
    self = [super initWithFrame:notificationFrame];
    if (self) {
        self.titleColor = [UIColor whiteColor];
        self.subtitleColor = [UIColor whiteColor];
        
        self.backgroundButton = [[UIButton alloc] initWithFrame:self.bounds];
        [self addSubview:self.backgroundButton];
        
        self.backgroundButton.tag = kBackgroundButtonTag;
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    NSAssert(NO, @"Wrong initializer. Use the base init method, or initialize with the convenience class method provided.");
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Class Overrides

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    static const CGFloat kPaddingX = 5;
    CGFloat notificationWidth = CGRectGetWidth(self.bounds);
    
    // BACKROUND TAP CATCHER
    self.backgroundButton.frame = self.bounds;
    
    
    // ICON IMAGE
    static const CGFloat kIconPaddingY = 15;
    
    self.iconImageView.frame = CGRectMake(kPaddingX, kIconPaddingY, kIconImageSize, kIconImageSize);
    
    
    // BUTTONS
    static const CGFloat kButtonOriginXOffset = 75;
    static const CGFloat kCloseButtonOriginXOffset = 40;
    
    static const CGFloat kButtonWidthClose = 25;
    static const CGFloat kButtonWidthDefault = 64;
    static const CGFloat kButtonPadding = 2.5;
    
    static const CGFloat kCloseButtonOriginY = 17;
    static const CGFloat kCloseButtonWidth = 25;
    static const CGFloat kCloseButtonHeight = 30;
    
    CGFloat buttonOriginX = notificationWidth - kButtonOriginXOffset;
    CGFloat closeButtonOriginX = notificationWidth - kCloseButtonOriginXOffset;
    
    CGFloat firstButtonOriginY = (self.secondButton) ? 6 : 17;
    CGFloat buttonHeight = (self.firstButton && self.secondButton) ? 25 : 30;
    CGFloat secondButtonOriginY = firstButtonOriginY + buttonHeight + kButtonPadding;
    
    self.firstButton.frame = CGRectMake(buttonOriginX, firstButtonOriginY, kButtonWidthDefault, buttonHeight);
    self.secondButton.frame = CGRectMake(buttonOriginX, secondButtonOriginY, kButtonWidthDefault, buttonHeight);
    self.closeButton.frame = CGRectMake(closeButtonOriginX, kCloseButtonOriginY, kCloseButtonWidth, kCloseButtonHeight);
    
    
    // TITLE LABEL
    NSParameterAssert(self.title);
    
    static const CGFloat kTitleLabelPaddingX = 8;
    static const CGFloat kTitleLabelHeight = 20;
    
    CGFloat textPaddingX = (self.iconImageView) ? CGRectGetMaxX(self.iconImageView.frame) + kTitleLabelPaddingX : kPaddingX;
    CGFloat textTrailingX = (self.firstButton) ? CGRectGetWidth(self.bounds) - CGRectGetMinX(self.firstButton.frame) + 9 : 20;
    CGFloat textWidth = notificationWidth - (textPaddingX + textTrailingX);
    
    // expected subtitle calculations
    // TODO: this method is deprecated; update this (use Evil Studios NSString category?)
    static const CGFloat kSubtitleHeight = 50;
    CGSize expectedSubtitleSize = [self.subtitle sizeWithFont:self.subtitleLabel.font
                                            constrainedToSize:CGSizeMake(textWidth, kSubtitleHeight)];
    
    BOOL subtitleEmpty = (self.subtitle == nil || self.subtitle.length == 0);
    BOOL subtitleOneLiner = (expectedSubtitleSize.height < 25 && subtitleEmpty == NO);
    
    CGFloat titleLabelPaddingY = (subtitleEmpty) ? 18 : (subtitleOneLiner) ? 13 : 3;
    
    self.titleLabel.frame = CGRectMake(textPaddingX,
                                       titleLabelPaddingY,
                                       textWidth,
                                       kTitleLabelHeight);
    
    
    // SUBTITLE LABEL
    CGFloat subtitlePaddingY = 1;
    
    self.subtitleLabel.frame = CGRectMake(CGRectGetMinX(self.titleLabel.frame),
                                          CGRectGetMaxY(self.titleLabel.frame) + subtitlePaddingY,
                                          textWidth,
                                          kSubtitleHeight);
    [self.subtitleLabel sizeToFit];
    
    
    // TEXT COLOR
    [self.titleLabel setTextColor:self.titleColor];
    [self.subtitleLabel setTextColor:self.subtitleColor];
    
}

#pragma mark - UIDynamicAnimator Delegate

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator{
    [self removeFromSuperview];
    [self.animator setDelegate:nil];
}

#pragma mark - Class Methods

+ (MPGNotification *)notificationWithTitle:(NSString *)title subtitle:(NSString *)subtitle backgroundColor:(UIColor *)color iconImage:(UIImage *)image {
    
    MPGNotification *newNotification = [MPGNotification new];
    
    newNotification.title = title;
    newNotification.subtitle = subtitle;
    newNotification.backgroundColor = color;
    newNotification.iconImage = image;
    
    return newNotification;
    
}

#pragma mark - Getters & Setters

- (void)setTitle:(NSString *)title {
    
    _title = title;
    
    if (!self.titleLabel) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:self.titleLabel];
        
        self.titleLabel.font = [UIFont fontWithName:kTitleFontName size:kTitleFontSize];
    }
    
    self.titleLabel.text = title;
    [self setNeedsLayout];
}

- (void)setSubtitle:(NSString *)subtitle {
    
    _subtitle = subtitle;
    
    if (!self.subtitleLabel) {
        self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, 1, 1, 1)];
        [self addSubview:self.subtitleLabel];
        
        self.subtitleLabel.font = [UIFont fontWithName:kSubtitleFontName size:kSubtitleFontSize];
        self.subtitleLabel.numberOfLines = 2;
    }
    
    self.subtitleLabel.text = subtitle;
    [self setNeedsLayout];
}

- (void)setIconImage:(UIImage *)iconImage {
    
    _iconImage = iconImage;
    
    if (!self.iconImageView) {
        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.iconImageView];
    }
    
    self.iconImageView.image = iconImage;
    [self setNeedsLayout];
}

- (void)setBackgroundTapsEnabled:(BOOL)allowBackgroundTaps {
    
    _backgroundTapsEnabled = allowBackgroundTaps;
    
    [self.backgroundButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    
    if (allowBackgroundTaps) {
        [self.backgroundButton addTarget:self
                                  action:@selector(_buttonTapped:)
                        forControlEvents:UIControlEventTouchUpInside];
    }
    
}

#pragma mark - Public Methods

- (void)setButtonConfiguration:(MPGNotificationButtonConfigration)configuration withButtonTitles:(NSArray *)buttonTitles {
    
    self.buttonConfiguration = configuration;
    
    switch (configuration) {
        case MPGNotificationButtonConfigrationZeroButtons:
            NSParameterAssert(buttonTitles == nil || buttonTitles.count == 0);
            self.firstButton = nil;
            self.secondButton = nil;
            self.closeButton = nil;
            break;
            
        case MPGNotificationButtonConfigrationCloseButton: {
            
            self.firstButton = nil;
            self.secondButton = nil;
            
            if (!self.closeButton) {
                self.closeButton = [self _newButtonWithTitle:@"X" withTag:0];
                [self addSubview:self.closeButton];
                
                self.closeButton.titleLabel.font = [UIFont systemFontOfSize:15.0]; // custom font!

            }
            
            break;
        }
            
        // deliberately grabbing one and two button states
        case MPGNotificationButtonConfigrationOneButton:
        case MPGNotificationButtonConfigrationTwoButton: {
            
            // note: configuration typedef value is matches # of buttons
            NSParameterAssert(buttonTitles.count == configuration);
            
            self.closeButton = nil;
            
            NSInteger firstButtonTagIndex = 0;
            NSString *firstButtonTitle = buttonTitles[firstButtonTagIndex];
            if (!self.firstButton) {
                self.firstButton = [self _newButtonWithTitle:firstButtonTitle withTag:firstButtonTagIndex];
                [self addSubview:self.firstButton];
            } else {
                [self.firstButton setTitle:firstButtonTitle forState:UIControlStateNormal];
            }
            
            if (configuration == MPGNotificationButtonConfigrationTwoButton) {
                
                NSInteger secondButtonTagIndex = 1;
                NSString *secondButtonTitle = buttonTitles[secondButtonTagIndex];
                if (!self.secondButton) {
                    self.secondButton = [self _newButtonWithTitle:secondButtonTitle withTag:secondButtonTagIndex];
                    [self addSubview:self.secondButton];
                } else {
                    [self.secondButton setTitle:firstButtonTitle forState:UIControlStateNormal];
                }
                
            }
            
            break;
        }

    }
    
    [self setNeedsLayout];
    
}

- (void)show {
    
    [self _showNotification];
    
}

- (void)showWithButtonHandler:(MPGNotificationButtonHandler)buttonHandler {
    
    self.buttonHandler = buttonHandler;
    
    [self _showNotification];
    
}

- (void)dismissWithAnimation:(BOOL)animated {
    
    [self _dismissAnimated:animated];
    
}

#pragma mark - Private Methods - Show/Dismiss

- (void)_showNotification {
    
    // Called to display the initiliased notification on screen.
    
    UIWindow *window = [self _topAppWindow];
    
    self.windowLevel = [[[[UIApplication sharedApplication] delegate] window] windowLevel];
    
    // Update windowLevel to make sure status bar does not interfere with the notification
    [[[[UIApplication sharedApplication] delegate] window] setWindowLevel:UIWindowLevelStatusBar+1];
    
    // add the notification to the screen
    [window.subviews.lastObject addSubview:self];
    
    // move notification off-screen
    self.transform = CGAffineTransformMakeTranslation(0, -1 * CGRectGetHeight(self.bounds));
    
    switch (self.animationType) {
        case MPGNotificationAnimationTypeLinear: {
            
            [UIView animateWithDuration:kLinearAnimationTime animations:^{
                self.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                [self _startDismissTimerIfSet];
            }];
            
            break;
        }
            
        case MPGNotificationAnimationTypeDrop: {
            
            self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
            
            UIGravityBehavior* gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self]];
            [self.animator addBehavior:gravityBehavior];
            
            CGFloat notificationWidth = CGRectGetWidth(self.bounds);
            CGFloat notificationHeight = CGRectGetHeight(self.bounds);
            
            UICollisionBehavior* collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self]];
            [collisionBehavior addBoundaryWithIdentifier:@"MPGNotificationBoundary"
                                               fromPoint:CGPointMake(0, notificationHeight)
                                                 toPoint:CGPointMake(notificationWidth, notificationHeight)];
            
            [self.animator addBehavior:collisionBehavior];
            
            UIDynamicItemBehavior *elasticityBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self]];
            elasticityBehavior.elasticity = 0.3f;
            [self.animator addBehavior:elasticityBehavior];
            
            break;
        }
            
        case MPGNotificationAnimationTypeSnap: {
            
            self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
            
            // make transform more extreme
            self.transform = CGAffineTransformMakeTranslation(0, -2.5 * CGRectGetHeight(self.bounds));
            
            CGPoint centerPoint = CGPointMake(CGRectGetWidth(self.bounds) * 0.5,
                                              CGRectGetHeight(self.bounds) * 0.5);
            
            UISnapBehavior *snapBehaviour = [[UISnapBehavior alloc] initWithItem:self snapToPoint:centerPoint];
            snapBehaviour.damping = 0.50f;
            [self.animator addBehavior:snapBehaviour];

            
            break;
        }
            
    }
    
}

- (void)_dismissAnimated:(BOOL)animated {
    
    //Call this method to dismiss the notification. The notification will dismiss in the same animation as it appeared on screen. If the 'animated' variable is set NO, the notification will disappear without any animation.
    CGRect viewBounds = [self.superview bounds];
    if (animated) {
        
        if (self.animationType == MPGNotificationAnimationTypeLinear || self.animationType == MPGNotificationAnimationTypeDrop) {
            [UIView animateWithDuration:0.25
                             animations:^{
                                 self.frame = CGRectMake(0, 0, viewBounds.size.width, -64);
                             }
                             completion:^(BOOL finished){
                                 [self removeFromSuperview];
                                 [[[[UIApplication sharedApplication] delegate] window] setWindowLevel:self.windowLevel];
                             }];
        }
        else if (self.animationType == MPGNotificationAnimationTypeSnap){
            self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
            [self.animator setDelegate:self];
            UISnapBehavior *snapBehaviour = [[UISnapBehavior alloc] initWithItem:self snapToPoint:CGPointMake(viewBounds.size.width, -74)];
            snapBehaviour.damping = 0.75f;
            [self.animator addBehavior:snapBehaviour];
            [[[[UIApplication sharedApplication] delegate] window] setWindowLevel:self.windowLevel];
        }
        
    } else {
        
        [self removeFromSuperview];
        [[[[UIApplication sharedApplication] delegate] window] setWindowLevel:self.windowLevel];
        
    }
    
}

#pragma mark - Private Methods

- (void)_buttonTapped:(UIButton *)button {
    
    //Called when a button is tapped on the notification. The notification is then moved off-screen and the button handling block is called.
    [self _dismissAnimated:YES];
    
    if (self.buttonHandler) {
        self.buttonHandler(self, button.tag);
    }
}

//Color methods to create a darker and lighter tone of the notification background color. These colors are used for providing backgrounds to button and make sure that buttons are suited to all color environments.
- (UIColor *)_darkerColorForColor:(UIColor *)color
{
    CGFloat r,g,b,a;
    if ([color getRed:&r green:&g blue:&b alpha:&a]) {
        static const CGFloat minValue = 0.0;
        return [UIColor colorWithRed:MAX(r + kColorAdjustmentDark, minValue)
                               green:MAX(g + kColorAdjustmentDark, minValue)
                                blue:MAX(b + kColorAdjustmentDark, minValue)
                               alpha:a];
    } else {
        return nil;
    }
}

- (UIColor *)_lighterColorForColor:(UIColor *)color
{
    CGFloat r, g, b, a;
    if ([color getRed:&r green:&g blue:&b alpha:&a]){
        static const CGFloat maxValue = 1.0;
        return [UIColor colorWithRed:MIN(r + kColorAdjustmentLight, maxValue)
                               green:MIN(g + kColorAdjustmentLight, maxValue)
                                blue:MIN(b + kColorAdjustmentLight, maxValue)
                               alpha:a];
    } else {
        return nil;
    }
    
}

- (UIWindow *)_topAppWindow {
    return ([UIApplication sharedApplication].keyWindow) ?: [[UIApplication sharedApplication].windows lastObject];
}

- (void)_startDismissTimerIfSet {
    
    if (self.duration > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self _dismissAnimated:YES];
        });
    }
    
}

- (UIButton *)_newButtonWithTitle:(NSString *)title withTag:(NSInteger)tag {
    
    UIButton *newButton = [[UIButton alloc] initWithFrame:CGRectZero];
    newButton.tag = tag;
    
    [newButton setTitle:title forState:UIControlStateNormal];
    newButton.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
    
    [newButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [newButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    
    [newButton setBackgroundColor:[self _darkerColorForColor:self.backgroundColor]];
    newButton.layer.cornerRadius = kButtonCornerRadius;
    
    [newButton addTarget:self action:@selector(_buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return newButton;
    
}

@end
