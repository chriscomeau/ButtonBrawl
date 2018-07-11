//
//  JoystickMemoryHomeViewController.m
//  Joystick Memory
//
//  Created by Chris Comeau on 2014-08-04.
//  Copyright (c) 2014 Skyriser Media. All rights reserved.
//

#import "JoystickMemoryHomeViewController.h"

@interface JoystickMemoryHomeViewController ()

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIImageView *playGlow;
@property (weak, nonatomic) IBOutlet UIButton *mockupButton;
@property (weak, nonatomic) IBOutlet UIButton *storeButton;
@property (weak, nonatomic) IBOutlet UIImageView *storeGlow;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *leaderboardButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (weak, nonatomic) IBOutlet UILabel *creditsLabel;
@property (weak, nonatomic) IBOutlet UILabel *creditsLabel2;
@property (weak, nonatomic) IBOutlet UIImageView *creditsBack;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (strong, nonatomic) UIImageView *fadeView;

- (IBAction)actionPlay:(id)sender;
- (IBAction)actionMockup:(id)sender;
- (IBAction)actionStore:(id)sender;
- (IBAction)actionSettings:(id)sender;
- (IBAction)actionLeaderboard:(id)sender;

@end

@implementation JoystickMemoryHomeViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)appplicationIsActive:(NSNotification *)notification {
    NSLog(@"Application Did Become Active");
    
}

