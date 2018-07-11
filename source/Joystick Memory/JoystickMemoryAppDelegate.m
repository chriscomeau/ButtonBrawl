//
//  JoystickMemoryAppDelegate.m
//  Joystick Memory
//
//  Created by Chris Comeau on 2014-08-02.
//  Copyright (c) 2014 Skyriser Media. All rights reserved.
//

#import "JoystickMemoryAppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "GameCenterManager.h"

@interface JoystickMemoryAppDelegate ()
@property (strong, nonatomic) NSString* currentMusic;
@end

@implementation JoystickMemoryAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //init
    _soundVolume = 1.0f;
    _musicVolume = 1.0f;
    _credits = 0;
    self.currentMusic = @"";
    
    [Fabric with:@[[Crashlytics class]]];
    
    //google analytics
    [GAI sharedInstance].trackUncaughtExceptions = NO;
    [GAI sharedInstance].dispatchInterval = 20;
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelWarning];
    [[GAI sharedInstance] trackerWithTrackingId:kGoogleAnalyticsTrackingID];
    

    //alert style
    [[SIAlertView appearance] setTitleFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:22]];
    [[SIAlertView appearance] setMessageFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:16]];
    [[SIAlertView appearance] setButtonColor:RGB(255, 129, 0)];

    
    //load state
    [self loadState];
    
    //audio
    [SoundManager sharedManager].allowsBackgroundMusic = YES;
    [[SoundManager sharedManager] prepareToPlay];
    
    [self setSoundVolume:self.soundVolume];
    [self setMusicVolume:self.musicVolume];

    //status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];

    [kHelpers listFonts];
    
    //gamecenter
    [[GameCenterManager sharedManager] setupManager]; // Or use setupManagerAndSetShouldCryptWithKey: for use with encryption
    //[[GameCenterManager sharedManager] setDelegate:self];

    return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    SKView *view = (SKView *)self.window.rootViewController.view;
    if(view && [view isKindOfClass:[SKView class]])
        view.paused = NO;

    // resume audio
    //[[AVAudioSession sharedInstance] setActive:YES error:nil];

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // prevent audio crash
    //[[AVAudioSession sharedInstance] setActive:NO error:nil];
    
    SKView *view = (SKView *)self.window.rootViewController.view;
    if(view && [view isKindOfClass:[SKView class]])
        view.paused = YES;

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // prevent audio crash
    //[[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    SKView *view = (SKView *)self.window.rootViewController.view;
    if(view && [view isKindOfClass:[SKView class]])
        view.paused = NO;

    // resume audio
    //[[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (UIStoryboard *)storyboard {
    UIStoryboard *tempStoryboard = nil;
    
    tempStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
   
     //if([kHelpers isIpad])
    //tempStoryboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:[NSBundle mainBundle]];
    //else
    //    tempStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];

    return tempStoryboard;
}


#pragma mark - Sound
- (void)playSound:(NSString*)name
{
    //https://github.com/nicklockwood/SoundManager
    [[SoundManager sharedManager] playSound:name looping:NO];
}

- (void)playMusic:(NSString*)name
{
    if(!kMusicEnabled)
        return;
    
    if([name isEqualToString:self.currentMusic])
    {
        //already playing
        return;
    }

    self.currentMusic = name;
    
    [[SoundManager sharedManager] playMusic:name looping:YES];
}

- (void)stopMusic
{

    self.currentMusic = @"";

    if(!kMusicEnabled)
        return;
    
    [[SoundManager sharedManager] stopMusic:NO];
}

- (void)setSoundVolume:(double)volume
{
    _soundVolume = volume;
    [[SoundManager sharedManager] setSoundVolume:volume];
    
    [self saveState];
}

- (void)setMusicVolume:(double)volume
{
    _musicVolume = volume;

    
    [[SoundManager sharedManager] setMusicVolume:volume * kMusicVolumeMultiplier];
    
    [self saveState];
}

- (void)setCredits:(int)value
{
    _credits = value;
    
    if(_credits < 0)
        _credits = 0;

    if(_credits >99)
        _credits = 99;

    [self saveState];
}

- (void)loadState {

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
    //set defaults
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 
                                [NSNumber numberWithFloat:1.0f], @"soundVolume",
                                 [NSNumber numberWithFloat:0.3f], @"musicVolume",
                                 [NSNumber numberWithInt:kDefaultCoins], @"credits",
                                nil];
                                 
    [prefs registerDefaults:appDefaults];

    _soundVolume = [[prefs objectForKey:@"soundVolume"] floatValue];
    _musicVolume = [[prefs objectForKey:@"musicVolume"] floatValue];
    _credits = [[prefs objectForKey:@"credits"] intValue];
    
    //force
    //_credits = 1;

}

- (void)saveState {

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    [prefs setObject:[NSNumber numberWithFloat:self.soundVolume] forKey:@"soundVolume"];
    [prefs setObject:[NSNumber numberWithFloat:self.musicVolume] forKey:@"musicVolume"];
    [prefs setObject:[NSNumber numberWithInt:self.credits] forKey:@"credits"];
    
    //save
    [prefs synchronize];

}

@end
