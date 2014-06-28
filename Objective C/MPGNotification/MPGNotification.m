//
//  MPGNotification.m
//  MPGNotification
//
//  Created by Gaurav Wadhwani on 28/06/14.
//  Copyright (c) 2014 Mappgic. All rights reserved.
//

#import "MPGNotification.h"

@implementation MPGNotification

@synthesize animator, delegate;

UIWindowLevel windowLevel;
UILabel *titleLabel;
UILabel *subtitleLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image backgroundColor:(UIColor *)color andButtonTitles:(NSArray *)buttonTitles
{
    CGRect viewBounds = [[UIScreen mainScreen] bounds];
    self = [super initWithFrame:CGRectMake(0, 0, viewBounds.size.width, 64)];
    
    CGRect titleFrame = CGRectMake(10, 6, 230, 20);
    if (buttonTitles == nil) {
        titleFrame = CGRectMake(10, 6, 280, 20);
    }
    if (image != nil) {
        UIImageView *notifIcon = [[UIImageView alloc] initWithFrame:CGRectMake(5, 15, 32, 32)];
        [notifIcon setImage:image];
        [self addSubview:notifIcon];
        
        titleFrame.origin.x = 40;
        titleFrame.size.width -= 40;
    }
    
    if (subtitle == nil || [subtitle isEqualToString:@""]) {
        titleFrame.origin.y += 15;
    }
    titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    [titleLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:17.0]];
    [titleLabel setText:title];
    
    subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleFrame.origin.x, 26, titleFrame.size.width, 50)];
    [subtitleLabel setText:subtitle];
    [subtitleLabel setFont:[UIFont systemFontOfSize:12.0]];
    [subtitleLabel setNumberOfLines:2];
    [subtitleLabel sizeToFit];
    
    if (subtitleLabel.frame.size.height < 25){
        //The subtitle takes up only a single line. Shift the frames to align the title and subtitle in the center
        CGRect subtitleFrame = subtitleLabel.frame;
        subtitleFrame.origin.y += 7;
        [subtitleLabel setFrame:subtitleFrame];
        
        if (subtitle != nil && ![subtitle isEqualToString:@""]) {
            [titleLabel setFrame:CGRectMake(titleFrame.origin.x, 13, titleFrame.size.width, 20)];
        }
    }
    
    if (buttonTitles.count == 1) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(viewBounds.size.width - 75, 17, 64, 30)];
        [button setTitle:buttonTitles[0] forState:UIControlStateNormal];
        [[button titleLabel] setFont:[UIFont systemFontOfSize:13.0]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [button setBackgroundColor:[self darkerColorForColor:color]];
        [button.layer setCornerRadius:3.0];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag:0];
        [self addSubview:button];
    }
    else{
        for (int i = 0; i<buttonTitles.count; i++) {
            if (i < 2) {
                float buttonOrigins = 27.5;
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(viewBounds.size.width - 75, 6 + ((i+1)*buttonOrigins) - buttonOrigins, 64, 25)];
                [button setTitle:buttonTitles[i] forState:UIControlStateNormal];
                [[button titleLabel] setFont:[UIFont systemFontOfSize:13.0]];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
                [button setBackgroundColor:[self darkerColorForColor:color]];
                [button.layer setCornerRadius:3.0];
                [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
                [button setTag:i];
                [self addSubview:button];
            }
        }
        if (buttonTitles == nil) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(viewBounds.size.width - 40, 17, 25, 30)];
            [button setTitle:@"X" forState:UIControlStateNormal];
            [[button titleLabel] setFont:[UIFont systemFontOfSize:15.0]];
            [button setTitleColor:[self lighterColorForColor:color] forState:UIControlStateNormal];
            [button setTitleColor:[self darkerColorForColor:color] forState:UIControlStateHighlighted];
            [button.layer setCornerRadius:3.0];
            [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [button setTag:0];
            [self addSubview:button];
        }
    }
    
    [self addSubview:subtitleLabel];
    [self addSubview:titleLabel];
    self.backgroundColor = color;
    return self;
}

