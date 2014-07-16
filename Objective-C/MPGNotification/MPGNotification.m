//
//  MPGNotification.m
//  MPGNotification
//
//  Created by Gaurav Wadhwani on 28/06/14.
//  Copyright (c) 2014 Mappgic. All rights reserved.
//

#import "MPGNotification.h"

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kNotificationHeight = 64;
static const CGFloat kIconImageSize = 32.0;

static const NSString *kTitleFontName = @"HelveticaNeue-Bold";
static const CGFloat kTitleFontSize = 17.0;

static const NSString *kSubtitleFontName = @"HelveticaNeue";
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
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UILabel *titleLabel;

// optionally built
@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) UILabel *subtitleLabel;

@property (nonatomic, readwrite) UIButton *firstButton;
@property (nonatomic, readwrite) UIButton *secondButton;
@property (nonatomic, readwrite) UIButton *closeButton;

// other
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic) MPGNotificationButtonConfigration buttonConfiguration;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation MPGNotification

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
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
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
    
    // TODO: deprecated; update this (use EA NSString category)
    CGSize subtitleSize = [self.subtitle sizeWithFont:self.subtitleLabel.font
                                    constrainedToSize:self.subtitleLabel.bounds.size];
    
    BOOL subtitleEmpty = (self.subtitle == nil || self.subtitle.length == 0);
    BOOL subtitleOneLiner = (subtitleSize.height < 25 && subtitleEmpty == NO);
    
    
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
    CGFloat secondButtonOriginY = CGRectGetMaxY(self.firstButton.frame) + kButtonPadding;
    CGFloat buttonHeight = (self.firstButton && self.secondButton) ? 25 : 30;
    
    self.firstButton.frame = CGRectMake(buttonOriginX, firstButtonOriginY, kButtonWidthDefault, buttonHeight);
    self.secondButton.frame = CGRectMake(buttonOriginX, secondButtonOriginY, kButtonWidthDefault, buttonHeight);
    self.closeButton.frame = CGRectMake(closeButtonOriginX, kCloseButtonOriginY, kCloseButtonWidth, kCloseButtonHeight);
    
    
    // TITLE LABEL
    NSParameterAssert(self.title);
    
    static const CGFloat kTitleLabelPaddingX = 5;
    static const CGFloat kTitleLabelHeight = 20;
    
    CGFloat textPaddingX = (self.iconImageView) ? CGRectGetMaxX(self.iconImageView.frame) + kTitleLabelPaddingX : kPaddingX;
    CGFloat textTrailingX = (self.firstButton) ? 70 : 20;
    CGFloat textWidth = notificationWidth - (textPaddingX + textTrailingX);
    
    CGFloat titleLabelPaddingY = (subtitleEmpty) ? 18 : (subtitleOneLiner) ? 13 : 3;
    
    self.titleLabel.frame = CGRectMake(textPaddingX,
                                       titleLabelPaddingY,
                                       textWidth,
                                       kTitleLabelHeight);
    
    // SUBTITLE LABEL
    static const CGFloat kSubtitleHeight = 50;
    
    CGFloat subtitlePaddingY = (subtitleOneLiner) ? 1 : 8;
    
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
        self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
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
    
    //Called to display the initiliased notification on screen.
    
    UIWindow *window = [self _topAppWindow];
    
    self.windowLevel = [[[[UIApplication sharedApplication] delegate] window] windowLevel];
    
    //Update windowLevel to make sure status bar does not interfere with the notification
    [[[[UIApplication sharedApplication] delegate] window] setWindowLevel:UIWindowLevelStatusBar+1];
    
    //Store presentationFrame (final frame) of the notification and move the notification off-screen. Then, animate the notification to presentationFrame depending on the animationType selected by the caller. If no animationType is specified, 'Linear' animation type will be used.
    CGRect presentationFrame = self.frame;
    CGRect viewBounds = [[[window subviews] lastObject] bounds];
    self.frame = CGRectMake(0, 0, viewBounds.size.width, -64);
    [[[window subviews] lastObject] addSubview:self];
    
    if (self.animationType == MPGNotificationAnimationTypeLinear) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.frame = presentationFrame;
                         } completion:^(BOOL finished) {
                             [self _startDismissTimerIfSet];
                         }];
    }
    else if (self.animationType == MPGNotificationAnimationTypeDrop){
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
        
        UIGravityBehavior* gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self]];
        [self.animator addBehavior:gravityBehavior];
        
        UICollisionBehavior* collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self]];
        [collisionBehavior addBoundaryWithIdentifier:@"MPGNotificationBoundary" fromPoint:CGPointMake(0, 64) toPoint:CGPointMake(viewBounds.size.width, 64)];
        [self.animator addBehavior:collisionBehavior];
        
        UIDynamicItemBehavior *elasticityBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self]];
        elasticityBehavior.elasticity = 0.3f;
        [self.animator addBehavior:elasticityBehavior];
    }
    else if (self.animationType == MPGNotificationAnimationTypeSnap){
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
        self.frame = CGRectMake(0, -150, viewBounds.size.width, 64);
        UISnapBehavior *snapBehaviour = [[UISnapBehavior alloc] initWithItem:self snapToPoint:CGPointMake(viewBounds.size.width/2, 32)];
        snapBehaviour.damping = 0.50f;
        [self.animator addBehavior:snapBehaviour];
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

- (void)_buttonTapped:(UIButton *)button
{
    //Called when a button is tapped on the notification. The notification is then moved off-screen and the button handling block is called.
    [self _dismissAnimated:YES];
    
    if (self.buttonHandler) {
        self.buttonHandler(button.tag);
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
