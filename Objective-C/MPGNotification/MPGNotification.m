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

static const CGFloat kMaximumNotificationWidth = 512;

static const CGFloat kNotificationHeight = 64;
static const CGFloat kIconImageSize = 32.0;
static const NSTimeInterval kLinearAnimationTime = 0.25;

NSString * const kTitleFontName = @"HelveticaNeue-Bold";
static const CGFloat kTitleFontSize = 17.0;

NSString * const kSubtitleFontName = @"HelveticaNeue";
static const CGFloat kSubtitleFontSize = 14.0;

static const CGFloat kButtonFontSize = 13.0;
static const CGFloat kButtonCornerRadius = 3.0;

static const CGFloat kColorAdjustmentDark = -0.15;
static const CGFloat kColorAdjustmentLight = 0.35;

////////////////////////////////////////////////////////////////////////////////

@interface MPGNotification ()

// required for system interaction
@property (nonatomic) UIWindowLevel windowLevel; // ensures the system status bar does not overlap the notification

// always built
@property (nonatomic, strong) UILabel *titleLabel;

// optionally built
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *subtitleLabel;

@property (nonatomic, readwrite) UIView *backgroundView;
@property (nonatomic, readwrite) UIButton *firstButton;
@property (nonatomic, readwrite) UIButton *secondButton;
@property (nonatomic, readwrite) UIButton *closeButton;

@property (nonatomic, strong) UIView *swipeHintView;

// state
@property (nonatomic) BOOL notificationRevealed;
@property (nonatomic) BOOL notificationDragged;
@property (nonatomic) BOOL notificationDestroyed;

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

    // Now get the 'top'-most object in that window and use its width for the Notification
    UIView *topSubview = [[window subviews] lastObject];
    CGRect notificationFrame = CGRectMake(0, 0, CGRectGetWidth(topSubview.bounds), kNotificationHeight);
    
    self = [super initWithFrame:notificationFrame];
    if (self) {
        
        self.scrollEnabled = NO; // default swipe/scrolling to off (in case swipeToDismiss is not enabled by default)
        self.contentSize = CGSizeMake(CGRectGetWidth(self.bounds), 2 * CGRectGetHeight(self.bounds));
        
        self.pagingEnabled = YES;
        self.showsVerticalScrollIndicator = NO;
        self.bounces = NO;
        
        self.delegate = self;
        
        [super setBackgroundColor:[UIColor clearColor]]; // set background color of scrollView to clear
        
        // make background button (always needed, even if no target)
        self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:self.backgroundView];
        
        self.backgroundView.frame = self.bounds;
        self.backgroundView.tag = MPGNotificationButtonConfigrationZeroButtons;
        
        // set other default values
        self.titleColor = [UIColor whiteColor];
        self.subtitleColor = [UIColor whiteColor];
        
        self.backgroundTapsEnabled = YES;
        self.swipeToDismissEnabled = YES;
        
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

//- (void)dealloc {
//    NSLog(@"DEBUG: NOTIFICATION DEALLOC");
//}

#pragma mark - Class Overrides

