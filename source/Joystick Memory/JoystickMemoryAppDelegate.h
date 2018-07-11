//
//  JoystickMemoryAppDelegate.h
//  Joystick Memory
//
//  Created by Chris Comeau on 2014-08-02.
//  Copyright (c) 2014 Skyriser Media. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JoystickMemoryAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) double soundVolume;
@property (nonatomic) double musicVolume;
@property (nonatomic) int credits;

- (UIStoryboard *)storyboard;
- (void)playSound:(NSString*)name;
- (void)playMusic:(NSString*)name;
- (void)stopMusic;

- (void)setSoundVolume:(double)volume;
- (void)setMusicVolume:(double)volume;
- (void)setCredits:(int)value;

@end
