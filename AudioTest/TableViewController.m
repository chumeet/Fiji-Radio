//
//  TableViewController.m
//  AudioTest
//
//  Created by Sumeet Kumar on 9/28/13.
//  Copyright (c) 2013 KPX. All rights reserved.
//

#import "TableViewController.h"
#import "RadioStation.h"
#include "AppDelegate.h"
#import "UIImage+animatedGIF.h"

@interface TableViewController ()

@end

@implementation TableViewController

-(void) viewWillAppear:(BOOL)animated {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
     [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.tableView reloadData];
  
    
}

//-(void) animate {
//    [UIView animateWithDuration:2.0 delay:(0.0) options:(UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionAutoreverse) animations:^{
//        self.tableView.alpha = 0.0;
//        [UIView setAnimationRepeatCount:2.0];
//    } completion:^(BOOL finished) {
//        self.tableView.alpha = 1.0;
//    }];
//    
//}

-(void) refreshTimer {
    self.radioStations = nil;
    self.currentListeners = nil;
    self.arrayOfListeners = nil;
    
    self.radioStations = [[NSMutableArray alloc]init];
    self.arrayOfListeners = [[NSMutableArray alloc]init];
  
    [self getStations];
    [self getListeners];
    
    [self.tableView reloadData];
    
    NSLog(@"Timer Fired!");
    
}

-(void) refreshView:(UIRefreshControl *)refresh {
    
    refresh.attributedTitle = [[NSAttributedString alloc]initWithString:@"Refreshing Listeners"];
    
    self.radioStations = nil;
    self.currentListeners = nil;
    self.arrayOfListeners = nil;
    
    self.radioStations = [[NSMutableArray alloc]init];
    self.arrayOfListeners = [[NSMutableArray alloc]init];
  
   
    
    NSLog(@"Currently playing Station: %@", self.currentPlayingViewController.stationName);
    NSLog(@"Playing? : %hhd",(char)self.currentPlayingViewController.isPlaying);
    
    [self getStations];
    [self getListeners];
    
    
    [self.tableView reloadData];
    
    [refresh endRefreshing];
    
 
    
    
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) getListeners {
    
    //NSNumber objects with int value for the line of HTML code to extract the value of current listeners from.
    NSNumber *bulaFM = [NSNumber numberWithInt:110];
    NSNumber *radioFijiGold = [NSNumber numberWithInt:168];
    NSNumber *radioMirchi = [NSNumber numberWithInt:226];
    NSNumber *radioFijiOne = [NSNumber numberWithInt:284];
    NSNumber *radioFijiTwo = [NSNumber numberWithInt:342];
    NSNumber *radioTarana = [NSNumber numberWithInteger:400];
  
    
    NSArray *arrayOfStations = [NSArray arrayWithObjects:bulaFM,radioFijiGold,radioMirchi,radioFijiOne,radioFijiTwo,radioTarana, nil];
    NSArray *arrayOfLinklines;
    
    NSError *error;
    NSString *initialString;
    NSURL *fbcListenerURL = [NSURL URLWithString:@"http://icast3.streamcom.net:8000"];
  
    
    if ( [[UIApplication sharedApplication] canOpenURL:[fbcListenerURL absoluteURL]] )
    {
        initialString = [NSString stringWithContentsOfURL:fbcListenerURL encoding:NSUTF8StringEncoding error:&error];
    }
    else {
        NSLog(@"Failed to open fbcListenerURL");
    }
    
    
    if (initialString) {
    arrayOfLinklines = [initialString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSLog(@"Number of arrayOfLinkLines : %lu", (unsigned long)[arrayOfLinklines count]);
    }
    
    if ([arrayOfLinklines count] == 426 ) {
    for (NSNumber *number in arrayOfStations ) {
        
        
        //Get full line of code from HTML file using the line-number specified in arrayOfStations
        NSString *currentLink = [arrayOfLinklines objectAtIndex:[number intValue]];
        
        //Trim string so only the current listeners number is left
        NSString *trimmedString = [currentLink stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<td class=\"streamdata\">"]];
        NSString *finalString = [trimmedString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"</"]];
        NSLog(@"%@",finalString);
        
        [self.arrayOfListeners addObject:finalString];
        
    }
        
    }
    
    else {
        for (NSNumber *number in arrayOfStations) {
            NSString *unavailableString = [NSString stringWithFormat:@"-"];
            [self.arrayOfListeners addObject:unavailableString];
        }
    }
}

