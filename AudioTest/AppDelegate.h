//
//  AppDelegate.h
//  AudioTest
//
//  Created by Sumeet Kumar on 9/26/13.
//  Copyright (c) 2013 KPX. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ViewController;
@class iPadViewController;
@class TableViewController;


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *myController;
@property (strong, nonatomic) iPadViewController *iPadController;
@property (strong ,nonatomic) TableViewController *tbController;


@end
