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

//Private declarations: 'windowLevel' is to make sure the status bar does not overlap the notification. 'titleLabel' and 'subtitleLabel' are instances to labels on notification for modifications like color changes.
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

//Method to initialise the notification with title (mandatory), subtitile, background color and buttons for interactivity
- (id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image backgroundColor:(UIColor *)color andButtonTitles:(NSArray *)buttonTitles
{
    //Get an instance of window's last object and its bounds. The bounds are used to determine the width of the view (for portrait and landscape) and thereby, the notification.
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window)
        window = [[UIApplication sharedApplication].windows lastObject];
    
    CGRect viewBounds = [[[window subviews] lastObject] bounds];
    self = [super initWithFrame:CGRectMake(0, 0, viewBounds.size.width, 64)];
    
    //Create titleFrame values for the width of the title label. Update this title label frame depending on the optional values - subtitle, icon and button titles.
    CGRect titleFrame = CGRectMake(10, 3, viewBounds.size.width - 80, 20);
    if (buttonTitles == nil) {
        //If there are no buttons supplied, the titleFrame width is increased to fit in more text.
        titleFrame.size.width += 50;
    }
    if (image != nil) {
        //If there is an icon supplied, adjust the titleFrame width and X-position accordingly and add an ImageView object to display the icon in a 32x32px size.
        UIImageView *notifIcon = [[UIImageView alloc] initWithFrame:CGRectMake(5, 15, 32, 32)];
        [notifIcon setImage:image];
        [self addSubview:notifIcon];
        
        titleFrame.origin.x = 40;
        titleFrame.size.width -= 40;
    }
    
    if (subtitle == nil || [subtitle isEqualToString:@""]) {
        //Shift the titleFrame to center it vertically if there is no subtitle supplied by the user.
        titleFrame.origin.y += 15;
    }
    else{
        //The subtitle is supplied. Initialise an instance of subtitle with supplied text and font attributes.
        subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleFrame.origin.x, 24, titleFrame.size.width, 50)];
        [subtitleLabel setText:subtitle];
        [subtitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0]];
        [subtitleLabel setNumberOfLines:2];
        [subtitleLabel sizeToFit];
    }
    
    //Initialise the title instance with the given text and bold font.
    titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0]];
    [titleLabel setText:title];
    
    
    if (subtitleLabel.frame.size.height < 25){
        //The subtitle takes up only a single line. Shift the frames to align the title and subtitle in the center
        CGRect subtitleFrame = subtitleLabel.frame;
        subtitleFrame.origin.y += 7;
        [subtitleLabel setFrame:subtitleFrame];
        
        if (subtitle != nil && ![subtitle isEqualToString:@""]) {
            [titleLabel setFrame:CGRectMake(titleFrame.origin.x, 13, titleFrame.size.width, 20)];
        }
    }
    
    //ButtonTitles is an array of buttons. Check if it has a single, double or no button at all and add buttons accordingly (by aligning it on the center-right).
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
    
    //Add subviews and return 'self' instance
    [self addSubview:subtitleLabel];
    [self addSubview:titleLabel];
    self.backgroundColor = color;
    return self;
}

- (void)show
{
    //Called to display the initiliased notification on screen. Set titleColor and subtitleColor (if set by the user, use default otherwise).
    [titleLabel setTextColor:self.titleColor];
    [subtitleLabel setTextColor:self.subtitleColor];
    
    //Get window instance to display the notification as a subview on the view present on screen
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window)
        window = [[UIApplication sharedApplication].windows lastObject];
    
    windowLevel = [[[[UIApplication sharedApplication] delegate] window] windowLevel];
    
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
                         }];
    }
    else if (self.animationType == MPGNotificationAnimationTypeDrop){
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
        
        UIGravityBehavior* gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self]];
        [self.animator addBehavior:gravityBehavior];
        
        UICollisionBehavior* collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self]];
        [collisionBehavior addBoundaryWithIdentifier:@"MPGNotificationBoundary" fromPoint:CGPointMake(0, 64) toPoint:CGPointMake(viewBounds.size.width, 64)];
        //collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
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

- (void)dismissWithAnimation:(BOOL)animated
{
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
                                 [[[[UIApplication sharedApplication] delegate] window] setWindowLevel:windowLevel];
                             }];
        }
        else if (self.animationType == MPGNotificationAnimationTypeSnap){
            self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
            [self.animator setDelegate:self];
            UISnapBehavior *snapBehaviour = [[UISnapBehavior alloc] initWithItem:self snapToPoint:CGPointMake(viewBounds.size.width, -74)];
            snapBehaviour.damping = 0.75f;
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
    //Called when a button is tapped on the notification. The notification is then moved off-screen and the caller is notified via delegate that a button was tapped and its index.
    [self dismissWithAnimation:YES];
    if ([[self delegate] respondsToSelector:@selector(notificationView:didDismissWithButtonIndex:)]) {
        [[self delegate] notificationView:self didDismissWithButtonIndex:[sender tag]];
    }
}

//Color methods to create a darker and lighter tone of the notification background color. These colors are used for providing backgrounds to button and make sure that buttons are suited to all color environments.
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
