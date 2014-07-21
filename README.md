MPGNotification
===============

MPGNotifications is an iOS control that allows you to display in-app interactive notifications that are fully customisable to suit your needs.

![MPGNotification Screenshot}]("https://s3.amazonaws.com/cocoacontrols_production/uploads/control_image/image/4171/iOS_Simulator_Screen_shot_10-Jul-2014_11.52.04_pm.png")

# Overview
`MPGNotification` objects are `UIView` objects. They are displayed on top of "everything" using logic that grabs the level of the top-most window (as reported by `UIApplciation`).

# Initialization
Initializing an `MPGNotification` object is simple - just use init! Or new!
``` obj-c
MPGNotification *notification = [[MPGNotification alloc] init];
MPGNotification *anotherNotification = [MPGNotification new];
```

You may also use the following convenience method to initialize with many of the "basic" visualization properties already set:

``` obj-c
MPGNotification *easyNotification = [MPGNotification notificationWithTitle:@"Greetings!"
                                                                  subtitle:@"Did you know we have Notifications now?"
                                                           backgroundColor:[UIColor redColor]
                                                                 iconImage:[UIImage imageNamed:@"radical"]];
```