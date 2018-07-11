//
//  JoystickMemoryStoreViewController.m
//  Joystick Memory
//
//  Created by Chris Comeau on 2014-08-07.
//  Copyright (c) 2014 Skyriser Media. All rights reserved.
//

#import "JoystickMemoryStoreViewController.h"

@interface JoystickMemoryStoreViewController ()

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UILabel *buyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *storeGlow;

@property (strong, nonatomic) UIImageView *fadeView;


- (IBAction)actionBack:(id)sender;
- (IBAction)actionBuy:(id)sender;

@end

@implementation JoystickMemoryStoreViewController


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
    

    //back
    self.backButton.titleLabel.font = [UIFont fontWithName:@"FeastofFleshBB" size:18];
    self.backButton.titleEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0);
    self.backButton.titleLabel.alpha = 0.6f;
    self.backButton.adjustsImageWhenHighlighted = NO;
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"button_white_up"] forState:UIControlStateNormal];
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"button_white_down"] forState:(UIControlStateHighlighted)];
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"button_white_down"] forState:(UIControlStateSelected)];
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"button_white_down"] forState:(UIControlStateSelected | UIControlStateHighlighted)];
    
    
    //buy label
    //labels
    self.buyLabel.font = [UIFont fontWithName:@"FeastofFleshBB" size:22];
    self.buyLabel.text = [NSString stringWithFormat:@"Buy %d Tokens", kIAPNumCoins];
    
    //buy
    //self.buyButton.titleLabel.font = [UIFont fontWithName:@"FeastofFleshBB" size:18];
    self.buyButton.titleLabel.font = [UIFont fontWithName:@"FeastofFleshBB" size:40];
    self.buyButton.titleEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0);
    self.buyButton.titleLabel.alpha = 0.6f;
    self.buyButton.adjustsImageWhenHighlighted = NO;
    [self.buyButton setBackgroundImage:[UIImage imageNamed:@"button_white_up"] forState:UIControlStateNormal];
    [self.buyButton setBackgroundImage:[UIImage imageNamed:@"button_white_down"] forState:(UIControlStateHighlighted)];
    [self.buyButton setBackgroundImage:[UIImage imageNamed:@"button_white_down"] forState:(UIControlStateSelected)];
    [self.buyButton setBackgroundImage:[UIImage imageNamed:@"button_white_down"] forState:(UIControlStateSelected | UIControlStateHighlighted)];
    //multiline
    self.buyButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.buyButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    //[self.buyButton setTitle: @"Buy\ncoins" forState: UIControlStateNormal];
    [self.buyButton setTitle: @"$" forState: UIControlStateNormal];
    
    //fade
    self.fadeView = [[UIImageView alloc] init];
    self.fadeView.contentMode = UIViewContentModeScaleAspectFill;
    self.fadeView.frame = self.view.bounds;
    self.fadeView.image = [kHelpers imageWithColor:kFadeColor andSize:self.fadeView.frame.size];
    self.fadeView.userInteractionEnabled = NO;
    self.fadeView.alpha = 0.0f;
    [self.view addSubview:self.fadeView];
    [self.view bringSubviewToFront:self.fadeView];

    //glow
    [self setupGlows];

}

- (void) setupGlows {
    
    self.storeGlow.userInteractionEnabled = NO;
    self.storeGlow.alpha = 0.0f;
    
    CABasicAnimation *theAnimation;
    theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    theAnimation.duration=0.5f;
    theAnimation.repeatCount=HUGE_VALF;
    theAnimation.autoreverses=YES;
    theAnimation.fromValue=[NSNumber numberWithFloat:0.9f];
    theAnimation.toValue=[NSNumber numberWithFloat:0.0f];
    
    [self.storeGlow.layer removeAllAnimations];
    
    //any credits?
    if(kAppDelegate.credits <= 0)
        [self.storeGlow.layer addAnimation:theAnimation forKey:@"animateOpacity"];
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

- (void) actionBuy:(id)sender {
    
    [kHelpers sendGoogleAnalyticsEventWithCategory:@"store" andAction:@"tap" andLabel:@"buy"];

    [kAppDelegate playSound:@"click1.wav"];

    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Token" andMessage:[NSString stringWithFormat:@"Buy %d Tokens for $0.99?", kIAPNumCoins]];
    
    [alertView addButtonWithTitle:@"Cancel"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alert) {
                              [kAppDelegate playSound:@"click1.wav"];

                          }];
    [alertView addButtonWithTitle:@"Buy"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              [kAppDelegate playSound:@"click1.wav"];

                              
                              [kHelpers showMessageHud:@"Connecting..."];
                              
                              //after delay
                              float secs = 1.5f;
                              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secs * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                  //[kHelpers dismissHud];
                                  
                                  
                                  [kAppDelegate playSound:@"coin3.wav"];
                                  
                                  [kHelpers showSuccessHud:@"Success!"];
                                  
                                  //credsits test
                                  kAppDelegate.credits += kIAPNumCoins;
                                  
                                  //glow
                                  [self setupGlows];
                                  
                              });

                              
                          }];
    
    
    alertView.transitionStyle = kAlertStyle;
    
    [alertView show];

    
    
}
@end