- (void)layoutSubviews {
    
    // TODO: layoutSubviews is triggered on scrolling (every frame) - super inefficient
    // figure out how to style all views together without triggering a FULL styling pass on every single property setter
    
    [super layoutSubviews];
    
    static const CGFloat kPaddingX = 5;
    CGFloat notificationWidth = CGRectGetWidth(self.bounds);
    
    CGFloat maxWidth = 0.5 * (notificationWidth - kMaximumNotificationWidth);
    CGFloat contentPaddingX = (self.fullWidthMessages) ? 0 : MAX(0,maxWidth);
    
    // ICON IMAGE
    static const CGFloat kIconPaddingY = 15;
    
    self.iconImageView.frame = CGRectMake(contentPaddingX + kPaddingX,
                                          kIconPaddingY,
                                          kIconImageSize,
                                          kIconImageSize);
    
    
    // BUTTONS
    static const CGFloat kButtonOriginXOffset = 75;
    static const CGFloat kCloseButtonOriginXOffset = 40;
    
    static const CGFloat kButtonWidthDefault = 64;
    static const CGFloat kButtonPadding = 2.5;
    
    static const CGFloat kCloseButtonOriginY = 17;
    static const CGFloat kCloseButtonWidth = 25;
    static const CGFloat kCloseButtonHeight = 30;
    
    CGFloat buttonOriginX = notificationWidth - kButtonOriginXOffset - contentPaddingX;
    CGFloat closeButtonOriginX = notificationWidth - kCloseButtonOriginXOffset - contentPaddingX;
    
    CGFloat firstButtonOriginY = (self.secondButton) ? 6 : 17;
    CGFloat buttonHeight = (self.firstButton && self.secondButton) ? 25 : 30;
    CGFloat secondButtonOriginY = firstButtonOriginY + buttonHeight + kButtonPadding;
    
    self.firstButton.frame = CGRectMake(buttonOriginX, firstButtonOriginY, kButtonWidthDefault, buttonHeight);
    self.secondButton.frame = CGRectMake(buttonOriginX, secondButtonOriginY, kButtonWidthDefault, buttonHeight);
    self.closeButton.frame = CGRectMake(closeButtonOriginX, kCloseButtonOriginY, kCloseButtonWidth, kCloseButtonHeight);
    
    
    // TITLE LABEL
    NSParameterAssert(self.title);
    
    static const CGFloat kTitleLabelHeight = 20;
    
    CGFloat textPaddingX = (self.iconImage) ? CGRectGetMaxX(self.iconImageView.frame) + kPaddingX : contentPaddingX + kPaddingX + 5;
    CGFloat textTrailingX = (self.firstButton) ? CGRectGetWidth(self.bounds) - CGRectGetMinX(self.firstButton.frame) + 9 : contentPaddingX + 20;
    CGFloat textWidth = notificationWidth - (textPaddingX + textTrailingX);
    
    // expected subtitle calculations
    static const CGFloat kSubtitleHeight = 50;
    CGSize expectedSubtitleSize = CGSizeZero;
    
    // use new sizeWithAttributes: if possible
    SEL selector = NSSelectorFromString(@"sizeWithAttributes:");
    if ([self.subtitle respondsToSelector:selector]) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        NSDictionary *attributes = @{NSFontAttributeName:self.subtitleLabel.font};
        CGRect rect = [self.subtitle boundingRectWithSize:CGSizeMake(textWidth, kSubtitleHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        expectedSubtitleSize = rect.size;
#endif
    }
    
    // otherwise use old sizeWithFont:
    else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000 // only when deployment target is < ios7
        expectedSubtitleSize = [self.subtitle sizeWithFont:self.subtitleLabel.font];
#endif
    }
    
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
    
    
    // SWIPE HINT VIEW, ONLY SHOW IF ENABLED
    if(self.swipeToDismissEnabled){
        static const CGFloat kSwipeHintWidth = 37;
        static const CGFloat kSwipeHintHeight = 5;
        static const CGFloat kSwipeHintTrailingY = 5;
        
        self.swipeHintView.frame = CGRectMake(0.5 * (CGRectGetWidth(self.backgroundView.bounds) - kSwipeHintWidth),
                                              CGRectGetHeight(self.backgroundView.bounds) - kSwipeHintTrailingY - kSwipeHintHeight,
                                              kSwipeHintWidth,
                                              kSwipeHintHeight);
        
        self.swipeHintView.layer.cornerRadius = CGRectGetHeight(self.swipeHintView.bounds) * 0.5;
    }
    
    // COLORS!!
    self.swipeHintView.backgroundColor = [self _darkerColorForColor:self.backgroundColor];
    self.titleLabel.textColor = self.titleColor;
    self.subtitleLabel.textColor = self.subtitleColor;
    
    
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (self.notificationDragged == NO) {
        self.notificationDragged = YES;
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate &&
        [self _notificationOffScreen] &&
        self.notificationRevealed) {
        
        [self _destroyNotification];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self _notificationOffScreen] &&
        self.notificationRevealed) {
        [self _destroyNotification];
    }
}

#pragma mark - UIDynamicAnimator Delegate

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator{
    [self _destroyNotification];
}

#pragma mark - Class Methods

+ (MPGNotification *)notificationWithHostViewController:(UIViewController *)hostViewController title:(NSString *)title subtitle:(NSString *)subtitle backgroundColor:(UIColor *)color iconImage:(UIImage *)image {
    
    MPGNotification *newNotification = [MPGNotification notificationWithTitle:title subtitle:subtitle backgroundColor:color iconImage:image];
    
    newNotification.hostViewController = hostViewController;
    
    return newNotification;
    
}

+ (MPGNotification *)notificationWithTitle:(NSString *)title subtitle:(NSString *)subtitle backgroundColor:(UIColor *)color iconImage:(UIImage *)image {
    
    MPGNotification *newNotification = [MPGNotification new];
    
    newNotification.title = title;
    newNotification.subtitle = subtitle;
    newNotification.backgroundColor = color;
    newNotification.iconImage = image;
    
    return newNotification;
    
}

#pragma mark - Getters & Setters

- (UIColor *)backgroundColor {
    return self.backgroundView.backgroundColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    
    // do not actually set the background color of the base view (scrollView)
    self.backgroundView.backgroundColor = backgroundColor;
    
}

