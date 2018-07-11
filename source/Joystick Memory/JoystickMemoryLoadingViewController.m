//
//  JoystickMemoryLoadingViewController.m
//  Joystick Memory
//
//  Created by Chris Comeau on 2014-08-04.
//  Copyright (c) 2014 Skyriser Media. All rights reserved.
//

#import "JoystickMemoryLoadingViewController.h"

@interface JoystickMemoryLoadingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) UIImageView *fadeView;

@end

@implementation JoystickMemoryLoadingViewController

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

    self.titleLabel.font = [UIFont fontWithName:@"FeastofFleshBB" size:38];

    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    float secs = kLoadingFakeTime;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secs * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        [self fade:YES animated:YES];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kFadeDuration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            UIViewController *controller = [kAppDelegate.storyboard instantiateViewControllerWithIdentifier:@"home"];
            [self.view.window setRootViewController:controller];
         });

    });
    
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
    //[self fade:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)prefersStatusBarHidden {
  return NO;
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

@end