-(void) getStations {
    NSData *newData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.kumarsxray.com/station"]];
    
    if (newData) {
    NSDictionary *newStations = [ NSJSONSerialization JSONObjectWithData:newData options:NSJSONReadingMutableContainers error:nil];
        
    
    for (NSDictionary *bpDictionary in newStations) {
        RadioStation *newStation = [[RadioStation alloc]init];
        newStation.url = [NSURL URLWithString:[bpDictionary objectForKey:@"url"]];
        newStation.name = [bpDictionary objectForKey:@"name"];
        newStation.stationHomepage = [bpDictionary objectForKey:@"homePage"];
        newStation.stationImage = [NSURL URLWithString:[bpDictionary objectForKey:@"imageURL"]];
        
        [self.radioStations addObject:newStation];
    
}
    }
    else {
        RadioStation *noInternetStation = [[RadioStation alloc]init];
        noInternetStation.url = [NSURL URLWithString:@"Please check your internet connection"];
        noInternetStation.name = @"Check your internet connection";
        noInternetStation.stationHomepage = @"N/A";
        noInternetStation.stationImage = [NSURL URLWithString:@"N/A"];
        [self.radioStations addObject:noInternetStation];
    }
}
- (void)viewDidLoad {

    [super viewDidLoad];
    UIImage *magImage = [UIImage imageNamed:@"magnifier.png"];
    NSData *magImageData = UIImagePNGRepresentation(magImage);
    UIImage *scaledMagImage = [UIImage imageWithData:magImageData scale:2.0];
    [self.magButton setImage:scaledMagImage];
    UIImage *settingsImage = [UIImage imageNamed:@"settings.png"];
    NSData *settingsImageData = UIImagePNGRepresentation(settingsImage);
    UIImage *scaledSettingsImage = [UIImage imageWithData:settingsImageData scale:2.0];
    [self.settingsButton setImage:scaledSettingsImage];
    
    self.radioStations = [[NSMutableArray alloc]init];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
   
    self.arrayOfListeners = [[NSMutableArray alloc]init];
    
     // Create RadioStations
    [self getStations];
    
    //Get Listner Count
    [self getListeners];
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication]delegate];
    appDelegate.tbController = self;
    
    
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc]init];
    refresh.attributedTitle = [[NSAttributedString alloc]initWithString:@"Refreshing Listeners"];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    if ([self.radioStations isKindOfClass:[NSMutableArray class]]) {
        
    }
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:300.0
                                             target:self
                                            selector:@selector(refreshTimer)
                                           userInfo:nil
                                            repeats:YES];
    
    [timer fire];

    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.radioStations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    RadioStation *currentStation = [self.radioStations objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor blackColor];
    UIImage *yellowArrow = [UIImage imageNamed:@"rightarrowyellow.png"];
    NSData *yellowArrowData = UIImagePNGRepresentation(yellowArrow);
    UIImage *scaledYellowArrow = [UIImage imageWithData:yellowArrowData scale:2.0];
    UIImageView *accessoryImage = [[UIImageView alloc]initWithImage:scaledYellowArrow];
    [cell setAccessoryView:accessoryImage];
    ((UILabel *)[cell viewWithTag:1]).text = [currentStation name];
    ((UILabel *)[cell viewWithTag:3]).text = [currentStation stationHomepage];
    ((UILabel *)[cell viewWithTag:2]).text = [NSString stringWithFormat:@"Unprovided"];
    
    cell.detailTextLabel.text = [currentStation stationHomepage];
    
    UILabel *listenerlabel = ((UILabel *)[cell viewWithTag:2]);
    UIColor *listenerColor = [listenerlabel textColor];
    self.fullLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 25, 20)];
    __unused UIColor *fullLabelColor = [UIColor colorWithRed:255.0 green:103.0 blue:112.0 alpha:1.0];
    self.fullLabel.textColor = listenerColor;
    self.fullLabel.font = [UIFont fontWithName:@"Verdana" size:10];
    self.fullLabel.text = @"FULL";
    
    if ([currentStation.name isEqualToString:[self.currentPlayingViewController stationName]] && self.currentPlayingViewController.isPlaying == 1 ) {
        NSURL *animationURL = [[NSBundle mainBundle] URLForResource:@"smallequalizer" withExtension:@"gif"];
        ((UIImageView *)[cell viewWithTag:5]).image  = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfURL:animationURL]];
    }
    
    else {
        ((UIImageView *)[cell viewWithTag:5]).image = nil;
    }

    
    
    // Configure the cell...
    
    if ([currentStation.name  isEqual: @"Bula FM"]) {
       ((UILabel *)[cell viewWithTag:2]).text =  [NSString stringWithFormat:@"%@/40",[self.arrayOfListeners objectAtIndex:0]] ;
    }
    if ([currentStation.name  isEqual: @"Radio Fiji Gold"]) {
        ((UILabel *)[cell viewWithTag:2]).text =  [NSString stringWithFormat:@"%@/13",[self.arrayOfListeners objectAtIndex:1]] ;
    }
    if ([currentStation.name  isEqual: @"Radio Mirchi"]) {
        ((UILabel *)[cell viewWithTag:2]).text =   [NSString stringWithFormat:@"%@/100",[self.arrayOfListeners objectAtIndex:2]] ;
    }
    if ([currentStation.name  isEqual: @"Radio Fiji 1"]) {
        ((UILabel *)[cell viewWithTag:2]).text =  [NSString stringWithFormat:@"%@/25",[self.arrayOfListeners objectAtIndex:3]] ;
    }
    if ([currentStation.name  isEqual: @"Radio Fiji 2"]) {
      ((UILabel *)[cell viewWithTag:2]).text =  [NSString stringWithFormat:@"%@/100",[self.arrayOfListeners objectAtIndex:4]] ;
    }
    if ([currentStation.name  isEqual: @"Radio Tarana"]) {
        ((UILabel *)[cell viewWithTag:2]).text =  [NSString stringWithFormat:@"%@/14",[self.arrayOfListeners objectAtIndex:5]] ;
    }
    if ([currentStation.name  isEqual: @"Radio Sargam"]) {
        ((UILabel *)[cell viewWithTag:2]).text =  [NSString stringWithFormat:@"Unlimited"] ;
    }
    if ([currentStation.name  isEqual: @"Navtarang"]) {
        ((UILabel *)[cell viewWithTag:2]).text =  [NSString stringWithFormat:@"Unlimited"] ;
    }
    if ([currentStation.name  isEqual: @"FM 90.6"]) {
        ((UILabel *)[cell viewWithTag:2]).text =  [NSString stringWithFormat:@"Unlimited"];
    }
    if ([currentStation.name  isEqual: @"Tambura Bhajan Radio"]) {
        ((UILabel *)[cell viewWithTag:2]).text =  [NSString stringWithFormat:@"Unlimited"] ;
    }
    
    if ([currentStation.name isEqualToString:@"Check your internet connection"]) {
        ((UILabel *)[cell viewWithTag:1]).alpha = 0.3;
        ((UILabel *)[cell viewWithTag:2]).alpha = 0.3;
        ((UILabel *)[cell viewWithTag:3]).alpha = 0.3;
        ((UILabel *)[cell viewWithTag:4]).alpha = 0.3;
        ((UILabel *)[cell viewWithTag:2]).text = @"N/A";
        self.fullLabel.text = @"N/A";
        [cell setAccessoryView:self.fullLabel];
        [[cell accessoryView]setAlpha:0.3];
        [cell setAlpha:0.3];
        [cell setUserInteractionEnabled:NO];
        return cell;
        
    }
    
    if ([currentStation.name isEqualToString:@"Radio Tarana"] && [[self.arrayOfListeners objectAtIndex:5] isEqualToString:@"14"]){
        
        
        ((UILabel *)[cell viewWithTag:1]).alpha = 0.3;
        ((UILabel *)[cell viewWithTag:2]).alpha = 0.3;
        ((UILabel *)[cell viewWithTag:3]).alpha = 0.3;
        ((UILabel *)[cell viewWithTag:4]).alpha = 0.3;
        [cell setAccessoryView:self.fullLabel];
        [[cell accessoryView]setAlpha:0.3];
        [cell setAlpha:0.3];
        [cell setUserInteractionEnabled:NO];
        return cell;
    }
    
    else {
        
        ((UILabel *)[cell viewWithTag:1]).alpha = 1.0;
        ((UILabel *)[cell viewWithTag:2]).alpha = 1.0;
        ((UILabel *)[cell viewWithTag:3]).alpha = 1.0;
        ((UILabel *)[cell viewWithTag:4]).alpha = 1.0;
        
        [cell setUserInteractionEnabled:YES];
        
    }
    
    if ([currentStation.name isEqualToString:@"Radio Fiji 1"] && [[self.arrayOfListeners objectAtIndex:3] isEqualToString:@"25"]){
        
        
        ((UILabel *)[cell viewWithTag:1]).alpha = 0.3;
        ((UILabel *)[cell viewWithTag:2]).alpha = 0.3;
        ((UILabel *)[cell viewWithTag:3]).alpha = 0.3;
        ((UILabel *)[cell viewWithTag:4]).alpha = 0.3;
        [cell setAccessoryView:self.fullLabel];
        [[cell accessoryView]setAlpha:0.3];
        [cell setAlpha:0.3];
        [cell setUserInteractionEnabled:NO];
        return cell;
    }
    
    else {
        
        ((UILabel *)[cell viewWithTag:1]).alpha = 1.0;
        ((UILabel *)[cell viewWithTag:2]).alpha = 1.0;
        ((UILabel *)[cell viewWithTag:3]).alpha = 1.0;
        ((UILabel *)[cell viewWithTag:4]).alpha = 1.0;
        
        [cell setUserInteractionEnabled:YES];
        
    }
    
    if ([currentStation.name isEqualToString:@"Radio Fiji Gold"] && [[self.arrayOfListeners objectAtIndex:1] isEqualToString:@"13"]){
        
        
        ((UILabel *)[cell viewWithTag:1]).alpha = 0.3;
        ((UILabel *)[cell viewWithTag:2]).alpha = 0.3;
        ((UILabel *)[cell viewWithTag:3]).alpha = 0.3;
        ((UILabel *)[cell viewWithTag:4]).alpha = 0.3;
        [cell setAccessoryView:self.fullLabel];
        [[cell accessoryView]setAlpha:0.3];
        [cell setAlpha:0.3];
        [cell setUserInteractionEnabled:NO];
        return cell;
    }
    
    else {
        
        ((UILabel *)[cell viewWithTag:1]).alpha = 1.0;
        ((UILabel *)[cell viewWithTag:2]).alpha = 1.0;
        ((UILabel *)[cell viewWithTag:3]).alpha = 1.0;
        ((UILabel *)[cell viewWithTag:4]).alpha = 1.0;
        
        [cell setUserInteractionEnabled:YES];
        
    }
    
    if ([currentStation.name isEqualToString:@"Bula FM"] && [[self.arrayOfListeners objectAtIndex:0] isEqualToString:@"40"]){
        
        
        ((UILabel *)[cell viewWithTag:1]).alpha = 0.3;
        ((UILabel *)[cell viewWithTag:2]).alpha = 0.3;
        ((UILabel *)[cell viewWithTag:3]).alpha = 0.3;
        ((UILabel *)[cell viewWithTag:4]).alpha = 0.3;
        [cell setAccessoryView:self.fullLabel];
        [[cell accessoryView]setAlpha:0.3];
        [cell setAlpha:0.3];
        [cell setUserInteractionEnabled:NO];
        return cell;
    }
    
    else {
        
        ((UILabel *)[cell viewWithTag:1]).alpha = 1.0;
        ((UILabel *)[cell viewWithTag:2]).alpha = 1.0;
        ((UILabel *)[cell viewWithTag:3]).alpha = 1.0;
        ((UILabel *)[cell viewWithTag:4]).alpha = 1.0;
        
        [cell setUserInteractionEnabled:YES];
        
    }
    
    if ([currentStation.name isEqualToString:@"Radio Mirchi"] && [[self.arrayOfListeners objectAtIndex:2] isEqualToString:@"100"]){
      
        
        ((UILabel *)[cell viewWithTag:1]).alpha = 0.3;
        ((UILabel *)[cell viewWithTag:2]).alpha = 0.3;
        ((UILabel *)[cell viewWithTag:3]).alpha = 0.3;
        ((UILabel *)[cell viewWithTag:4]).alpha = 0.3;
        [cell setAccessoryView:self.fullLabel];
        [[cell accessoryView]setAlpha:0.3];
        [cell setAlpha:0.3];
        [cell setUserInteractionEnabled:NO];
        return cell;
    }
    
    else {
       
        ((UILabel *)[cell viewWithTag:1]).alpha = 1.0;
        ((UILabel *)[cell viewWithTag:2]).alpha = 1.0;
        ((UILabel *)[cell viewWithTag:3]).alpha = 1.0;
        ((UILabel *)[cell viewWithTag:4]).alpha = 1.0;
        
        [cell setUserInteractionEnabled:YES];
        
    }
    
    if ([currentStation.name isEqualToString:@"Radio Fiji 2"] && [[self.arrayOfListeners objectAtIndex:4] isEqualToString:@"100"]) {
     
        
        ((UILabel *)[cell viewWithTag:1]).alpha = 0.3;
        ((UILabel *)[cell viewWithTag:2]).alpha = 0.3;
        ((UILabel *)[cell viewWithTag:3]).alpha = 0.3;
        ((UILabel *)[cell viewWithTag:4]).alpha = 0.3;
        [cell setAccessoryView:self.fullLabel];
        [[cell accessoryView]setAlpha:0.3];
        [cell setAlpha:0.3];
        [cell setUserInteractionEnabled:NO];
        return cell;
    }
    
    else {
        
        ((UILabel *)[cell viewWithTag:1]).alpha = 1.0;
        ((UILabel *)[cell viewWithTag:2]).alpha = 1.0;
        ((UILabel *)[cell viewWithTag:3]).alpha = 1.0;
        ((UILabel *)[cell viewWithTag:4]).alpha = 1.0;
        
        [cell setUserInteractionEnabled:YES];
        
    }
  

    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
    
   
}


#pragma mark - Navigation

 //In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    RadioStation *currentStation = [self.radioStations objectAtIndex:indexPath.row];
    
    self.currentPlayingViewController = [segue destinationViewController];
    NSURL *urlToSend = [currentStation url];
    
    NSLog( @"current station name : %@", [currentStation name]);
    [[segue destinationViewController]setStationName:[currentStation name]];
    [[segue destinationViewController]setAudioURL:urlToSend];
    [[segue destinationViewController]setHomePage:[currentStation stationHomepage]];
    //Get the new view controller using [segue destinationViewController].
    //Pass the selected object to the new view controller.
}

 

@end
