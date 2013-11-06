//
//  RadioStation.m
//  AudioTest
//
//  Created by Sumeet Kumar on 10/1/13.
//  Copyright (c) 2013 KPX. All rights reserved.
//

#import "RadioStation.h"

@implementation RadioStation


-(RadioStation *) initStationWithURL:(NSURL *) url forName:(NSString *)name withImageURL:(NSURL*)imageURL homePage:(NSString *)homePage {
    self = [super init];
    self.url = url;
    self.name = name;
    self.stationImage = imageURL;
    self.stationHomepage = homePage;
    return self;
}

@end
