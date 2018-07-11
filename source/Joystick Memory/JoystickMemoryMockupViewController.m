//
//  JoystickMemoryMockupViewController.m
//  Joystick Memory
//
//  Created by Chris Comeau on 2014-08-04.
//  Copyright (c) 2014 Skyriser Media. All rights reserved.
//

#import "JoystickMemoryMockupViewController.h"

@interface JoystickMemoryMockupViewController ()
- (IBAction)actionHome:(id)sender;

@end

@implementation JoystickMemoryMockupViewController

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
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
  return NO;
}


- (void)viewDidAppear:(BOOL)animated{
    [kAppDelegate playMusic:@"music3.wav"];
}


- (void)viewWillDisappear:(BOOL)animated{
    //[kAppDelegate stopMusic];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    //google analytics
    [kHelpers setupGoogleAnalyticsForView:[[self class] description]];
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


#pragma mark - Actions

- (void) actionHome:(id)sender {
    
    [kAppDelegate playSound:@"click1.wav"];
    
    UIViewController *controller = [kAppDelegate.storyboard instantiateViewControllerWithIdentifier:@"home"];
    [self.view.window setRootViewController:controller];

}


@end
