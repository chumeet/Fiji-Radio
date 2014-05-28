//
//  ViewController.m
//  AudioTest
//
//  Created by Sumeet Kumar on 9/26/13.
//  Copyright (c) 2013 KPX. All rights reserved.
//

#import "iPadViewController.h"
#import "UIImage+animatedGIF.h"
#include "AppDelegate.h"

@interface iPadViewController ()

@end

@implementation iPadViewController

-(void) animate {
    
    [UIView animateWithDuration:5.5 delay:(0.0) options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAutoreverse ) animations: ^{
        self.statusLabel.alpha =  1.0;
        self.statusLabel.frame = CGRectMake(170, 387, 180, 33);
        [UIView setAnimationRepeatCount:5.5];
        NSLog(@"in animation");
        
    } completion:^(BOOL finished) {
        self.statusLabel.alpha = 1.0;
        self.statusLabel.frame = CGRectMake(439, 387, 180, 33);
    }];
    

    
    
}

-(void) viewWillAppear:(BOOL)animated {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [[UIApplication sharedApplication]beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    if (self.animationImage != nil) {
        self.playOrPauseButton.imageView.image = [UIImage imageNamed:@"Play.png"];
    }
    
    self.volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake( 267, 584, 230, 60)];
    self.currentAudioSession = [AVAudioSession sharedInstance];
    [self.volumeView setShowsRouteButton:YES];
    UIImage *sliderImage = [UIImage imageNamed:@"slider.png"];
    UIImage *smallSlider = [UIImage imageWithCGImage:sliderImage.CGImage scale:2 orientation:sliderImage.imageOrientation];
    UIImage *soundSliderBG = [UIImage imageNamed:@"soundsliderbg.png"];
    UIImage *soundSlider = [UIImage imageNamed:@"soundslider.png"];
    UIImage *smallSoundSliderBG = [UIImage imageWithCGImage:soundSliderBG.CGImage scale:3.5 orientation:soundSliderBG.imageOrientation];
    UIImage *smallSoundSlider = [UIImage imageWithCGImage:soundSlider.CGImage scale:3.5 orientation:soundSlider.imageOrientation];
    [self.volumeView setMaximumVolumeSliderImage:smallSoundSliderBG forState:UIControlStateNormal];
    [self.volumeView setMinimumVolumeSliderImage:smallSoundSlider forState:UIControlStateNormal];
    [self.volumeView setVolumeThumbImage:smallSlider forState:UIControlStateNormal];
    [self.view addSubview:self.volumeView];

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
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication]delegate];
    appDelegate.iPadController = self;
    self.audioData = [[NSMutableData alloc]init];
    [self.activityOutlet setHidesWhenStopped:YES];
    self.musicController = [MPMusicPlayerController iPodMusicPlayer];
    [self.musicController beginGeneratingPlaybackNotifications];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(audioSessionInterrupted:)name:AVAudioSessionInterruptionNotification object:nil];
    
    [self.trackScroll scroll];
    
    if (self.animationImage != nil ) {
        self.playOrPauseButton.imageView.image = [UIImage imageNamed:@"Play.png"];
    }
    
    
    
}


- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object
                         change:(NSDictionary*)change context:(void*)context {
    
    if ([keyPath isEqualToString:@"timedMetadata"])
    {
        AVPlayerItem* playerItem = object;
        
        for (AVMetadataItem* metadata in playerItem.timedMetadata)
        {
            NSLog(@"\nkey: %@\nkeySpace: %@\ncommonKey: %@\nvalue: %@", [metadata.key description], metadata.keySpace, metadata.commonKey, metadata.stringValue);
            self.trackLabel.text = [NSString stringWithFormat:@"%@",metadata.stringValue];
            [self.trackScroll setScrollSpeed:22.0];
            
            if ([[self.currentViewController stationName] isEqualToString:@"Fiji Bhajan Radio"]) {
                self.trackScroll.text = [NSString stringWithFormat:@"%@ - Fiji Bhajan Radio - Special thanks to Jawahar Lal",metadata.stringValue];
            }
            else if ([[self.currentViewController stationName] isEqualToString:@"Radio Dhadkan"] ) {
                AVMetadataItem *metaData = [playerItem.timedMetadata objectAtIndex:0];
                self.trackScroll.text = [NSString stringWithFormat:@"%@ - Radio Dhadkan - Live from Australia - http://radiodhadkan.com.au", metaData.stringValue];
            }
            
            [self.trackScroll setTextColor:[UIColor lightGrayColor]];
            [self.trackScroll setFont:[UIFont fontWithDescriptor:[UIFontDescriptor fontDescriptorWithName:@"Futura" size:10.0] size:10.0]];
            [self.trackScroll readjustLabels];
            [self.trackScroll scroll];
        }
    }
}



-(void) audioSessionInterrupted:(NSNotification *) notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSLog(@"AVAudioSessionInterruptionTypeKey is %@",[userInfo valueForKey:AVAudioSessionInterruptionTypeKey]);
    
    NSLog(@"Value for key %@",[userInfo valueForKey:AVAudioSessionInterruptionOptionKey]);
    
    if (![userInfo valueForKey:AVAudioSessionInterruptionOptionKey]) {
        NSLog(@"Began Interruption");
        self.myPlayer = nil;
        self.connectionLabel.text = @"phone call";
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
        [self animate];
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
        [self.playOrPauseButton setImage:[UIImage imageNamed:@"Play.png"] forState:(UIControlStateNormal)];
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
    
    [self animate];
    
}


-(void) checkStatusOfPlayer {
    
    dispatch_queue_t taskQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(taskQ,   ^{
        while (self.myPlayer.status == AVPlayerStatusUnknown) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.connectionLabel.text = @"connecting";
                
            });
            NSLog(@"Player not ready. %f", [self.currentAudioSession sampleRate]);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Current Status of myPlayer: %ld",(long)[self.myPlayer status]);
            NSError *error;
            [self.currentAudioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
            [self.activityOutlet stopAnimating];
            [self.myPlayer play];
            self.isPlaying = YES;
            self.connectionLabel.text = @"";
            
            AVPlayerItem *songItem = [self.myPlayer currentItem];
            [songItem addObserver:self forKeyPath:@"timedMetadata" options:NSKeyValueObservingOptionNew context:nil];
         
            NSURL *animationURL = [[NSBundle mainBundle] URLForResource:@"equalizer4" withExtension:@"gif"];
            self.animationImage.image = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfURL:animationURL]];
            if (error){
                NSLog(@"%@",[error localizedDescription]);
            }
            NSLog(@"%f",[self.currentAudioSession outputVolume]);
        });
        
        
    });
    
}

-(iPadViewController *)currentViewController {
    
    iPadViewController *viewControllerToReturn = [[iPadViewController alloc]init];
    viewControllerToReturn = self;
    return viewControllerToReturn;
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
    self.animationImage.image = nil;
    self.statusLabel.text = @"";
    NSLog(@"%f",[self.myPlayer rate]);
    if (self.myPlayer.rate == 0.0) {
        [self.playOrPauseButton setImage:[UIImage imageNamed:@"Pause.png"] forState:(UIControlStateNormal)];
        NSLog(@"titleLabel: %@",[self.playOrPauseButton titleLabel]);
    }
    if (self.myPlayer) {
        self.myPlayer = nil;
    }
    self.isPlaying = NO;
    self.trackScroll.text = @"";
    [self.statusLabel.layer removeAllAnimations];
    [self.homeStream.layer removeAllAnimations];
}

@end
