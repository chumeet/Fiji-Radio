//
//  RadioStation.h
//  AudioTest
//
//  Created by Sumeet Kumar on 10/1/13.
//  Copyright (c) 2013 KPX. All rights reserved.
//

@import Foundation;

@interface RadioStation : NSObject

@property (strong, nonatomic) NSURL *url;
@property (strong,nonatomic) NSString *name;
@property (strong, nonatomic) NSURL *stationImage;
@property (strong, nonatomic) NSString *stationHomepage;

-(RadioStation *) initStationWithURL:(NSURL *) url forName:(NSString *)name withImageURL:(NSURL*)imageURL homePage:(NSString *)homePage;

@end
