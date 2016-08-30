//
//  DetailViewController.m
//  BackgroundAudioSampleApp
//
//  Created by DILIP KOSURI on 15/08/2016.
//
//

#import "DetailViewController.h"
#import "TestMusicPlayer.h"

@interface DetailViewController ()
@property (strong, nonatomic) TestMusicPlayer *musicPlayer;

@property (weak, nonatomic) IBOutlet UILabel *songTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *songIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

-(void)setArtistAlbum:(NSDictionary *)newArtistAlbum {
    if (_artistAlbum != newArtistAlbum) {
        _artistAlbum = newArtistAlbum;
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.artistAlbum) {
        self.artistNameLabel.text = self.artistAlbum[@"artist"];
        self.albumNameLabel.text = self.artistAlbum[@"album"];
        NSDictionary *song = [self.artistAlbum[@"songs"] objectAtIndex:self.songIndex];
        self.songTitleLabel.text = song[@"title"];
        self.songIdLabel.text = [NSString stringWithFormat:@"%@", song[@"songId"]];

    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    [TestMusicPlayer initSession];
    self.musicPlayer = [[TestMusicPlayer alloc]init];

}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //play song
    NSDictionary *song = [self.artistAlbum[@"songs"] objectAtIndex:self.songIndex];
    [self.musicPlayer playSongWithId:song[@"songId"] songTitle:song[@"title"] artist:self.artistAlbum[@"artist"]];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    
    [self.musicPlayer clear];
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - user actions
-(IBAction)playPauseButtonTapped:(UIButton*)button
{
    if ([button.titleLabel.text isEqualToString:@"Pause"]) {
        [self.musicPlayer pause];
        [button setTitle:@"Play" forState:UIControlStateNormal];
    } else {
        [self.musicPlayer play];
        [button setTitle:@"Pause" forState:UIControlStateNormal];
    }
}

#pragma mark - remote control events
- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    [self.musicPlayer remoteControlReceivedWithEvent:receivedEvent];
}

#pragma mark - audio session management
- (BOOL) canBecomeFirstResponder {
    return YES;
}

@end



