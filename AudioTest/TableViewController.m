//
//  TableViewController.m
//  AudioTest
//
//  Created by Sumeet Kumar on 9/28/13.
//  Copyright (c) 2013 KPX. All rights reserved.
//

#import "TableViewController.h"
#import "ViewController.h"
#import "RadioStation.h"
#include "AppDelegate.h"

@interface TableViewController ()

@end

@implementation TableViewController

-(void) viewWillAppear:(BOOL)animated {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
     [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
  
    
}

-(void) animate {
    [UIView animateWithDuration:2.0 delay:(0.0) options:(UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionAutoreverse) animations:^{
        self.tableView.alpha = 0.0;
        [UIView setAnimationRepeatCount:2.0];
    } completion:^(BOOL finished) {
        self.tableView.alpha = 1.0;
    }];
    
}

-(void) refreshView:(UIRefreshControl *)refresh {
    
    refresh.attributedTitle = [[NSAttributedString alloc]initWithString:@"Refreshing listeners count"];
    
    self.radioStations = nil;
    self.currentListeners = nil;
    self.arrayOfListeners = nil;
    
    self.radioStations = [[NSMutableArray alloc]init];
    self.arrayOfListeners = [[NSMutableArray alloc]init];
  
    
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
    
    NSArray *arrayOfStations = [NSArray arrayWithObjects:bulaFM,radioFijiGold,radioMirchi,radioFijiOne,radioFijiTwo,nil];
    
    NSError *error;
    NSString *initialString = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://icast3.streamcom.net:8000"] encoding:NSUTF8StringEncoding error:&error];
    
    NSArray *arrayOfLinklines = [initialString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSLog(@"%@",arrayOfLinklines);
    
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

-(void) getStations {
    NSData *newData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http:/www.kumarsxray.com/station"]];
    
    NSDictionary *newStations = [ NSJSONSerialization JSONObjectWithData:newData options:NSJSONReadingMutableContainers error:nil];
    //        NSLog(@"New Stations: %@",newStations);
    
    for (NSDictionary *bpDictionary in newStations) {
        RadioStation *newStation = [[RadioStation alloc]init];
        newStation.url = [NSURL URLWithString:[bpDictionary objectForKey:@"url"]];
        newStation.name = [bpDictionary objectForKey:@"name"];
        newStation.stationHomepage = [bpDictionary objectForKey:@"homePage"];
        newStation.stationImage = [NSURL URLWithString:[bpDictionary objectForKey:@"imageURL"]];
        
        [self.radioStations addObject:newStation];
    
}
}
- (void)viewDidLoad {

    [super viewDidLoad];
    self.radioStations = [[NSMutableArray alloc]init];
    
    self.tableView.backgroundColor = [UIColor blackColor];
    
    self.arrayOfListeners = [[NSMutableArray alloc]init];
    
     // Create RadioStations
    [self getStations];
    
    //Get Listner Count
    [self getListeners];
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication]delegate];
    appDelegate.tbController = self;
    
    
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc]init];
    refresh.attributedTitle = [[NSAttributedString alloc]initWithString:@"Pull to refresh"];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    if ([self.radioStations isKindOfClass:[NSMutableArray class]]) {
        
    }
    
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
    cell.backgroundColor = [UIColor blackColor];
    cell.textLabel.textColor = [UIColor lightGrayColor];
    ((UILabel *)[cell viewWithTag:1]).text = [currentStation name];
    ((UILabel *)[cell viewWithTag:3]).text = [currentStation stationHomepage];
    ((UILabel *)[cell viewWithTag:2]).text = [NSString stringWithFormat:@"unprovided"];
    
    cell.detailTextLabel.text = [currentStation stationHomepage];
    
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
    if ([currentStation.name  isEqual: @"Radio Sargam"]) {
        ((UILabel *)[cell viewWithTag:2]).text =  [NSString stringWithFormat:@"unlimited"] ;
    }
    if ([currentStation.name  isEqual: @"Navtarang"]) {
        ((UILabel *)[cell viewWithTag:2]).text =  [NSString stringWithFormat:@"unlimited"] ;
    }
    if ([currentStation.name  isEqual: @"FM 90.6"]) {
        ((UILabel *)[cell viewWithTag:2]).text =  [NSString stringWithFormat:@"unlimited"];
    }
    if ([currentStation.name  isEqual: @"Tambura Bhajan Radio"]) {
        ((UILabel *)[cell viewWithTag:2]).text =  [NSString stringWithFormat:@"unlimited"] ;
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
    
    NSURL *urlToSend = [currentStation url];
    
    NSLog( @"current station name : %@", [currentStation name]);
    [[segue destinationViewController]setStationName:[currentStation name]];
    [[segue destinationViewController]setAudioURL:urlToSend];
    [[segue destinationViewController]setHomePage:[currentStation stationHomepage]];
    //Get the new view controller using [segue destinationViewController].
    //Pass the selected object to the new view controller.
}

 

@end
