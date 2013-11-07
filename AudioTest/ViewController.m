//
//  ViewController.m
//  AudioTest
//
//  Created by Sumeet Kumar on 9/26/13.
//  Copyright (c) 2013 KPX. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

-(void) viewWillAppear:(BOOL)animated {
    [self.view setBackgroundColor:[UIColor blackColor]];
    [[UIApplication sharedApplication]beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    self.volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake( 50, 260, 210, 60)];
//    [self.volumeView setVolumeThumbImage:[UIImage imageNamed:@"slider.png"] forState:UIControlStateNormal];
    [self.volumeView setShowsRouteButton:YES];
    [self.view addSubview:self.volumeView];
    self.currentAudioSession = [AVAudioSession sharedInstance];
    [self.nameLabel setText:self.stationName];
    [self.homePageLabel setText:self.homePage];
    
    
    
}
- (void)viewWillDisappear:(BOOL)animated {
    
    // Turn off remote control event delivery
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    
    // Resign as first responder
    [self resignFirstResponder];
    
    [super viewWillDisappear:animated];
}
-(void) viewDidAppear:(BOOL)animated {
    [[UIApplication sharedApplication]beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

-(void) remoteControlReceivedWithEvent:(UIEvent *)event {
    if (event.type == UIEventTypeRemoteControl) {
        
        switch (event.subtype) {
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self playOrPause:self]; ;
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
//                [self previousTrack: nil];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
//                [self nextTrack: nil];
                break;
                
            default:
                break;
        }
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.audioData = [[NSMutableData alloc]init];
    [self.activityOutlet setHidesWhenStopped:YES];
    self.musicController = [MPMusicPlayerController iPodMusicPlayer];
    [self.musicController beginGeneratingPlaybackNotifications];
        // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(audioSessionInterrupted:)name:AVAudioSessionInterruptionNotification object:nil];
    
    
}

-(void) audioSessionInterrupted:(NSNotification *) notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSLog(@"AVAudioSessionInterruptionTypeKey is %@",[userInfo valueForKey:AVAudioSessionInterruptionTypeKey]);
 
    NSLog(@"Value for key %@",[userInfo valueForKey:AVAudioSessionInterruptionOptionKey]);
    
    if (![userInfo valueForKey:AVAudioSessionInterruptionOptionKey]) {
        NSLog(@"Began Interruption");
        self.myPlayer = nil;
        self.statusLabel.text = @"phone call";
    }
    
    NSLog(@"Notifiction: %@",[notification name]);
    
    if ([userInfo valueForKey:AVAudioSessionInterruptionOptionKey]) {
        NSError *error;
        NSLog(@"Activating Session");
        [self.currentAudioSession setActive:YES error:&error];
        if (error) {
            NSLog(@"Error activating audio session: %@",[error localizedDescription]);
        }
        
        [self playAudio:self.audioURL];
    }
    }

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  
}

-(IBAction)downloadData:(id)sender {
    NSLog(@"Current Volume: %f - Category: %@ - Mode: %@",[self.currentAudioSession outputVolume], [self.currentAudioSession category], [self.currentAudioSession mode]);
//    self.audioConnection = [NSURLConnection connectionWithRequest:self.audioRequest delegate:self];
}


-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
}

-(IBAction)playOrPause:(id)sender {
    if (self.myPlayer.rate == 1.0) {
        [self pauseAudio];
    }
    else {
        [self.playOrPauseButton setImage:[UIImage imageNamed:@"Pause.png"] forState:(UIControlStateNormal)];
        [self playAudio:self.audioURL];
        
    }
}


-(BOOL) becomeFirstResponder {
    [super becomeFirstResponder];
    NSLog(@"First Responder method called");
    return [super becomeFirstResponder];
    
}

-(BOOL) resignFirstResponder {
    [super resignFirstResponder];
    NSLog(@"Resign first responder called");
    return [super resignFirstResponder];
}

-(BOOL) canBecomeFirstResponder {
    return YES;
}
-(void)playAudio:(NSURL *)url {
    
    
    if (self.myPlayer) {
        self.myPlayer=nil;
    }
    
    if (!self.myPlayer) {
    self.myPlayer = [[AVPlayer alloc]initWithURL:self.audioURL];
    }
    
    if (self.myPlayer  == nil) {
        NSLog(@"%@",[[self.myPlayer error]localizedDescription]);
    }
    else {
        [self.activityOutlet startAnimating];
        NSError *error;
        if ([self.currentAudioSession setActive:YES error:&error]) {
            [self.myPlayer play];
            NSLog(@"Success activating audio session");
        }
        else {
            NSLog(@"Error activating audio session: %@",[error localizedDescription]);
        }
    }
    [self checkStatusOfPlayer];
    
  
    [UIView animateWithDuration:2.5 delay:(0.2) options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveEaseInOut) animations: ^{
        self.statusLabel.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:2.5 animations:^{
            self.statusLabel.alpha = 1;
        }];
    }];
   
 
}


-(void) checkStatusOfPlayer {

    dispatch_queue_t taskQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(taskQ,   ^{
        while (self.myPlayer.status == AVPlayerStatusUnknown) {
           dispatch_async(dispatch_get_main_queue(), ^{
               self.statusLabel.text = @"connecting";
               
           });

            
        NSLog(@"Player not ready. %f", [self.currentAudioSession sampleRate]);
    }
        
        dispatch_async(dispatch_get_main_queue(), ^{
             NSLog(@"Current Status of myPlayer: %ld",(long)[self.myPlayer status]);
            NSError *error;
            [self.currentAudioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
            [self.activityOutlet stopAnimating];
            [self.myPlayer play];
            self.statusLabel.text = [NSString stringWithFormat:@"streaming"];
            if (error){
                NSLog(@"%@",[error localizedDescription]);
            }
        NSLog(@"%f",[self.currentAudioSession outputVolume]);
        });
        
       
    });

}


-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) playAudioData:(NSMutableData *)audioData {
    
    
}

-(void)pauseAudio {
    [self.myPlayer pause];
    
    self.statusLabel.text = @"";
    NSLog(@"%f",[self.myPlayer rate]);
    if (self.myPlayer.rate == 0.0) {
        [self.playOrPauseButton setImage:[UIImage imageNamed:@"Play.png"] forState:(UIControlStateNormal)];
        NSLog(@"titleLabel: %@",[self.playOrPauseButton titleLabel]);
    }
    if (self.myPlayer) {
        self.myPlayer = nil;
    }
    
    [self.statusLabel.layer removeAllAnimations];
    
}

@end