- (void)show
{
    [titleLabel setTextColor:self.titleColor];
    [subtitleLabel setTextColor:self.subtitleColor];
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window)
        window = [[UIApplication sharedApplication].windows lastObject];
    
    windowLevel = [[[[UIApplication sharedApplication] delegate] window] windowLevel];
    [[[[UIApplication sharedApplication] delegate] window] setWindowLevel:UIWindowLevelStatusBar+1];
    CGRect presentationFrame = self.frame;
    self.frame = CGRectMake(0, 0, 320, -64);
    [[[window subviews] lastObject] addSubview:self];
    
    if (self.animationType == MPGNotificationAnimationTypeLinear) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.frame = presentationFrame;
                         }];
    }
    else if (self.animationType == MPGNotificationAnimationTypeDrop){
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
        
        UIGravityBehavior* gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self]];
        [self.animator addBehavior:gravityBehavior];
        
        UICollisionBehavior* collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self]];
        [collisionBehavior addBoundaryWithIdentifier:@"MPGNotificationBoundary" fromPoint:CGPointMake(0, 64) toPoint:CGPointMake(320, 64)];
        //collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
        [self.animator addBehavior:collisionBehavior];
        
        UIDynamicItemBehavior *elasticityBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self]];
        elasticityBehavior.elasticity = 0.3f;
        [self.animator addBehavior:elasticityBehavior];

    }
    else if (self.animationType == MPGNotificationAnimationTypeSnap){
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
        UISnapBehavior *snapBehaviour = [[UISnapBehavior alloc] initWithItem:self snapToPoint:CGPointMake(160, 30)];
        snapBehaviour.damping = 0.65f;
        [self.animator addBehavior:snapBehaviour];
    }
    
}

- (void)dismissWithAnimation:(BOOL)animated
{
    if (animated) {
        if (self.animationType == MPGNotificationAnimationTypeLinear || self.animationType == MPGNotificationAnimationTypeDrop) {
            [UIView animateWithDuration:0.25
                             animations:^{
                                 self.frame = CGRectMake(0, 0, 320, -64);
                             }
                             completion:^(BOOL finished){
                                 [self removeFromSuperview];
                                 [[[[UIApplication sharedApplication] delegate] window] setWindowLevel:windowLevel];
                             }];
        }
        else if (self.animationType == MPGNotificationAnimationTypeSnap){
            self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
            [self.animator setDelegate:self];
            UISnapBehavior *snapBehaviour = [[UISnapBehavior alloc] initWithItem:self snapToPoint:CGPointMake(160, -40)];
            snapBehaviour.damping = 0.65f;
            [self.animator addBehavior:snapBehaviour];
            [[[[UIApplication sharedApplication] delegate] window] setWindowLevel:windowLevel];
        }
        
    }
    else{
        [self removeFromSuperview];
        [[[[UIApplication sharedApplication] delegate] window] setWindowLevel:windowLevel];
    }
}

- (void)buttonTapped:(id)sender
{
    [self dismissWithAnimation:YES];
    if ([[self delegate] respondsToSelector:@selector(notificationView:didDismissWithButtonIndex:)]) {
        [[self delegate] notificationView:self didDismissWithButtonIndex:[sender tag]];
    }
}

- (UIColor *)darkerColorForColor:(UIColor *)color
{
    CGFloat r,g,b,a;
    if ([color getRed:&r green:&g blue:&b alpha:&a]) {
        return [UIColor colorWithRed:MAX(r - 0.15, 0.0)
                               green:MAX(g - 0.15, 0.0)
                                blue:MAX(b - 0.15, 0.0)
                               alpha:a];
    }
    else{
        return nil;
    }
}

- (UIColor *)lighterColorForColor:(UIColor *)c
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a]){
        return [UIColor colorWithRed:MIN(r + 0.35, 1.0)
                               green:MIN(g + 0.35, 1.0)
                                blue:MIN(b + 0.35, 1.0)
                               alpha:a];
    }
    else{
        return nil;
    }
    
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator{
    [self removeFromSuperview];
    [self.animator setDelegate:nil];
}

@end
