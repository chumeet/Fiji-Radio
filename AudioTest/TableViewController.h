//
//  TableViewController.h
//  AudioTest
//
//  Created by Sumeet Kumar on 9/28/13.
//  Copyright (c) 2013 KPX. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RadioStation;


@interface TableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *radioStations;
@property (nonatomic, strong) NSMutableArray *arrayOfListeners;
@property (nonatomic, strong) NSDictionary *stationInfo;
@property (strong, nonatomic) UILabel *currentListeners;
@property (nonatomic, strong) RadioStation *currentStation;


-(void) refreshView:(UIRefreshControl *)refresh;
-(void) getListeners;
-(void) getStations;
-(void) animate;


@end
