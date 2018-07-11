//
//  JoystickMemoryViewController.m
//  Joystick Memory
//
//  Created by Chris Comeau on 2014-08-02.
//  Copyright (c) 2014 Skyriser Media. All rights reserved.
//

#import "JoystickMemoryViewController.h"
#import "JoystickMemoryMyScene.h"

@interface JoystickMemoryViewController ()
@property (strong, nonatomic) SKScene * scene;
@end


@implementation JoystickMemoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];


    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    
    // Create and configure the scene.
    self.scene = [JoystickMemoryMyScene sceneWithSize:skView.bounds.size];
    self.scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:self.scene];

    //gamecenter
    [[GameCenterManager sharedManager] setDelegate:self];
}

- (void)gameCenterManager:(GameCenterManager *)manager authenticateUser:(UIViewController *)gameCenterLoginController
{
    [self presentViewController:gameCenterLoginController animated:YES completion:^{
        NSLog(@"Finished Presenting Authentication Controller");
    }];
    
}

- (void)viewWillAppear:(BOOL)animated{
    //google analytics
    [kHelpers setupGoogleAnalyticsForView:[[self class] description]];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    [kAppDelegate playMusic:@"music1.wav"];

    //gamecenter
    
    /*[[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(showAuthenticationViewController)
     name:PresentAuthenticationViewController
     object:nil]; */
    
    //[[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
}

/*- (void)showAuthenticationViewController
{
    GameKitHelper *gameKitHelper =
    [GameKitHelper sharedGameKitHelper];
    
    [self presentViewController:
     gameKitHelper.authenticationViewController
                       animated:YES
                     completion:nil];
}*/



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewWillDisappear:(BOOL)animated{
    //[kAppDelegate stopMusic];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)viewDidDisappear:(BOOL)animated{
    //cleanup, fix fade
    [self.scene removeAllChildren];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
  return YES;
}

@end
