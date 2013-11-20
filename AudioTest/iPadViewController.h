//
//  ViewController.h
//  AudioTest
//
//  Created by Sumeet Kumar on 9/26/13.
//  Copyright (c) 2013 KPX. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;
@import AudioToolbox;
@import MediaPlayer;

@interface iPadViewController : UIViewController <NSURLConnectionDataDelegate, NSURLConnectionDelegate, AVAudioSessionDelegate> {
    
    float fileLength;
    float currentLength;
    float currentProgressView;
}

@property (nonatomic, strong) NSMutableData *audioData;
@property (nonatomic, strong) NSURL *audioURL;
@property (nonatomic,strong) NSURLRequest *audioRequest;
@property (nonatomic, strong) NSURLConnection *audioConnection;
@property (strong, nonatomic) AVPlayer *myPlayer;
@property (nonatomic, strong)   MPVolumeView *volumeView;
@property (nonatomic,strong) MPMusicPlayerController *musicController;
@property (nonatomic, strong) AVAudioSession *currentAudioSession;
@property (strong, nonatomic) IBOutlet UIButton *playOrPauseButton;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityOutlet;
@property (strong, nonatomic) NSString *stationName;
@property (nonatomic, strong) NSString *homePage;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;


-(IBAction)downloadData:(id)sender;
-(IBAction)playOrPause:(id)sender;


-(void) playAudioData: (NSMutableData *)audioData;
-(void) checkStatusOfPlayer;
-(void) audioSessionInterrupted:(NSNotification *) notification;
-(void)playAudio:(NSURL *) url;
-(void)pauseAudio;
@end
