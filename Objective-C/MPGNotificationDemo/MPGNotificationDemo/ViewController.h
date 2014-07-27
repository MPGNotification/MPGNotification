//
//  ViewController.h
//  MPGNotificationDemo
//
//  Created by Gaurav Wadhwani on 29/06/14.
//  Copyright (c) 2014 Mappgic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPGNotification.h"

@interface ViewController : UIViewController
{
    MPGNotification *notification;
}

- (IBAction)showNotification:(id)sender;
- (IBAction)updateButtonCount:(id)sender;
- (IBAction)selectColor:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *showNotificationButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *animationType;
@property (weak, nonatomic) IBOutlet UISwitch *iconSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *subtitleSwitch;
@property (weak, nonatomic) IBOutlet UILabel *buttonLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *colorChooser;


@end