- (void)applicationEnteredForeground:(NSNotification *)notification {
    NSLog(@"Application Entered Foreground");
    
    [self setupGlows];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //foreground
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appplicationIsActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnteredForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    

    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    self.creditsLabel.text = [NSString stringWithFormat:@"%d", kAppDelegate.credits];
    
    self.versionLabel.text = [kHelpers getVersionString];
    //self.versionLabel.font = [UIFont fontWithName:@"FeastofFleshBB" size:16]; //cartoony
    self.versionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:11];
    self.versionLabel.textColor = [UIColor whiteColor];
    self.versionLabel.alpha = 0.2f;

    self.creditsLabel2.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:14];
    self.creditsLabel2.textColor = [UIColor whiteColor];
    self.creditsLabel2.alpha = 0.5f;
    self.creditsLabel2.text = @"Tokens:";
    
    //self.creditsLabel.font = [UIFont fontWithName:@"Disorient-Pixels" size:30];
    self.creditsLabel.font = [UIFont fontWithName:@"Open24DisplaySt" size:36];
    self.creditsLabel.textColor = RGB(204,33,42);
    //glow
    self.creditsLabel.layer.shadowColor = self.creditsLabel.textColor.CGColor;
    self.creditsLabel.layer.shadowRadius = 4.0f;
    self.creditsLabel.layer.shadowOpacity = .9;
    self.creditsLabel.layer.shadowOffset = CGSizeZero;
    self.creditsLabel.layer.masksToBounds = NO;

    //self.creditsBack.frame = self.creditsLabel.frame;
    self.creditsBack.backgroundColor = RGB(46,17,21);
    
    //self.titleLabel.font = [UIFont fontWithName:@"Arcade" size:40];
    //self.titleLabel.font = [UIFont fontWithName:@"CrimesTimesSix" size:40];
    //self.titleLabel.font = [UIFont fontWithName:@"FeastofFleshBBItalic" size:40]; //cartoony
    //self.titleLabel.font = [UIFont fontWithName:@"MonstersAttack" size:40]; //bloody
    self.titleLabel.font = [UIFont fontWithName:@"FeastofFleshBB" size:40]; //cartoony
    self.titleLabel.text = @"Combos";
    self.titleLabel.textColor = RGB(255,228,0);
    self.titleLabel.hidden = YES;
    self.titleImageView.hidden = NO;
    
    self.playButton.titleLabel.font = [UIFont fontWithName:@"FeastofFleshBB" size:18];
    self.settingsButton.titleLabel.font = [UIFont fontWithName:@"FeastofFleshBB" size:16];
    self.leaderboardButton.titleLabel.font = [UIFont fontWithName:@"FeastofFleshBB" size:16];
    self.storeButton.titleLabel.font = [UIFont fontWithName:@"FeastofFleshBB" size:16];
    self.mockupButton.titleLabel.font = [UIFont fontWithName:@"FeastofFleshBB" size:9];
    
    self.playButton.titleEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0);
    self.mockupButton.titleEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0);
    self.storeButton.titleEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0);
    self.settingsButton.titleEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0);
    self.leaderboardButton.titleEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0);
    
    self.playButton.titleLabel.alpha = 0.6f;
    self.mockupButton.titleLabel.alpha = 0.6f;
    self.storeButton.titleLabel.alpha = 0.6f;
    self.settingsButton.titleLabel.alpha = 0.6f;
    self.leaderboardButton.titleLabel.alpha = 0.6f;

    self.mockupButton.hidden = YES;

    //1 player
    [self.playButton setTitle:@"" forState:UIControlStateNormal];

    UIImage *mergedImage = [UIImage mergeImage:[UIImage imageNamed:@"button_white_up"] withImage:[UIImage imageNamed:@"1player"]];
    [self.playButton setImage:mergedImage forState:UIControlStateNormal];

    mergedImage = [UIImage mergeImage:[UIImage imageNamed:@"button_white_down"] withImage:[UIImage imageNamed:@"1player"]];
    [self.playButton setImage:mergedImage forState:(UIControlStateSelected) ];
    [self.playButton setImage:mergedImage forState:(UIControlStateHighlighted) ];
    [self.playButton setImage:mergedImage forState:(UIControlStateSelected | UIControlStateHighlighted) ];
    self.playButton.adjustsImageWhenHighlighted = NO;

    
    //normal, with text
    //[self.playButton setTitle:@"Play" forState:UIControlStateNormal];
    //[self.playButton setBackgroundImage:[UIImage imageNamed:@"button_white_up"] forState:UIControlStateNormal];
    //[self.playButton setBackgroundImage:[UIImage imageNamed:@"button_white_down"] forState:(UIControlStateSelected|UIControlStateHighlighted) ];
    
    self.mockupButton.adjustsImageWhenHighlighted = NO;
    [self.mockupButton setBackgroundImage:[UIImage imageNamed:@"button_white_up"] forState:UIControlStateNormal];
    [self.mockupButton setBackgroundImage:[UIImage imageNamed:@"button_white_down"] forState:(UIControlStateHighlighted)];
    [self.mockupButton setBackgroundImage:[UIImage imageNamed:@"button_white_down"] forState:(UIControlStateSelected)];
    [self.mockupButton setBackgroundImage:[UIImage imageNamed:@"button_white_down"] forState:(UIControlStateSelected | UIControlStateHighlighted)];
    
    self.storeButton.adjustsImageWhenHighlighted = NO;
    [self.storeButton setBackgroundImage:[UIImage imageNamed:@"button_white_up"] forState:UIControlStateNormal];
    [self.storeButton setBackgroundImage:[UIImage imageNamed:@"button_white_down"] forState:(UIControlStateHighlighted)];
    [self.storeButton setBackgroundImage:[UIImage imageNamed:@"button_white_down"] forState:(UIControlStateSelected)];
    [self.storeButton setBackgroundImage:[UIImage imageNamed:@"button_white_down"] forState:(UIControlStateSelected | UIControlStateHighlighted)];
    
    self.settingsButton.adjustsImageWhenHighlighted = NO;
    [self.settingsButton setBackgroundImage:[UIImage imageNamed:@"button_white_up"] forState:UIControlStateNormal];
    [self.settingsButton setBackgroundImage:[UIImage imageNamed:@"button_white_down"] forState:(UIControlStateHighlighted)];
    [self.settingsButton setBackgroundImage:[UIImage imageNamed:@"button_white_down"] forState:(UIControlStateSelected)];
    [self.settingsButton setBackgroundImage:[UIImage imageNamed:@"button_white_down"] forState:(UIControlStateSelected | UIControlStateHighlighted)];
    
    self.leaderboardButton.adjustsImageWhenHighlighted = NO;
    [self.leaderboardButton setBackgroundImage:[UIImage imageNamed:@"button_white_up"] forState:UIControlStateNormal];
    [self.leaderboardButton setBackgroundImage:[UIImage imageNamed:@"button_white_down"] forState:(UIControlStateHighlighted)];
    [self.leaderboardButton setBackgroundImage:[UIImage imageNamed:@"button_white_down"] forState:(UIControlStateSelected)];
    [self.leaderboardButton setBackgroundImage:[UIImage imageNamed:@"button_white_down"] forState:(UIControlStateSelected | UIControlStateHighlighted)];
    
    //glow
    [self setupGlows];
    
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
    
    [self setupGlows];
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


- (BOOL)prefersStatusBarHidden {
  return NO;
}


#pragma mark - Actions