- (void)setTitle:(NSString *)title {
    
    _title = title;
    
    if (!self.titleLabel) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.backgroundView addSubview:self.titleLabel];
        
        self.titleLabel.backgroundColor = [UIColor clearColor];
        
        self.titleLabel.font = [UIFont fontWithName:kTitleFontName size:kTitleFontSize];
    }
    
    self.titleLabel.text = title;
    [self setNeedsLayout];
}

- (void)setSubtitle:(NSString *)subtitle {
    
    _subtitle = subtitle;
    
    if (!self.subtitleLabel) {
        self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, 1, 1, 1)];
        [self.backgroundView addSubview:self.subtitleLabel];
        
        self.subtitleLabel.backgroundColor = [UIColor clearColor];
        
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
        [self.backgroundView addSubview:self.iconImageView];
    }
    
    self.iconImageView.image = iconImage;
    [self setNeedsLayout];
}

- (void)setBackgroundTapsEnabled:(BOOL)allowBackgroundTaps {
    
    NSParameterAssert(self.backgroundView);
    
    _backgroundTapsEnabled = allowBackgroundTaps;
    
    // remove existing tapRecognizers
    for (UIGestureRecognizer *recognizer in self.backgroundView.gestureRecognizers.copy) {
        [self.backgroundView removeGestureRecognizer:recognizer];
    }
    
    if (allowBackgroundTaps) {
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_backgroundTapped:)];
        [self.backgroundView addGestureRecognizer:tapRecognizer];
    }
    
}

- (void)setSwipeToDismissEnabled:(BOOL)swipeToDismissEnabled {
    
    _swipeToDismissEnabled = swipeToDismissEnabled;
    
    self.scrollEnabled = swipeToDismissEnabled;
    
    if (swipeToDismissEnabled) {
        
        if (!self.swipeHintView) {
            self.swipeHintView = [[UIView alloc] initWithFrame:CGRectZero];
            [self.backgroundView addSubview:self.swipeHintView];
        }
        
    }
    
}

- (void)setHostViewController:(UIViewController *)hostViewController {
    
    if (self.notificationRevealed && hostViewController == nil) {
        NSAssert(NO, @"Cannot set hostViewController to nil after the Notification has been revealed.");
    } else {
        _hostViewController = hostViewController;
    }
    
}

#pragma mark - Public Methods

- (void)setButtonConfiguration:(MPGNotificationButtonConfigration)configuration withButtonTitles:(NSArray *)buttonTitles {
    
    self.buttonConfiguration = configuration;
    
    NSInteger buttonTag = configuration;
    
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
                self.closeButton = [self _newButtonWithTitle:@"X" withTag:buttonTag];
                [self.backgroundView addSubview:self.closeButton];
                
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
            
            NSString *firstButtonTitle = buttonTitles[0];
            if (!self.firstButton) {
                self.firstButton = [self _newButtonWithTitle:firstButtonTitle withTag:buttonTag];
                [self.backgroundView addSubview:self.firstButton];
            } else {
                [self.firstButton setTitle:firstButtonTitle forState:UIControlStateNormal];
            }
            
            if (configuration == MPGNotificationButtonConfigrationTwoButton) {
                
                NSInteger tagIncrement = 4317; // large, random increment to prevent overlapping tags
                NSInteger tag = buttonTag + tagIncrement;
                
                NSString *secondButtonTitle = buttonTitles[1];
                if (!self.secondButton) {
                    self.secondButton = [self _newButtonWithTitle:secondButtonTitle withTag:tag];
                    [self.backgroundView addSubview:self.secondButton];
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
   
    self.notificationDestroyed = NO; 
    self.notificationRevealed = YES;
    
    [self _setupNotificationViews];
    
    switch (self.animationType) {
        case MPGNotificationAnimationTypeLinear: {
            
            // move notification off-screen
            self.contentOffset = CGPointMake(0, CGRectGetHeight(self.bounds));
            
            [UIView animateWithDuration:kLinearAnimationTime animations:^{
                self.contentOffset = CGPointZero;
            } completion:^(BOOL finished) {
                [self _startDismissTimerIfSet];
            }];
            
            break;
        }
            
        case MPGNotificationAnimationTypeDrop: {
            
            self.backgroundView.center = CGPointMake(self.center.x,
                                                     self.center.y - CGRectGetHeight(self.bounds));
            
            self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
            
            UIGravityBehavior* gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.backgroundView]];
            [self.animator addBehavior:gravityBehavior];
            
            CGFloat notificationWidth = CGRectGetWidth(self.bounds);
            CGFloat notificationHeight = CGRectGetHeight(self.bounds);
            
            UICollisionBehavior* collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.backgroundView]];
            [collisionBehavior addBoundaryWithIdentifier:@"MPGNotificationBoundary"
                                               fromPoint:CGPointMake(0, notificationHeight)
                                                 toPoint:CGPointMake(notificationWidth, notificationHeight)];
            
            [self.animator addBehavior:collisionBehavior];
            
            UIDynamicItemBehavior *elasticityBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.backgroundView]];
            elasticityBehavior.elasticity = 0.3f;
            [self.animator addBehavior:elasticityBehavior];
            
            [self _startDismissTimerIfSet];
            
            break;
        }
            
        case MPGNotificationAnimationTypeSnap: {
            
            self.backgroundView.center = CGPointMake(self.center.x,
                                                     self.center.y - 2 * CGRectGetHeight(self.bounds));
            
            self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
            
            CGPoint centerPoint = CGPointMake(CGRectGetWidth(self.bounds) * 0.5,
                                              CGRectGetHeight(self.bounds) * 0.5);
            
            UISnapBehavior *snapBehaviour = [[UISnapBehavior alloc] initWithItem:self.backgroundView snapToPoint:centerPoint];
            snapBehaviour.damping = 0.50f;
            [self.animator addBehavior:snapBehaviour];
            
            [self _startDismissTimerIfSet];
            break;
        }
            
    }
    
}

