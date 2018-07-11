//
//  JoystickMemorySettingsViewController.m
//  Joystick Memory
//
//  Created by Chris Comeau on 2014-08-07.
//  Copyright (c) 2014 Skyriser Media. All rights reserved.
//

#import "JoystickMemorySettingsViewController.h"

@interface JoystickMemorySettingsViewController ()

@property (weak, nonatomic) IBOutlet UISlider *soundVolumeSlider;
@property (weak, nonatomic) IBOutlet UISlider *musicVolumeSlider;
@property (weak, nonatomic) IBOutlet UILabel *soundLabel;
@property (weak, nonatomic) IBOutlet UILabel *musicLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (strong, nonatomic) UIImageView *fadeView;

- (IBAction)actionBack:(id)sender;

@end

@implementation JoystickMemorySettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //back
    self.backButton.titleLabel.font = [UIFont fontWithName:@"FeastofFleshBB" size:18];
    self.backButton.titleEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0);
    self.backButton.titleLabel.alpha = 0.6f;
    self.backButton.adjustsImageWhenHighlighted = NO;
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"button_white_up"] forState:UIControlStateNormal];
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"button_white_down"] forState:(UIControlStateHighlighted)];
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"button_white_down"] forState:(UIControlStateSelected)];
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"button_white_down"] forState:(UIControlStateSelected | UIControlStateHighlighted)];
    
    
    //labels
    self.soundLabel.font = [UIFont fontWithName:@"FeastofFleshBB" size:24];
    self.musicLabel.font = [UIFont fontWithName:@"FeastofFleshBB" size:24];

    //slider
    self.soundVolumeSlider.tintColor = RGB(100,100,100);
    self.soundVolumeSlider.minimumValue = 0;
    self.soundVolumeSlider.maximumValue = 1;
    self.soundVolumeSlider.value = kAppDelegate.soundVolume;
    [self.soundVolumeSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];

    self.musicVolumeSlider.tintColor = self.soundVolumeSlider.tintColor;
    self.musicVolumeSlider.minimumValue = 0;
    self.musicVolumeSlider.maximumValue = 1;
    self.musicVolumeSlider.value = kAppDelegate.musicVolume;
    [self.musicVolumeSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];

    //fade
    self.fadeView = [[UIImageView alloc] init];
    self.fadeView.contentMode = UIViewContentModeScaleAspectFill;
    self.fadeView.frame = self.view.bounds;
    self.fadeView.image = [kHelpers imageWithColor:kFadeColor andSize:self.fadeView.frame.size];
    self.fadeView.userInteractionEnabled = NO;
    self.fadeView.alpha = 0.0f;
    [self.view addSubview:self.fadeView];
    [self.view bringSubviewToFront:self.fadeView];

}
- (void)fade:(BOOL)fade animated:(BOOL)animated {
    
    float fadeFull = 1.0f;
    
    if(fade)
        self.fadeView.alpha = 0.0f;
    else
        self.fadeView.alpha = fadeFull;
    
    float duration = 0.0f;
    if(animated)
        duration = kFadeDuration;
    
    [UIView animateWithDuration:duration animations:^{
        
        if(fade)
            self.fadeView.alpha = fadeFull;
        else
            self.fadeView.alpha = 0.0f;
        
    }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)viewWillAppear:(BOOL)animated{
    [self fade:NO animated:YES];

    //google analytics
    [kHelpers setupGoogleAnalyticsForView:[[self class] description]];
}


- (void)viewDidAppear:(BOOL)animated{
    //[kAppDelegate playMusic:@"music1.wav"];
    [kAppDelegate playMusic:@"music3.wav"];
}


- (void)viewWillDisappear:(BOOL)animated{
    //[kAppDelegate stopMusic];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) actionBack:(id)sender {
    
    [kAppDelegate playSound:@"click1.wav"];
    
    [self fade:YES animated:YES];
    
    float secs = kFadeDuration;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secs * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIViewController *controller = [kAppDelegate.storyboard instantiateViewControllerWithIdentifier:@"home"];
        [self.view.window setRootViewController:controller];
    });
}

- (IBAction)actionSliderRelease:(UISlider *)sender {
    [kAppDelegate playSound:@"coin1.wav"];
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    
    if(sender == self.soundVolumeSlider)
    {
        [kAppDelegate setSoundVolume:sender.value];
        
        [kHelpers sendGoogleAnalyticsEventWithCategory:@"settings" andAction:@"tap" andLabel:@"sliderVolumeSound"];


    }
    else if(sender == self.musicVolumeSlider)
    {
        [kHelpers sendGoogleAnalyticsEventWithCategory:@"settings" andAction:@"tap" andLabel:@"sliderVolumeMusic"];

        [kAppDelegate setMusicVolume:sender.value];
    }
    
}


@end