- (void) actionPlay:(id)sender {
    //sound
    [kAppDelegate playSound:@"click1.wav"];
    
    //out of coins
    if(kAppDelegate.credits == 0) {
        //[kHelpers showErrorHud:@"Not enough tokens."];
        
        
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Token" andMessage:@"Not enough tokens. Go to store?"];
        
        [alertView addButtonWithTitle:@"Cancel"
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView *alert) {
                                  [kAppDelegate playSound:@"click1.wav"];

                              }];
        
        [alertView addButtonWithTitle:@"Store"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                                  [kAppDelegate playSound:@"click1.wav"];

                                  
                                  float secs = 0.5f;
                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secs * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                      [self fade:YES animated:YES];
                                      
                                      float secs = kFadeDuration;
                                      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secs * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                          UIViewController *controller = [kAppDelegate.storyboard instantiateViewControllerWithIdentifier:@"store"];
                                          [self.view.window setRootViewController:controller];
                                      });
                                  });

                              }];

        
        alertView.transitionStyle = kAlertStyle;
        
        [alertView show];
        [kAppDelegate playSound:@"gasp1.wav"];
        
        return;
    }
    
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Token" andMessage:@"Are you sure you want to use a token to play?"];
    
    [alertView addButtonWithTitle:@"Cancel"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alert) {
                              [kAppDelegate playSound:@"click1.wav"];

                          }];
    [alertView addButtonWithTitle:@"Play"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              [kAppDelegate playSound:@"click1.wav"];

                              [kAppDelegate playSound:@"coin1.wav"];
                              
                              kAppDelegate.credits--;
                              
                              //credits
                              self.creditsLabel.text = [NSString stringWithFormat:@"%d", kAppDelegate.credits];
                              

                              float secs = 0.5f;
                              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secs * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                  //fade
                                  [self fade:YES animated:YES];
                                  
                                  float secs = kFadeDuration;
                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secs * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                      UIViewController *controller = [kAppDelegate.storyboard instantiateViewControllerWithIdentifier:@"game"];
                                      [self.view.window setRootViewController:controller];
                                  });
                              });
                          }];

    alertView.willShowHandler = ^(SIAlertView *alertView) {
        //NSLog(@"%@, willShowHandler", alertView);
    };
    alertView.didShowHandler = ^(SIAlertView *alertView) {
        //NSLog(@"%@, didShowHandler", alertView);
    };
    alertView.willDismissHandler = ^(SIAlertView *alertView) {
        //NSLog(@"%@, willDismissHandler", alertView);
    };
    alertView.didDismissHandler = ^(SIAlertView *alertView) {
        //NSLog(@"%@, didDismissHandler", alertView);
    };
    
    alertView.transitionStyle = kAlertStyle;
    
    [alertView show];

    
    
    //alert
    /*NSString *message = [NSString stringWithFormat:@"Are you sure you want to use a token to play?" ];
    
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Cancel" action:^{
    }];
    
    RIButtonItem *okItem = [RIButtonItem itemWithLabel:@"Play" action:^{
        //play
        
        [kAppDelegate playSound:@"coin1.wav"];
        
        kAppDelegate.credits--;
        
        //credits
        self.creditsLabel.text = [NSString stringWithFormat:@"%d", kAppDelegate.credits];
        
        
        float secs = 0.3f;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secs * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            UIViewController *controller = [kAppDelegate.storyboard instantiateViewControllerWithIdentifier:@"game"];
            [self.view.window setRootViewController:controller];
        });
    }];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Token"
                                                    message:message
                                           cancelButtonItem:cancelItem
                                           otherButtonItems:okItem, nil];
    [alert show];*/
}

- (void) actionMockup:(id)sender {
    [kAppDelegate playSound:@"click1.wav"];
    
    [self fade:YES animated:YES];
    
    float secs = kFadeDuration;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secs * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIViewController *controller = [kAppDelegate.storyboard instantiateViewControllerWithIdentifier:@"mockup"];
        [self.view.window setRootViewController:controller];
    });

}

- (IBAction)actionStore:(id)sender {
    
    [kAppDelegate playSound:@"click1.wav"];
    
    [self fade:YES animated:YES];
    
    float secs = kFadeDuration;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secs * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIViewController *controller = [kAppDelegate.storyboard instantiateViewControllerWithIdentifier:@"store"];
        [self.view.window setRootViewController:controller];
    });
    
}

- (void) actionSettings:(id)sender {
    [kAppDelegate playSound:@"click1.wav"];
    
    [self fade:YES animated:YES];
    
    float secs = kFadeDuration;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secs * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIViewController *controller = [kAppDelegate.storyboard instantiateViewControllerWithIdentifier:@"settings"];
        [self.view.window setRootViewController:controller];
    });
    
}

- (void) actionLeaderboard:(id)sender {
    
    [kHelpers sendGoogleAnalyticsEventWithCategory:@"home" andAction:@"tap" andLabel:@"leaderboard"];

    [kAppDelegate playSound:@"click1.wav"];

    [self showLeaderboard];
}

- (void) setupGlows {

    self.playGlow.userInteractionEnabled = NO;
    self.storeGlow.userInteractionEnabled = NO;
    self.playGlow.alpha = 0.0f;
    self.storeGlow.alpha = 0.0f;
    
    CABasicAnimation *theAnimation;
    theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    theAnimation.duration=0.5f;
    theAnimation.repeatCount=HUGE_VALF;
    theAnimation.autoreverses=YES;
    theAnimation.fromValue=[NSNumber numberWithFloat:0.9f];
    theAnimation.toValue=[NSNumber numberWithFloat:0.0f];
    
    [self.playGlow.layer removeAllAnimations];
    [self.storeGlow.layer removeAllAnimations];

    if(kAppDelegate.credits > 0)
        [self.playGlow.layer addAnimation:theAnimation forKey:@"animateOpacity"];
    else
        [self.storeGlow.layer addAnimation:theAnimation forKey:@"animateOpacity"];
}

- (void)showLeaderboard {
    [[GameCenterManager sharedManager] presentLeaderboardsOnViewController:self];
}

@end
