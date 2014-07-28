//
//  ViewController.m
//  MPGNotificationDemo
//
//  Created by Gaurav Wadhwani on 29/06/14.
//  Copyright (c) 2014 Mappgic. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showNotification:(id)sender
{
    NSArray *buttonArray;
    UIImage *icon;
    NSString *subtitle;
    switch ([[_buttonLabel text] intValue]) {
        case 0:
            buttonArray = nil;
            break;
            
        case 1:
            buttonArray = [NSArray arrayWithObject:@"Done"];
            break;
            
        case 2:
            buttonArray = [NSArray arrayWithObjects:@"Reply",@"Later", nil];
            break;
            
        default:
            break;
    }
    
    if ([_iconSwitch isOn]) {
        icon = [UIImage imageNamed:@"ChatIcon"];
    }
    else{
        icon = nil;
    }
    
    if ([_subtitleSwitch isOn]) {
        subtitle = @"Did you hear my new collab on Beatport? It's on #1. It's getting incredible reviews as well. Let me know what you think of it!";
    }
    else{
        subtitle = nil;
    }
    
    notification = [MPGNotification notificationWithTitle:@"Joey Dale" subtitle:subtitle backgroundColor:[_colorChooser tintColor] iconImage:icon];
    [notification setButtonConfiguration:buttonArray.count withButtonTitles:buttonArray];
    notification.duration = 20.0;
    
    notification.firstButtonShowCountdown = YES;
    notification.secondButtonShowCountdown = YES;
    
    __weak typeof(self) weakSelf = self;
    [notification setDismissHandler:^(MPGNotification *notification) {
        [weakSelf.showNotificationButton setEnabled:YES];
    }];
    
    [notification setButtonHandler:^(MPGNotification *notification, NSInteger buttonIndex, NSString *buttonTitle ) {
        NSLog(@"buttonIndex : %d buttonTitle %@", buttonIndex,buttonTitle);
        [weakSelf.showNotificationButton setEnabled:YES];
    }];
    
    if (!([_colorChooser selectedSegmentIndex] == 3 || [_colorChooser selectedSegmentIndex] == 1)) {
        [notification setTitleColor:[UIColor whiteColor]];
        [notification setSubtitleColor:[UIColor whiteColor]];
    }
    
    switch ([_animationType selectedSegmentIndex]) {
        case 0:
            [notification setAnimationType:MPGNotificationAnimationTypeLinear];
            break;
            
        case 1:
            [notification setAnimationType:MPGNotificationAnimationTypeDrop];
            break;
            
        case 2:
            [notification setAnimationType:MPGNotificationAnimationTypeSnap];
            break;
            
        default:
            break;
    }
    
    [notification show];
    [_showNotificationButton setEnabled:NO];
}

- (IBAction)updateButtonCount:(id)sender
{
    [_buttonLabel setText:[NSString stringWithFormat:@"%d", (int)[(UIStepper *)sender value]]];
}

- (IBAction)selectColor:(id)sender
{
    switch ([(UISegmentedControl *)sender selectedSegmentIndex]) {
        case 0:
            [_colorChooser setTintColor:[UIColor colorWithRed:231.0/255.0 green:76.0/255.0 blue:60.0/255.0 alpha:1.0]];
            break;
            
        case 1:
            [_colorChooser setTintColor:[UIColor colorWithRed:46.0/255.0 green:204.0/255.0 blue:113.0/255.0 alpha:1.0]];
            break;
            
        case 2:
            [_colorChooser setTintColor:[UIColor colorWithRed:41.0/255.0 green:128.0/255.0 blue:255.0/255.0 alpha:1.0]];
            break;
            
        case 3:
            [_colorChooser setTintColor:[UIColor colorWithRed:241.0/255.0 green:196.0/255.0 blue:15.0/255.0 alpha:1.0]];
            break;
            
        case 4:
            [_colorChooser setTintColor:[UIColor colorWithRed:52.0/255.0 green:73.0/255.0 blue:94.0/255.0 alpha:1.0]];
            break;
            
        default:
            break;
    }
}

#pragma mark MPGNotificationDelegate Handler

- (void)notificationView:(MPGNotification *)notification didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button Index = %d", buttonIndex);
    [_showNotificationButton setEnabled:YES];
}

@end