- (void)_dismissAnimated:(BOOL)animated {
    
    // Call this method to dismiss the notification. The notification will dismiss in the same animation as it appeared on screen. If the 'animated' variable is set NO, the notification will disappear without any animation.
    CGRect viewBounds = [self.superview bounds];
    if (animated) {
        
        switch (self.animationType) {
            
            // deliberately capturing 2 cases
            case MPGNotificationAnimationTypeLinear:
            case MPGNotificationAnimationTypeDrop: {
                
                [UIView animateWithDuration:kLinearAnimationTime animations:^{
                    self.contentOffset = CGPointMake(0, CGRectGetHeight(self.bounds));
                } completion:^(BOOL finished){
                    [self _destroyNotification];
                }];
                break;
            }
                
            case MPGNotificationAnimationTypeSnap: {
                self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
                [self.animator setDelegate:self];
                UISnapBehavior *snapBehaviour = [[UISnapBehavior alloc] initWithItem:self.backgroundView snapToPoint:CGPointMake(viewBounds.size.width, -74)];
                snapBehaviour.damping = 0.75f;
                [self.animator addBehavior:snapBehaviour];
                break;
            }
        }
        
    } else {
        
        [self _destroyNotification];
    }
    
}

#pragma mark - Private Methods - Taps & Gestures

- (void)_buttonTapped:(UIButton *)button {
    
    [self _responderTapped:button];
    
}

- (void)_backgroundTapped:(UITapGestureRecognizer *)tapRecognizer {
    
    [self _responderTapped:self.backgroundView];
    
}

#pragma mark - Private Methods

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
            if (self.notificationDragged == NO && self.notificationDestroyed == NO) {
                [self _dismissAnimated:YES];
            }
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

- (void)_destroyNotification {
    
    if (!self.notificationDestroyed) {
        self.notificationDestroyed = YES;
        
        if (self.hostViewController == nil) {
            [[[[UIApplication sharedApplication] delegate] window] setWindowLevel:self.windowLevel];
        }
        
        [self _dismissBlockHandler];
        
        self.animator.delegate = nil;
        self.animator = nil;
        
        [self removeFromSuperview];
    }
    
}

- (BOOL)_notificationOffScreen {
    
    return (self.contentOffset.y >= CGRectGetHeight(self.bounds));
    
}

- (void)_responderTapped:(UIView *)responder {
    
    [self _dismissAnimated:YES];
    
    if (self.buttonHandler) {
        self.buttonHandler(self, responder.tag);
    }
    
}

- (void)_dismissBlockHandler {
    if (self.dismissHandler) {
        self.dismissHandler(self);
        self.dismissHandler = nil;
    }
}

- (void)_setupNotificationViews {
    
    if (self.hostViewController) {
        
        [self.hostViewController.view addSubview:self];
        
    } else {
        
        UIWindow *window = [self _topAppWindow];
        
        self.windowLevel = [[[[UIApplication sharedApplication] delegate] window] windowLevel];
        
        // Update windowLevel to make sure status bar does not interfere with the notification
        [[[[UIApplication sharedApplication] delegate] window] setWindowLevel:UIWindowLevelStatusBar+1];
        
        // add the notification to the screen
        [window.subviews.lastObject addSubview:self];
        
    }
    
    UIView *superview = self.superview;
    self.frame = CGRectMake(0, 0, CGRectGetWidth(superview.bounds), kNotificationHeight);
    self.contentSize = CGSizeMake(CGRectGetWidth(self.bounds), 2 * CGRectGetHeight(self.bounds));
    self.backgroundView.frame = self.bounds;
    
    
}

@end
