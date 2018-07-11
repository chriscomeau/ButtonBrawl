//
//  JoystickMemoryMyScene.m
//  Joystick Memory
//
//  Created by Chris Comeau on 2014-08-02.
//  Copyright (c) 2014 Skyriser Media. All rights reserved.
//

#import "JoystickMemoryMyScene.h"

typedef NS_ENUM(NSUInteger, JoystickDirection)
{
    JoystickDirectionNone = 0,
    
    JoystickDirectionUp,
    JoystickDirectionDown,
    JoystickDirectionLeft,
    JoystickDirectionRight,
    
    JoystickDirectionUpRight,
    JoystickDirectionDownRight,
    JoystickDirectionUpLeft,
    JoystickDirectionDownLeft,

};

typedef NS_ENUM(NSUInteger, ButtonType)
{
    ButtonType1 = JoystickDirectionDownLeft + 1,
    ButtonType2,
    ButtonType3,
    ButtonType4,
    ButtonType5,
    ButtonType6,
};

@interface JoystickMemoryMyScene ()
@property (nonatomic, strong) NSMutableArray *buttonArray;
@property (nonatomic, strong) NSMutableArray *glowArray;
@property (nonatomic, strong) NSMutableArray *patternArray;
@property (nonatomic, strong) NSMutableArray *possibleMovesArray;
@property (nonatomic, strong) SKLabelNode *comboLabel;
@property (nonatomic, strong) SKLabelNode *comboLabelShadow;

@property (nonatomic, strong) SKSpriteNode *creditsBack;
@property (nonatomic, strong) SKLabelNode *creditsLabel;
@property (nonatomic, strong) SKLabelNode *creditsLabel2;
@property (nonatomic, strong) SKLabelNode *timerLabel;
@property (nonatomic, strong) SKLabelNode *timerLabelShadow;

@property (nonatomic, strong) SIAlertView *alertView;

@property (nonatomic) int clickCount;
@property (nonatomic) int lastComboCount;
@property (nonatomic) int streakCount;
@property (nonatomic) int patternCount;
@property (nonatomic) int numButtons;
@property (nonatomic) int currentPatternIndex;
@property (nonatomic) int timerCount;

@property (strong, nonatomic) NSTimer *timer;

@property (nonatomic) BOOL firstTime;
@property (nonatomic) BOOL showingPattern;
@property (nonatomic) BOOL gamePaused;

@property (nonatomic) BOOL joystickEdgeDetected;
@property (nonatomic) float joystickEdgeDetectedAngle;
@property (nonatomic) JoystickDirection joystickDirection;
@property (nonatomic, weak) SKNode *draggedNode;
@property (nonatomic, strong) SKSpriteNode *joystickButton;
@property (nonatomic, strong) SKSpriteNode *joystickBack;

@property (nonatomic, strong) SKSpriteNode *overlayWrong;
@property (nonatomic, strong) SKSpriteNode *overlayStart;
@property (nonatomic, strong) SKSpriteNode *overlayTimesout;

@property (strong, nonatomic) SKSpriteNode *fadeView;
@property (strong, nonatomic) SKSpriteNode *pauseView;

@end

@implementation JoystickMemoryMyScene


- (void)appplicationIsActive:(NSNotification *)notification {
    //NSLog(@"Application Did Become Active");
}



- (void)applicationEnteredForeground:(NSNotification *)notification {
    NSLog(@"Application Entered Foreground");
    
    //already
    //if(self.gamePaused && pause)
    //    return;

    [self pause:YES];
    
    @weakify(self)
    
    if(self.alertView)
        [self.alertView dismissAnimated:NO];

    self.alertView = [[SIAlertView alloc] initWithTitle:@"Paused" andMessage:@"Game paused."];
    [self.alertView addButtonWithTitle:@"Resume"
                                  type:SIAlertViewButtonTypeDefault
                               handler:^(SIAlertView *alert) {
                                   [kAppDelegate playSound:@"click1.wav"];

                                   @strongify(self)
                                   [self pause:NO];

                                   
                               }];
    self.alertView.transitionStyle = kAlertStyle;
    
    self.alertView.didDismissHandler = ^(SIAlertView *alertView) {
        //NSLog(@"%@, didDismissHandler", alertView);
    };
    
    [self.alertView show];

}

- (void)applicationEnteredBackground:(NSNotification *)notification {
    NSLog(@"Application Entered Background");
    
    [self pause:YES];
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        @weakify(self)
        
        //foreground
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appplicationIsActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationEnteredForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationEnteredBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        

        int shadowOffset = 3;
        UIColor *shadowColor = RGB(0,0,0);
        
        //self.userInteractionEnabled = NO;
        
        self.firstTime = YES;
        self.showingPattern = NO;
        self.gamePaused = NO;
        self.timerCount = kTimerStart;
        
        self.joystickDirection = JoystickDirectionNone;
        self.clickCount = 0;
        self.lastComboCount = 0;
        self.streakCount = 0;
        self.patternCount = kPatternCountStart;
        self.numButtons = 6;
        self.buttonArray = [NSMutableArray array];
        self.glowArray = [NSMutableArray array];
        self.possibleMovesArray = [NSMutableArray array];
        
        self.backgroundColor = [SKColor blackColor];
        
        //bg
        //SKSpriteNode *bgImage = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
        SKSpriteNode *bgImage = [SKSpriteNode spriteNodeWithImageNamed:@"background_game"];
        bgImage.position = CGPointMake(self.size.width/2, self.size.height/2);
        bgImage.name = @"background";
        bgImage.zPosition = 1;
        //bgImage.userInteractionEnabled = NO;
        [self addChild:bgImage];

        //buttons
        double scale = 0.84f;
        double scale2 = 0.6f;
        double size = 0;
        int yOffset = 20;
        
        //overlay wrong
        self.overlayWrong = [SKSpriteNode spriteNodeWithImageNamed:@"overlayWrong"];
        [self.overlayWrong setScale:1.0f];
        self.overlayWrong.name = [NSString stringWithFormat:@"overlayWrong"];
        self.overlayWrong.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        self.overlayWrong.zPosition = 300;
        self.overlayWrong.alpha = 0;
        self.overlayWrong.hidden = YES;
        //self.overlayWrong.userInteractionEnabled = NO;
        //[self addChild:self.overlayWrong];
         
        
        //overlay start
        self.overlayStart = [SKSpriteNode spriteNodeWithImageNamed:@"overlayStart"];
        [self.overlayStart setScale:1.0f];
        self.overlayStart.name = [NSString stringWithFormat:@"overlayStart"];
        self.overlayStart.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        self.overlayStart.zPosition = 300;
        self.overlayStart.alpha = 0;
        self.overlayStart.hidden = YES;
        //self.overlayStart.userInteractionEnabled = NO;
        //[self addChild:self.overlayStart];
        
        //overlay timesout
        self.overlayTimesout = [SKSpriteNode spriteNodeWithImageNamed:@"overlayTimesout"];
        [self.overlayTimesout setScale:1.0f];
        self.overlayTimesout.name = [NSString stringWithFormat:@"overlayTimesout"];
        self.overlayTimesout.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        self.overlayTimesout.zPosition = 300;
        self.overlayTimesout.alpha = 0;
        self.overlayTimesout.hidden = YES;

        
        //joystick back
        self.joystickBack = [SKSpriteNode spriteNodeWithImageNamed:@"joystick_back"];
        [self.joystickBack setScale:scale];
        self.joystickBack.name = [NSString stringWithFormat:@"joystick_back"];
        self.joystickBack.position = CGPointMake(self.joystickBack.size.height/2 + 10, self.frame.size.height - self.joystickBack.size.height - 120);
        self.joystickBack.zPosition = 10;
        self.joystickBack.scale = scale;
        //self.joystickBack.userInteractionEnabled = NO;
        //NSLog(@"self.joystickBack.userInteractionEnabled: %d", self.joystickBack.userInteractionEnabled);
        [self addChild:self.joystickBack];
        
        //joystick ball
        self.joystickButton = [SKSpriteNode spriteNodeWithImageNamed:@"joystick_ball"];
        [self.joystickButton setScale:scale];
        self.joystickButton.name = [NSString stringWithFormat:@"joystick_ball"];
        //same as bg
        self.joystickButton.position = CGPointMake(self.joystickBack.position.x, self.joystickBack.position.y);
        self.joystickButton.zPosition = 12;
        self.joystickButton.scale = scale;
        //self.joystickButton.userInteractionEnabled = YES;
        //NSLog(@"self.joystickButton.userInteractionEnabled: %d", self.joystickButton.userInteractionEnabled);
        [self addChild:self.joystickButton];

        //back
        STControlSprite *backButton = [STControlSprite spriteNodeWithImageNamed:@"button_white_up"];
        [backButton setScale:scale2];
        backButton.name = [NSString stringWithFormat:@"back"];
        backButton.position = CGPointMake(self.frame.size.width - backButton.size.width/2 - 10, self.frame.size.height - backButton.size.height/2 - 30 - 40);
        backButton.zPosition = 10;
        //backButton.userInteractionEnabled = YES;
        
        __weak STControlSprite *weakBackButton = backButton;
        
        [backButton setTouchDownBlock:^{
            if(self.showingPattern || self.gamePaused)
                return;
            
            [kHelpers sendGoogleAnalyticsEventWithCategory:@"game" andAction:@"tap" andLabel:@"back"];

            
            weakBackButton.texture = [SKTexture textureWithImageNamed:@"button_white_down"];

            NSString *soundName = [NSString stringWithFormat:@"click1.wav"];
            [kAppDelegate playSound:soundName];
        }];
        

        [backButton setTouchUpInsideBlock:^{
            if(self.showingPattern || self.gamePaused)
                return;

            [self pause:YES];


            weakBackButton.texture = [SKTexture textureWithImageNamed:@"button_white_up"];

            NSString *soundName = [NSString stringWithFormat:@"unclick.wav"];
            [kAppDelegate playSound:soundName];

            //back

            if(self.alertView)
                [self.alertView dismissAnimated:NO];
            
            self.alertView = [[SIAlertView alloc] initWithTitle:@"Quit" andMessage:@"Are you sure you want to quit?"];
            
            [self.alertView addButtonWithTitle:@"Cancel"
                                     type:SIAlertViewButtonTypeCancel
                                  handler:^(SIAlertView *alert) {
                                      [kAppDelegate playSound:@"click1.wav"];

                                      @strongify(self)
                                      [self pause:NO];
                                  }];
            [self.alertView addButtonWithTitle:@"Quit"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alert) {
                                      [kAppDelegate playSound:@"click1.wav"];

                                      @strongify(self)

                                      [self done];
                                      
                                      [self fade:YES animated:YES];
                                      
                                      float secs = kFadeDuration;
                                      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secs * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                          UIViewController *controller = [kAppDelegate.storyboard instantiateViewControllerWithIdentifier:@"home"];
                                          [self.view.window setRootViewController:controller];
                                      });
                                      
                                      
                                  }];
            self.alertView.transitionStyle = kAlertStyle;
            
            self.alertView.didDismissHandler = ^(SIAlertView *alertView) {
                //NSLog(@"%@, didDismissHandler", alertView);
            };

            [self.alertView show];
        }];
        
        [backButton setTouchUpOutsideBlock:^{
            if(self.showingPattern || self.gamePaused)
                return;

            weakBackButton.texture = [SKTexture textureWithImageNamed:@"button_white_up"];

            NSString *soundName = [NSString stringWithFormat:@"unclick.wav"];
            [kAppDelegate playSound:soundName];
        }];
        
        //back label
        /*SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"FeastofFleshBB"];
        label.name = [NSString stringWithFormat:@"back_label"];
        label.text = [NSString stringWithFormat:@"Pause"];
        label.fontColor = RGB(0,0,0);
        label.fontSize = 23;
        label.position = CGPointMake(0, -10);*/
        SKSpriteNode* label = [SKSpriteNode spriteNodeWithImageNamed:@"pause.png"];
        label.scale = 0.8f;
        
        label.alpha = 0.6f;
        label.zPosition = 30;
        
        [backButton addChild:label];
        
        [self addChild:backButton];

        
        //replay
        STControlSprite *replayButton = [STControlSprite spriteNodeWithImageNamed:@"button_white_up"];
        [replayButton setScale:scale2];
        replayButton.name = [NSString stringWithFormat:@"replay"];
        replayButton.position = CGPointMake(self.frame.size.width - replayButton.size.width/2 - 10, self.frame.size.height - replayButton.size.height/2 - 30 - 120);
        replayButton.zPosition = 10;
        //replayButton.userInteractionEnabled = YES;

        __weak STControlSprite *weakReplayButton = replayButton;
        
        [replayButton setTouchDownBlock:^{
            if(self.showingPattern || self.gamePaused)
                return;
            
            [kHelpers sendGoogleAnalyticsEventWithCategory:@"game" andAction:@"tap" andLabel:@"replay"];


            weakReplayButton.texture = [SKTexture textureWithImageNamed:@"button_white_down"];
            
            NSString *soundName = [NSString stringWithFormat:@"click1.wav"];
            [kAppDelegate playSound:soundName];
        }];
        
        [replayButton setTouchUpInsideBlock:^{
            if(self.showingPattern || self.gamePaused)
                return;

            [self pause:YES];


            weakReplayButton.texture = [SKTexture textureWithImageNamed:@"button_white_up"];
            
            NSString *soundName = [NSString stringWithFormat:@"unclick.wav"];
            [kAppDelegate playSound:soundName];
            
            
            //replay
            if(self.alertView)
                [self.alertView dismissAnimated:NO];

            self.alertView = [[SIAlertView alloc] initWithTitle:@"Token" andMessage:@"Are you sure you want to replay and use a token?"];
            
            [self.alertView addButtonWithTitle:@"Cancel"
                                     type:SIAlertViewButtonTypeCancel
                                  handler:^(SIAlertView *alert) {
                                      [kAppDelegate playSound:@"click1.wav"];

                                      @strongify(self)
                                      [self pause:NO];

                                  }];
            [self.alertView addButtonWithTitle:@"Replay"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alert) {
                                      [kAppDelegate playSound:@"click1.wav"];

                                      
                                      //replay
                                      //@strongify(self)
                                      
                                      //out of coins
                                      if(kAppDelegate.credits == 0) {
                                          
                                          @strongify(self)

                                          SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Token" andMessage:@"Not enough tokens. Go to store?"];
                                          
                                          [alertView addButtonWithTitle:@"Cancel"
                                                                   type:SIAlertViewButtonTypeCancel
                                                                handler:^(SIAlertView *alert) {
                                                                    [kAppDelegate playSound:@"click1.wav"];

                                                                    @strongify(self)
                                                                    [self pause:NO];
                                                                }];
                                          
                                          [alertView addButtonWithTitle:@"Store"
                                                                   type:SIAlertViewButtonTypeDefault
                                                                handler:^(SIAlertView *alert) {
                                                                    [kAppDelegate playSound:@"click1.wav"];

                                                                    
                                                                    float secs = 0.5f;
                                                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secs * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                                                        [self done];

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
                                          
                                      }
                                      else {
                                          @strongify(self)

                                          [self pause:NO];

                                          kAppDelegate.credits--;
                                          [kAppDelegate playSound:@"coin1.wav"];
                                          
                                          [kAppDelegate playSound:@"voice_again.mp3"];
                                          
                                          [self updateCreditLabel];
                                          
                                          [self showPattern];
                                      }
                                      
                                  }];
            self.alertView.transitionStyle = kAlertStyle;
            
            self.alertView.didDismissHandler = ^(SIAlertView *alertView) {
                //NSLog(@"%@, didDismissHandler", alertView);
            };

            [self.alertView show];
            
        }];
        
        [replayButton setTouchUpOutsideBlock:^{
            if(self.showingPattern || self.gamePaused)
                return;

            weakReplayButton.texture = [SKTexture textureWithImageNamed:@"button_white_up"];
            
            NSString *soundName = [NSString stringWithFormat:@"unclick.wav"];
            [kAppDelegate playSound:soundName];
        }];
        
        //replay label
        /*SKLabelNode* labelReplay = [SKLabelNode labelNodeWithFontNamed:@"FeastofFleshBB"];
        labelReplay.name = [NSString stringWithFormat:@"labelReplay"];
        labelReplay.text = [NSString stringWithFormat:@"Replay"];
        labelReplay.fontColor = RGB(0,0,0);
        labelReplay.colorBlendFactor = 1;
        labelReplay.fontSize = 23;
        labelReplay.position = CGPointMake(0, -10);
        labelReplay.alpha = 0.6f;
        labelReplay.zPosition = 30;
        [replayButton addChild:labelReplay];*/
        
        SKSpriteNode* labelReplay = [SKSpriteNode spriteNodeWithImageNamed:@"replay.png"];
        labelReplay.zPosition = 30;
        labelReplay.alpha = 0.6f;
        [replayButton addChild:labelReplay];

        [self addChild:replayButton];

        //__weak JoystickMemoryMyScene *weakSelf = self;

        //buttons
        for(int i = 0; i < self.numButtons; i++) {
            
            STControlSprite *button = [STControlSprite spriteNodeWithImageNamed:@"button_up"];
            
            //__weak STControlSprite *weakButton = button;
            @weakify(button)

            //@strongify(self)

            [button setScale:scale];
            size = button.frame.size.width;
            button.name = [NSString stringWithFormat:@"button%d", i];
            button.position = CGPointMake(size*(i%3) + size/2, yOffset + size*(1-(i/3)) + size/2);
            button.zPosition = 10;

            [button setTouchDownBlock:^{
                //[weakSelf buttonClicked:weakButton];
                @strongify(button)
                [self buttonClicked:button];
            }];
            
            [button setTouchUpInsideBlock:^{
                //[weakSelf buttonUnclicked:weakButton];
                @strongify(button)
                [self buttonUnclicked:button];
            }];
            
            [button setTouchUpOutsideBlock:^{
                //[weakSelf buttonUnclicked:weakButton];
                @strongify(button)
                [self buttonUnclicked:button];
            }];
            
            //glow
            SKSpriteNode *glow = [SKSpriteNode spriteNodeWithImageNamed:@"glow"];
            //[glow setScale:scale];
            size = glow.frame.size.width;
            //glow.name = [NSString stringWithFormat:@"glow%d", i];
            glow.name = [NSString stringWithFormat:@"glow"];
            glow.position = CGPointMake(0, 0);
            //glow.zPosition = 20;
            glow.alpha = 0.0;

            [button addChild:glow];
            //[self.glowArray addObject:glow];
            
            //number
            SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"FeastofFleshBB"];
            int number = (i+1);
            label.name = [NSString stringWithFormat:@"label"];

            //label.text = [NSString stringWithFormat:@"%d", number];
            switch(number) {
                case 1:
                    label.text = @"A"; //@"LP";
                    break;
                case 2:
                    label.text = @"B"; //@"MP";
                    break;
                case 3:
                    label.text = @"C"; //@"HP";
                    break;
                    
                case 4:
                    label.text = @"X"; //@"LK";
                    break;
                case 5:
                    label.text = @"Y"; //@"MK";
                    break;
                case 6:
                    label.text = @"Z"; //@"HK";
                    break;
                    
                default:
                    label.text = @"?";
                    break;
            }
            
            label.fontColor = RGB(0,0,0);
            //label.color = RGB(0,0,0);
            //label.colorBlendFactor = 1;
            label.fontSize = 40;
            label.position = CGPointMake(0, -15);
            label.alpha = 0.6f;
            label.zPosition = 30;
            [button addChild:label];
            //replayButton.userInteractionEnabled = YES;

            [self addChild:button];
            [self.buttonArray addObject:button];
        }
        
        //joystick glow
        SKSpriteNode *glowJoystick = [SKSpriteNode spriteNodeWithImageNamed:@"joystick_ball_glow"];
        size = glowJoystick.frame.size.width;
        glowJoystick.name = [NSString stringWithFormat:@"joystick_ball_glow"];
        glowJoystick.position = CGPointMake(0, 0);
        glowJoystick.alpha = 0.0;
        glowJoystick.userInteractionEnabled = NO;
        [self.joystickButton addChild:glowJoystick];
        
        
        //combo
        self.comboLabel = [SKLabelNode labelNodeWithFontNamed:@"FeastofFleshBB"];
        self.comboLabel.text = @"0-hit combo";
        self.comboLabel.fontColor = RGB(255,228,0);
        self.comboLabel.fontSize = 25;
        self.comboLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft; //left
        //self.comboLabel.userInteractionEnabled = NO;
        self.comboLabel.zPosition = 200;
        self.comboLabel.position = CGPointMake(20-200, self.frame.size.height - 150);
        self.comboLabel.alpha = 0; //hide
        [self addChild:self.comboLabel];
        
        //shadow
        shadowOffset = 3;
        self.comboLabelShadow = [SKLabelNode labelNodeWithFontNamed:@"FeastofFleshBB"];
        self.comboLabelShadow.text = @"0-hit combo";
        self.comboLabelShadow.fontColor = shadowColor;
        self.comboLabelShadow.fontSize = 25;
        self.comboLabelShadow.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft; //left
        self.comboLabelShadow.zPosition = self.comboLabel.zPosition-1;
        self.comboLabelShadow.position = CGPointMake(self.comboLabel.position.x + shadowOffset, self.comboLabel.position.y - shadowOffset);
        self.comboLabelShadow.alpha = 0.5f;
        [self addChild:self.comboLabelShadow];
        
        //[self updateComboLabel];
        
        
        //credits
        //self.creditsBack = [SKSpriteNode spriteNodeWithColor:RGB(46,17,21) size:CGSizeMake(80, 50)];
        self.creditsBack = [SKSpriteNode spriteNodeWithImageNamed:@"credits_back"];
        self.creditsBack.position = CGPointMake(320-45, 280);
        self.creditsBack.zPosition = 10;
        [self addChild:self.creditsBack];
        
        self.creditsLabel = [SKLabelNode labelNodeWithFontNamed:@"Open24DisplaySt"];
        self.creditsLabel.text = @"";
        self.creditsLabel.fontColor = RGB(204,33,42);
        self.creditsLabel.fontSize = 36;
        self.creditsLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        self.creditsLabel.position = CGPointMake(320-45, 265);
        self.creditsLabel.zPosition = 11;
        [self addChild:self.creditsLabel];
        [self updateCreditLabel];
        
        self.creditsLabel2 = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Thin"];
        self.creditsLabel2.text = @"Tokens:";
        self.creditsLabel2.fontColor = [UIColor whiteColor];
        self.creditsLabel2.fontSize = 14;
        self.creditsLabel2.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        self.creditsLabel2.position = CGPointMake(320-45, 265+44);
        self.creditsLabel2.zPosition = 11;
        self.creditsLabel2.alpha = 0.5f;
        [self addChild:self.creditsLabel2];
        
        self.timerLabel = [SKLabelNode labelNodeWithFontNamed:@"FeastofFleshBB"];
        self.timerLabel.fontColor = RGB(255,228,0);
        self.timerLabel.fontSize = 50;
        self.timerLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        self.timerLabel.position = CGPointMake(320/2, self.size.height-110);
        self.timerLabel.zPosition = 11;
        self.timerLabel.alpha = 1.0f;
        [self addChild:self.timerLabel];
        

        //shadow
        shadowOffset = 3;
        self.timerLabelShadow = [SKLabelNode labelNodeWithFontNamed:@"FeastofFleshBB"];
        self.timerLabelShadow.fontColor = shadowColor;
        self.timerLabelShadow.fontSize = 50;
        self.timerLabelShadow.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        self.timerLabelShadow.position = CGPointMake(self.timerLabel.position.x + shadowOffset, self.timerLabel.position.y - shadowOffset);
        self.timerLabelShadow.zPosition = self.timerLabel.zPosition-1;
        self.timerLabelShadow.alpha = 0.5f; //hide
        [self addChild:self.timerLabelShadow];
        
        
        
        [self updateTimer];
        
        //fade
        self.fadeView = [SKSpriteNode spriteNodeWithColor:kFadeColor size:self.size];
        self.fadeView.position = CGPointMake(self.size.width/2, self.size.height/2);
        self.fadeView.zPosition = 400;
        self.fadeView.alpha = 1.0f;
        
        //[self addChild:self.fadeView];
        
        //[self fade:NO animated:YES];

    }
    
    return self;
}

- (void)fade:(BOOL)fade animated:(BOOL)animated {
    
    float fadeFull = 1.0f;
    float duration = 0.0f;
    if(animated)
        duration = kFadeDuration;

    [self.fadeView removeAllActions];
    [self addChild:self.fadeView];
    
    SKAction *fade1 = nil;
    SKAction *fade2 = nil;
    SKAction *fade3 = nil;
    SKAction *fade4 = nil;
    SKAction *fadeSequence = nil;

    if(fade) {
        fade1 = [SKAction fadeAlphaTo:0.0f duration:0.0f];
        fade2 = [SKAction waitForDuration:0.0f];
        fade3 = [SKAction fadeAlphaTo:fadeFull duration:duration];
        fade4 = [SKAction runBlock:^{
        }];

    }
    else {
        fade1 = [SKAction fadeAlphaTo:fadeFull duration:0.0f];
        fade2 = [SKAction waitForDuration:0.0f];
        fade3 = [SKAction fadeAlphaTo:0.0f duration:kFadeDurationLong]; //longer
        fade4 = [SKAction runBlock:^{
            [self.fadeView removeFromParent];
        }];
    }

    fadeSequence = [SKAction sequence:@[fade1,fade2,fade3, fade4]];
    [self.fadeView runAction:fadeSequence];
}

-(void)didMoveToView:(SKView *)view {
    //[self fade:NO animated:YES];
}

/*
- (void)willMoveFromView:(SKView *)view
{
    [super willMoveFromView:view];

    //alert
    if(self.alertView && !self.alertView.hidden)
        [self.alertView dismissAnimated:NO];
    
    if(self.timer)
        [self.timer invalidate];
}*/


- (void)done {
    //alert
    if(self.alertView && !self.alertView.hidden)
        [self.alertView dismissAnimated:NO];
    
    if(self.timer)
        [self.timer invalidate];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)updateComboLabel {
    self.comboLabel.hidden = NO; //(self.clickCount == 0); //hide
    //self.comboLabel.alpha = 1.0;
    self.comboLabel.text = [NSString stringWithFormat:@"%d-hit combo", self.lastComboCount];
    self.comboLabelShadow.text = self.comboLabel.text;
    
    //slide speed
    float duration = 0.2f;
    
    //fade
    [self.comboLabel removeAllActions];
    [self.comboLabelShadow removeAllActions];
    
    SKAction *actionfade0 = [SKAction fadeAlphaTo:1.0f duration:duration];//in
    SKAction *actionfade1 = [SKAction waitForDuration:1.0f];
    SKAction *actionfade2 = [SKAction fadeAlphaTo:0.0f duration:duration];//out
    SKAction *fadeSequence = [SKAction sequence:@[actionfade0,actionfade1,actionfade2]];
    [self.comboLabel runAction:fadeSequence];
    [self.comboLabelShadow runAction:fadeSequence];
    
    //slide
    
    //self.comboLabel.position = CGPointMake(20, self.frame.size.height - 150);
    
    int offset = 200;
    int x = 20;
    int y = self.frame.size.height - 150;
    
    //[self.comboLabel removeAllActions];
    //SKAction *actionslide0 = [SKAction moveTo:CGPointMake(x-offset, y) duration:0.0f];//out
    SKAction *actionslide1 = [SKAction moveTo:CGPointMake(x, y) duration:duration]; //in
    SKAction *actionslide2 = [SKAction waitForDuration:1.0f];
    SKAction *actionslide3 = [SKAction moveTo:CGPointMake(x-offset, y) duration:duration]; //out
    SKAction *slideSequence = [SKAction sequence:@[/*actionslide0,*/actionslide1,actionslide2,actionslide3]];
    [self.comboLabel runAction:slideSequence];
    [self.comboLabelShadow runAction:slideSequence];
    
}


-(void)updateTimer {
    if(YES) {
        
        self.timerLabel.text = [NSString stringWithFormat:@"%d", self.timerCount];
        self.timerLabelShadow.text = self.timerLabel.text;
        
        float scale = 1.0f;
        
        if(self.timerCount <= 5 && self.timerCount >= 0) {
            scale = 1.4f; //bigger
            self.timerLabel.fontColor = RGB(252,118,8); //orange
        }
        else {
            scale = 1.05f;
            self.timerLabel.fontColor = RGB(255,228,0); //yellow
        }
        
        [self.timerLabel removeAllActions];
        [self.timerLabelShadow removeAllActions];
        SKAction *action0 = [SKAction scaleTo:1.0f duration:0.0f];
        SKAction *action1 = [SKAction scaleTo:scale duration:0.1f];
        SKAction *action2 = [SKAction waitForDuration:0.1f];
        SKAction *action3 = [SKAction scaleTo:1.0f duration:0.1f];
        SKAction *sequence = [SKAction sequence:@[action0,action1,action3,action2]];
        [self.timerLabel runAction:sequence];
        [self.timerLabelShadow runAction:sequence];

        
    }
    else {
        self.timerLabel.text = [NSString stringWithFormat:@"∞"];
        self.timerLabelShadow.text = self.timerLabel.text;
        self.comboLabel.fontColor = RGB(255,228,0); //yellow

    }
}


-(void)updateCreditLabel {
    self.creditsLabel.text = [NSString stringWithFormat:@"%d", kAppDelegate.credits];
}

-(void)showSuccess {
    
    [kHelpers sendGoogleAnalyticsEventWithCategory:@"game" andAction:@"game" andLabel:@"success"];

    [kAppDelegate playSound:@"coin3.wav"];
    [kAppDelegate playSound:@"voice_combo.mp3"];
    
    
    //timer
    self.timerCount += kTimerWin;
    if(self.timerCount > kTimerMax)
        self.timerCount = kTimerMax;
        
    [self updateTimer];
    
    //credits
    //kAppDelegate.credits++;
    //[self updateCreditLabel];
    
    //inc pattern count
    //self.patternCount++;
    if(self.patternCount > 10)
        self.patternCount = 10;
    
    //particle
    SKEmitterNode *myParticle = [SKEmitterNode emitterWithResourceNamed:@"Particle1"];
    
    //myParticle.particlePosition = buttonNode.position;
    myParticle.particlePosition = self.comboLabel.position;
    myParticle.particlePosition = CGPointMake(self.comboLabel.position.x+50, self.comboLabel.position.y + 20);
    
    myParticle.zPosition = 100;
    myParticle.userInteractionEnabled = NO;
    myParticle.numParticlesToEmit = 200;
    myParticle.particleBirthRate = myParticle.numParticlesToEmit * 10.0f; //0.1 duration
    myParticle.alpha = 0.6f;
    
    [self addChild:myParticle];

}

-(void)showOverlayWrong:(CGPoint)point {

    [kHelpers sendGoogleAnalyticsEventWithCategory:@"game" andAction:@"game" andLabel:@"wrong"];

    //particle
    SKEmitterNode *myParticle = [SKEmitterNode emitterWithResourceNamed:@"Particle2"];
    
    //myParticle.particlePosition = buttonNode.position;
    myParticle.particlePosition = self.comboLabel.position;
    
    point.y += 20;
    myParticle.particlePosition = point;
    
    myParticle.zPosition = 100;
    myParticle.userInteractionEnabled = NO;
    myParticle.numParticlesToEmit = 100;
    myParticle.particleBirthRate = myParticle.numParticlesToEmit * 5.0f; //10 0.1 duration
    myParticle.alpha = 0.6f;
    
    [self addChild:myParticle];

    
    [kAppDelegate playSound:@"wrong.wav"];
    //self.clickCount = 0;
    
    //fade
    [self.overlayWrong removeAllActions];
    self.overlayWrong.hidden = NO;
    [self addChild:self.overlayWrong];
    SKAction *actionfade0 = [SKAction fadeAlphaTo:0.0f duration:0.0f];
    SKAction *actionfade1 = [SKAction fadeAlphaTo:1.0f duration:0.1f];
    SKAction *actionfade2 = [SKAction waitForDuration:0.4f];
    SKAction *actionfade3 = [SKAction fadeAlphaTo:0.0f duration:0.2f];
    SKAction *actionfade4 = [SKAction runBlock:^{
        self.overlayWrong.hidden = YES;
        [self.overlayWrong removeFromParent];
    }];
    SKAction *fadeSequence = [SKAction sequence:@[actionfade0,actionfade1,actionfade2,actionfade3, actionfade4]];
    [self.overlayWrong runAction:fadeSequence];
    
    
    //scale
    SKAction *actionScale0 = [SKAction scaleTo:0.0f duration:0.0f];
    SKAction *actionScale1 = [SKAction scaleTo:1.0f duration:0.1f];
    SKAction *actionScale2 = [SKAction waitForDuration:0.4f];
    SKAction *actionScale3 = [SKAction scaleTo:0.0f duration:0.2f];
    SKAction *scaleSequence = [SKAction sequence:@[actionScale0,actionScale1,actionScale2,actionScale3]];
    
    [self.overlayWrong runAction:scaleSequence];

    
}

-(void)showOverlayTimesout {
    
    [kHelpers sendGoogleAnalyticsEventWithCategory:@"game" andAction:@"game" andLabel:@"timeout"];

    
    //disable input
    self.showingPattern = YES;
    
    [kAppDelegate playSound:@"wrong.wav"];
    
    //home
    float secs = 1.5f;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secs * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self done];
        
        [self fade:YES animated:YES];
        
        float secs = kFadeDuration;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secs * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            UIViewController *controller = [kAppDelegate.storyboard instantiateViewControllerWithIdentifier:@"home"];
            [self.view.window setRootViewController:controller];
        });
        
        
    });

    
    [self.overlayTimesout removeAllActions];
    self.overlayTimesout.hidden = NO;
    [self addChild:self.overlayTimesout];
    SKAction *actionfade0 = [SKAction fadeAlphaTo:0.0f duration:0.0f];
    SKAction *actionfade1 = [SKAction waitForDuration:0.5f];
    SKAction *actionfade2 = [SKAction fadeAlphaTo:1.0f duration:0.1f];
    
    SKAction *actionfade6 = [SKAction runBlock:^{
        [kAppDelegate playSound:@"voice_timeout.mp3"];
    }];
    
    SKAction *actionfade3 = [SKAction waitForDuration:1.0f];
    SKAction *actionfade4 = [SKAction fadeAlphaTo:0.0f duration:0.2f];
    SKAction *actionfade5 = [SKAction runBlock:^{
        
        self.overlayTimesout.hidden = YES;
        [self.overlayTimesout removeFromParent];
    }];
    
    SKAction *fadeSequence = [SKAction sequence:@[actionfade0,actionfade1,actionfade2,actionfade6,actionfade3, actionfade4, actionfade5]];
    [self.overlayTimesout runAction:fadeSequence];
    
    //scale
    SKAction *actionScale0 = [SKAction scaleTo:0.0f duration:0.0f];
    SKAction *actionScale1 = [SKAction waitForDuration:0.5f];
    SKAction *actionScale2 = [SKAction scaleTo:1.0f duration:0.1f];
    SKAction *actionScale3 = [SKAction waitForDuration:1.0f];
    SKAction *actionScale4 = [SKAction scaleTo:0.0f duration:0.2f];
    SKAction *scaleSequence = [SKAction sequence:@[actionScale0,actionScale1,actionScale2,actionScale3, actionScale4]];
    
    [self.overlayTimesout runAction:scaleSequence];

}

-(void)showOverlayStart {
    
    //voice
    //http://www.fromtexttospeech.com/
    

    [self.overlayStart removeAllActions];
    self.overlayStart.hidden = NO;
    [self addChild:self.overlayStart];
    SKAction *actionfade0 = [SKAction fadeAlphaTo:0.0f duration:0.0f];
    SKAction *actionfade1 = [SKAction waitForDuration:0.5f];
    SKAction *actionfade2 = [SKAction fadeAlphaTo:1.0f duration:0.1f];
    
    SKAction *actionfade6 = [SKAction runBlock:^{
        [kAppDelegate playSound:@"voice_ready.mp3"];
    }];
    
    SKAction *actionfade3 = [SKAction waitForDuration:1.0f];
    SKAction *actionfade4 = [SKAction fadeAlphaTo:0.0f duration:0.2f];
    SKAction *actionfade5 = [SKAction runBlock:^{
        
        [self resetTimer];
        
        self.overlayStart.hidden = YES;
        [self.overlayStart removeFromParent];
    }];
    
    SKAction *fadeSequence = [SKAction sequence:@[actionfade0,actionfade1,actionfade2,actionfade6,actionfade3, actionfade4, actionfade5]];
    [self.overlayStart runAction:fadeSequence];
    
    //scale
    SKAction *actionScale0 = [SKAction scaleTo:0.0f duration:0.0f];
    SKAction *actionScale1 = [SKAction waitForDuration:0.5f];
    SKAction *actionScale2 = [SKAction scaleTo:1.0f duration:0.1f];
    SKAction *actionScale3 = [SKAction waitForDuration:1.0f];
    SKAction *actionScale4 = [SKAction scaleTo:0.0f duration:0.2f];
    SKAction *scaleSequence = [SKAction sequence:@[actionScale0,actionScale1,actionScale2,actionScale3, actionScale4]];
    
    [self.overlayStart runAction:scaleSequence];

}

-(void)showPattern {

    //return;

    if(self.showingPattern)
        return;

    self.currentPatternIndex = 0;
    self.showingPattern = YES;
    
    //label
    self.clickCount = 0;
    //[self updateComboLabel];
    
    //[self resetTimer];
    
    double delay = 0.0f;
    if(self.firstTime)
        delay = 2.0f;
    else
        delay = 1.0f;

    double delayInc = 0.5f;
    
    NSArray *possibleMovesJoystick = @[@(JoystickDirectionUp), @(JoystickDirectionDown),
                                       @(JoystickDirectionLeft),@(JoystickDirectionRight)];
    NSArray *possibleMovesButtons= @[@(ButtonType1), @(ButtonType2), @(ButtonType3),
                                       @(ButtonType4), @(ButtonType5), @(ButtonType6)];
    
    /*NSArray *possibleMovesArray = @[@(JoystickDirectionUp), @(JoystickDirectionDown),
                                    @(JoystickDirectionLeft),@(JoystickDirectionRight),
                                    @(ButtonType1), @(ButtonType2), @(ButtonType3),
                                    @(ButtonType4), @(ButtonType5), @(ButtonType6)];*/
    
    
    self.patternArray = [NSMutableArray array];
    //generate pattern
    int lastButton = -1;
    for(int j=0;j<self.patternCount; j++) {
        int button = 0;
        
        int loopCount = 0;
        while(YES) {
            if(j%3 == 0 || j%3 == 1) {
                //int index = 0 + arc4random() % (possibleMovesJoystick.count);
                int index = 0 + arc4random_uniform((int)possibleMovesJoystick.count);
                
                assert(index < possibleMovesJoystick.count);
                button = [[possibleMovesJoystick objectAtIndex:index] intValue];
            }
            else if(j%3 == 2) {
                //int index = 0 + arc4random() % (possibleMovesButtons.count);
                int index = 0 + arc4random_uniform((int)possibleMovesButtons.count);

                assert(index < possibleMovesButtons.count);
                button = [[possibleMovesButtons objectAtIndex:index] intValue];
            }
            else {
                assert(0);
            }
            
            if(lastButton != button) {
                lastButton = button; //test to be different
                break;
            }
            
            //in case
            loopCount++;
            if(loopCount > 100)
                break;
        }
        
        [self.patternArray addObject:[NSNumber numberWithInt:button]];
    }
    
    //glow
    for(int j=0;j<self.patternCount; j++) {
        
        int buttonIndex = [[self.patternArray objectAtIndex:j] intValue];
        
        //joystick glow
        if(buttonIndex >= JoystickDirectionUp && buttonIndex <= JoystickDirectionDownLeft)
        {
            for (SKSpriteNode *node in self.joystickButton.children) {
                
                if ([node.name isEqualToString:@"joystick_ball_glow"] ) {
                    node.alpha = 0.0;
                    
                    SKAction *delayAction = [SKAction waitForDuration:delay];
                    
                    //sound
                    SKAction *action0 = [SKAction fadeAlphaTo:0.0f duration:0.0f];
                    SKAction *action1 = [SKAction fadeAlphaTo:1.0f duration:0.1f];
                    SKAction *action2 = [SKAction waitForDuration:0.2f];
                    SKAction *action3 = [SKAction fadeAlphaTo:0.0f duration:0.1f];
                    
                    //sound
                    int min = 1;
                    int max = 3;
                    //int random =  min + arc4random() % (max-min);
                    int random =  min + arc4random_uniform(max);
                    
                    NSString *soundName = [NSString stringWithFormat:@"click%d.wav", random];
                    SKAction *actionSound = [SKAction playSoundFileNamed:soundName waitForCompletion:NO];

                    SKAction *glowSequence = nil;
                    
                    //last
                    if(j == self.patternCount -1) {
                        
                        node.texture= [SKTexture textureWithImageNamed:@"joystick_ball_glow"];
                        
                        //done
                        SKAction *actionDone = [SKAction runBlock:^{
                            self.showingPattern = NO;
                        }];

                        glowSequence = [SKAction sequence:@[delayAction, actionSound, action0, action1, action2, action3, actionDone]];
                    }
                    else
                    {
                        node.texture= [SKTexture textureWithImageNamed:@"joystick_ball_glow"];
                        glowSequence = [SKAction sequence:@[delayAction, actionSound, action0, action1, action2, action3]];
                    }
                    
                    [node runAction:glowSequence];
                    
                    //move joystick
                    float angle = 0;
                    switch(buttonIndex)
                    {
                        case JoystickDirectionUp:
                            angle = 180;
                            break;
                        case JoystickDirectionDown:
                            angle = 0;
                            break;
                        case JoystickDirectionRight:
                            angle = 90;
                            break;
                        case JoystickDirectionLeft:
                            angle = -90;
                            break;
                            
                        case JoystickDirectionUpRight:
                            angle = 135;
                            break;
                        case JoystickDirectionDownRight:
                            angle = 45;
                            break;
                        case JoystickDirectionUpLeft:
                            angle = -135;
                            break;
                        case JoystickDirectionDownLeft:
                            angle = -45;
                            break;
                            
                        default:
                            NSLog(@"invalid direction");
                            break;
                    }

                    
                    /* glow
                     SKAction *delayAction = [SKAction waitForDuration:delay];
                     //sound
                     SKAction *action0 = [SKAction fadeAlphaTo:0.0f duration:0.0f];
                     SKAction *action1 = [SKAction fadeAlphaTo:1.0f duration:0.1f];
                     SKAction *action2 = [SKAction waitForDuration:0.3f];
                     SKAction *action3 = [SKAction fadeAlphaTo:0.0f duration:0.3f];
                     */
                    
                    CGPoint newPosition = [self getPositionFrom:self.joystickBack.position withDistance:kJoystickRadius withAngle:angle];
                    
                    SKAction *joystickMove = [SKAction moveTo:newPosition duration:0.1f];
                    SKAction *joystickWait = [SKAction waitForDuration:0.1f];
                    SKAction *joystickMoveBack = [SKAction moveTo:CGPointMake(self.joystickBack.position.x, self.joystickBack.position.y) duration:0.1f];
                    SKAction *joystickSequence = [SKAction sequence:@[delayAction, joystickMove, joystickWait, joystickMoveBack]];
                    [self.joystickButton runAction:joystickSequence];
                    

                    //delay
                    delay += delayInc;
                }
            }
        }
        else {
            //button
            SKSpriteNode *button = [self.buttonArray objectAtIndex:(buttonIndex-ButtonType1)];
            assert(button);
            
            //glow
            for (SKSpriteNode *node in button.children) {
                
                if ([node.name isEqualToString:@"glow"] ) {
                    node.alpha = 0.0;
                    
                    SKAction *delayAction = [SKAction waitForDuration:delay];
                    delay += delayInc;
                    
                    //sound
                    int min = 1;
                    int max = 3;
                    //int random =  min + arc4random() % (max-min);
                    int random =  min + arc4random_uniform(max);
                    
                    NSString *soundName = [NSString stringWithFormat:@"click%d.wav", random];
                    SKAction *actionSound = [SKAction playSoundFileNamed:soundName waitForCompletion:NO];
                    
                    SKAction *action0 = [SKAction fadeAlphaTo:0.0f duration:0.0f];
                    SKAction *action1 = [SKAction fadeAlphaTo:1.0f duration:0.1f];
                    SKAction *action2 = [SKAction waitForDuration:0.3f];
                    SKAction *action3 = [SKAction fadeAlphaTo:0.0f duration:0.3f];
                    
                    SKAction *glowSequence = nil;
                    //last
                    if(j == self.patternCount -1) {
                        
                        node.texture= [SKTexture textureWithImageNamed:@"glow"];
                        
                        //done
                        SKAction *actionDone = [SKAction runBlock:^{
                            self.showingPattern = NO;
                        }];
                        
                        glowSequence = [SKAction sequence:@[delayAction, actionSound, action0, action1, action2, action3, actionDone]];
                    }
                    else
                    {
                        node.texture= [SKTexture textureWithImageNamed:@"glow"];
                        glowSequence = [SKAction sequence:@[delayAction, actionSound, action0, action1, action2, action3]];
                    }
                    
                    SKAction *actionButtonDown = [SKAction setTexture:[SKTexture textureWithImageNamed:@"button_down"]];
                    SKAction *actionButtonWait = [SKAction waitForDuration:0.3f];
                    SKAction *actionButtonDone = [SKAction setTexture:[SKTexture textureWithImageNamed:@"button_up"]];
                    SKAction *buttonSequence = [SKAction sequence:@[delayAction, actionButtonDown, actionButtonWait, actionButtonDone]];
                    //[button removeAllActions];
                    [button runAction:buttonSequence];
                    
                    //[node removeAllActions];
                    [node runAction:glowSequence];
                    //glowNode.alpha = 1.0;
                    break;
                }
            }
        }
        
    }

}

-(void)buttonClicked:(STControlSprite*)button
{
    
    [kHelpers sendGoogleAnalyticsEventWithCategory:@"game" andAction:@"tap" andLabel:@"button"];

    if(self.showingPattern)
        return;

    //NSLog(@"buttonClicked");
    
    int i = 0;
    for(STControlSprite *tempButton in self.buttonArray) {
        if(tempButton == button)
            break;
        
        i++;
    }
    
    //down
    button.texture = [SKTexture textureWithImageNamed:@"button_down"];
    
    //sound
    int min = 1;
    int max = 3;
    //int random =  min + arc4random() % (max-min);
    int random =  min + arc4random_uniform(max);
    
    NSString *soundName = [NSString stringWithFormat:@"click%d.wav", random];
    //[self runAction:[SKAction playSoundFileNamed:soundName waitForCompletion:NO]];
    [kAppDelegate playSound:soundName];
    
    //wrong
    //find type
    ButtonType buttonType = 0;
    int k = 0;
    for (SKSpriteNode *tempButton in self.buttonArray) {
        if(button == tempButton) {
           buttonType = ButtonType1 + k;
        break;
        }
        k++;
    }
    
    if([[self.patternArray objectAtIndex:self.currentPatternIndex] intValue] != buttonType) {
        [self showOverlayWrong:button.position];
        
        //pattern
        [self showPattern];
        return;
    }

    //good
    self.currentPatternIndex++;

    //label
    self.clickCount++;
    self.lastComboCount = self.clickCount;
    [self updateComboLabel];
    
    int successCount = self.patternCount;
    
    //success
    if((self.clickCount % successCount)  == 0) {

        [self showSuccess];
        
        [self showPattern];
    }

}

-(void)buttonUnclicked:(STControlSprite*)button
{
    button.texture = [SKTexture textureWithImageNamed:@"button_up"];

    if(self.showingPattern)
        return;

    NSString *soundName = [NSString stringWithFormat:@"unclick.wav"];
    [kAppDelegate playSound:soundName];

}

- (SKNode *)nodeAtPoint:(CGPoint)p {
    return [self nodeAtPointWithUserInteractionEnabledAlgorithm:p];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    /*
    //reset all
    for(SKSpriteNode *tempNode in self.buttonArray) {
        tempNode.texture = [SKTexture textureWithImageNamed:@"button_up"];
    }
    */
}


-(void)update:(CFTimeInterval)currentTime {
    
    if(self.firstTime) {
        
        //fade
        [self fade:NO animated:YES];

        //float secs = 0.5f;
        //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secs * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        //fade
        [self showOverlayStart];

        
        //pattern
        [self showPattern];
            
        //});

        
        self.firstTime = NO;
    }
    
}


#pragma mark - Simple dragging

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*) event
{
    SKNode* tempNode = [self nodeAtPoint:[[touches anyObject] locationInNode:self]];
    //if(!tempNode)
    //    return;
    
    if(self.showingPattern) {
        //move back
        SKAction *moveAction = [SKAction moveTo:self.joystickBack.position duration:0.1f];
        [self.joystickButton runAction:moveAction];
        
        return;
    }
    
    //find joystick glow
    SKSpriteNode *joystickGlowNode = nil;
    for (SKSpriteNode *node in self.joystickButton.children) {
        
        if ([node.name isEqualToString:@"joystick_ball_glow"] ) {
            joystickGlowNode = node;
            break;
        }
    }

    if(tempNode == self.joystickButton || tempNode == joystickGlowNode) {
        
        self.draggedNode = self.joystickButton;
        
        //darken
        //self.joystickButton.texture = [SKTexture textureWithImage:[self darkenImage:[UIImage imageNamed:@"joystick_ball"]]];
        self.joystickButton.texture = [SKTexture textureWithImageNamed:@"joystick_ball_down"];

        
        //grow
        //SKAction *scaleAction = [SKAction scaleTo:1.2f duration:0.1f];
        //[self.joystickButton runAction:scaleAction];

    }
    else
       self.draggedNode = nil;
}


-(void)touchesMoved:(NSSet*) touches withEvent:(UIEvent*) event
{
    if(self.showingPattern) {
        //move back
        SKAction *moveAction = [SKAction moveTo:self.joystickBack.position duration:0.1f];
        [self.joystickButton runAction:moveAction];
        
        return;
    }
    
    //joystick
    if(self.draggedNode) {
        
        CGPoint position = [[touches anyObject] locationInNode:self];
        
        float angle = [self getAngleBetweenPoints:position withPoint:self.joystickBack.position];
        float distance = distanceBetweenPoints(position, self.joystickBack.position);
        
        //NSLog(@"angle: %f", angle);
        //NSLog(@"distance: %f", distance);
        
        //min/max
        
        //radius
        float offset = kJoystickRadius;
        if(distance >= offset) {
            
            //NSLog(@"angle: %f", angle);

            position = [self getPositionFrom:self.joystickBack.position withDistance:offset withAngle:angle];
            
            JoystickDirection tempDirection = JoystickDirectionNone;
            
            if(angle < 90 + kJoystickAngleOffset && angle > 90 - kJoystickAngleOffset) {
                tempDirection = JoystickDirectionRight;
            }
            else if(angle < 0 + kJoystickAngleOffset && angle > 0 - kJoystickAngleOffset) {
                tempDirection = JoystickDirectionDown;
            }
            else if(angle < -90 + kJoystickAngleOffset && angle > -90 - kJoystickAngleOffset) {
                tempDirection = JoystickDirectionLeft;
            }
            
            else if(angle < 180 + kJoystickAngleOffset && angle > 180 - kJoystickAngleOffset) {
                tempDirection = JoystickDirectionUp;
            }
            else if(angle < -180 + kJoystickAngleOffset && angle > -180 - kJoystickAngleOffset) {
                tempDirection = JoystickDirectionUp;
            }
            
            
            else if(angle < 135 + kJoystickAngleOffset && angle > 135 - kJoystickAngleOffset) {
                tempDirection = JoystickDirectionUpRight;
            }
            else if(angle < 45 + kJoystickAngleOffset && angle > 45 - kJoystickAngleOffset) {
                tempDirection = JoystickDirectionDownRight;
            }
            
            else if(angle < -135 + kJoystickAngleOffset && angle > -135 - kJoystickAngleOffset) {
                tempDirection = JoystickDirectionUpLeft;
            }
            else if(angle < -45 + kJoystickAngleOffset && angle > -45 - kJoystickAngleOffset) {
                tempDirection = JoystickDirectionDownLeft;
            }
            


            else {
                tempDirection = JoystickDirectionNone;
            }

            
            //not already detected, or new angle
            //if(!self.joystickEdgeDetected || (abs(self.joystickEdgeDetectedAngle - angle) > angleNeeded)) {
            if(!self.joystickEdgeDetected || (self.joystickDirection!=tempDirection && tempDirection != JoystickDirectionNone)) {
                
                self.joystickEdgeDetected = YES;
                self.joystickEdgeDetectedAngle = angle;

                self.joystickDirection = tempDirection;

                switch(self.joystickDirection)
                {
                    case JoystickDirectionUp:
                        NSLog(@"JoystickDirectionUp");
                        break;
                    case JoystickDirectionDown:
                        NSLog(@"JoystickDirectionDown");
                        break;
                    case JoystickDirectionRight:
                        NSLog(@"JoystickDirectionRight");
                        break;
                    case JoystickDirectionLeft:
                        NSLog(@"JoystickDirectionLeft");
                        break;
                        
                    case JoystickDirectionUpRight:
                        NSLog(@"JoystickDirectionUpRight");
                        break;
                    case JoystickDirectionDownRight:
                        NSLog(@"JoystickDirectionDownRight");
                        break;
                    case JoystickDirectionUpLeft:
                        NSLog(@"JoystickDirectionUpLeft");
                        break;
                    case JoystickDirectionDownLeft:
                        NSLog(@"JoystickDirectionDownLeft");
                        break;
                        
                    default:
                        //NSLog(@"JoystickDirectionNone");
                        break;
                }
                
                //sound
                int min = 1;
                int max = 3;
                //int random =  min + arc4random() % (max-min);
                int random =  min + arc4random_uniform(max);
                
                NSString *soundName = [NSString stringWithFormat:@"click%d.wav", random];
                [kAppDelegate playSound:soundName];
                
                BOOL goodEnough = NO;
                switch([[self.patternArray objectAtIndex:self.currentPatternIndex] intValue])
                {
                    case JoystickDirectionUp:
                        if(self.joystickDirection == JoystickDirectionUp ||
                            self.joystickDirection == JoystickDirectionUpLeft ||
                            self.joystickDirection == JoystickDirectionUpRight)
                            goodEnough = YES;
                        break;
                    case JoystickDirectionDown:
                        if(self.joystickDirection == JoystickDirectionDown ||
                            self.joystickDirection == JoystickDirectionDownLeft ||
                            self.joystickDirection == JoystickDirectionDownRight)
                            goodEnough = YES;
                        break;
                    case JoystickDirectionRight:
                        if(self.joystickDirection == JoystickDirectionRight ||
                            self.joystickDirection == JoystickDirectionUpRight ||
                            self.joystickDirection == JoystickDirectionDownRight)
                            goodEnough = YES;
                        break;
                    case JoystickDirectionLeft:
                        if(self.joystickDirection == JoystickDirectionLeft ||
                            self.joystickDirection == JoystickDirectionUpLeft ||
                            self.joystickDirection == JoystickDirectionDownLeft)
                            goodEnough = YES;
                        break;
                        
                    case JoystickDirectionUpRight:
                        if(self.joystickDirection == JoystickDirectionUpRight ||
                            self.joystickDirection == JoystickDirectionUp ||
                            self.joystickDirection == JoystickDirectionRight)
                            goodEnough = YES;
                        break;
                    case JoystickDirectionDownRight:
                        if(self.joystickDirection == JoystickDirectionDownRight ||
                            self.joystickDirection == JoystickDirectionDown ||
                            self.joystickDirection == JoystickDirectionRight)
                            goodEnough = YES;
                        break;
                    case JoystickDirectionUpLeft:
                        if(self.joystickDirection == JoystickDirectionUpLeft ||
                            self.joystickDirection == JoystickDirectionUp ||
                            self.joystickDirection == JoystickDirectionLeft)
                            goodEnough = YES;
                        break;
                    case JoystickDirectionDownLeft:
                        if(self.joystickDirection == JoystickDirectionDownLeft ||
                            self.joystickDirection == JoystickDirectionLeft ||
                            self.joystickDirection == JoystickDirectionDown)
                            goodEnough = YES;
                        break;
                        
                    default:
                        //NSLog(@"JoystickDirectionNone");
                        break;
                }

                
                //wrong
                if(!goodEnough) {
                    
                    [self showOverlayWrong:self.joystickBack.position];
                    
                    //pattern
                    [self showPattern];
                    return;
                }
                
                //good
                self.currentPatternIndex++;

                self.clickCount++;
                self.lastComboCount = self.clickCount;
                [self updateComboLabel];
                
                int successCount = self.patternCount;
                
                //success
                if((self.clickCount % successCount)  == 0) {

                    [self showSuccess];
                    
                    //pattern
                    //float secs = 0.5f;
                    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secs * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self showPattern];
                    //});
                }

                
            }

        }
        else
        {
            self.joystickEdgeDetected = NO;
            self.joystickEdgeDetectedAngle = 0;
        }
        
        self.draggedNode.position = position;
        
    }
}

-(void)touchesEnded:(NSSet*) touches withEvent:(UIEvent*) event
{
    self.joystickEdgeDetected = NO;
    self.joystickEdgeDetectedAngle = 0;
    //self.joystickButton.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"joystick_ball"]];
    self.joystickButton.texture = [SKTexture textureWithImageNamed:@"joystick_ball"];

    if(self.showingPattern) {
        //move back
        SKAction *moveAction = [SKAction moveTo:self.joystickBack.position duration:0.1f];
        [self.joystickButton runAction:moveAction];
        
        return;
    }
    

    if(self.draggedNode) {
        self.draggedNode = nil;
        
        //move back
        SKAction *moveAction = [SKAction moveTo:self.joystickBack.position duration:0.1f];
        [self.joystickButton runAction:moveAction];
        
        //sound
        NSString *soundName = [NSString stringWithFormat:@"unclick.wav"];
        [kAppDelegate playSound:soundName];

    }
}


- (UIImage *)darkenImage:(UIImage *)image{
    CIImage *ref = [CIImage imageWithCGImage:[image CGImage]];
    CIFilter *darken = [CIFilter filterWithName:@"CIPhotoEffectFade" keysAndValues:kCIInputImageKey, ref, nil];
    CIContext *context = [CIContext contextWithOptions:Nil];
    CIImage *outputImage = [darken outputImage];
    
    CGImageRef cgimg =
    [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImg = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    return newImg;
}

#pragma mark - Math

- (float) getAngleBetweenPoints:(CGPoint)a withPoint:(CGPoint)b
{
    int x = a.x;
    int y = a.y;
    float dx = b.x - x;
    float dy = b.y - y;
    CGFloat radians = atan2(-dx,dy);        // in radians
    CGFloat degrees = radians * 180 / 3.14; // in degrees
    return degrees;
}

- (CGPoint) getPositionFrom:(CGPoint)origin withDistance:(float)distance withAngle:(float)angle
{
    CGPoint endPoint;
    
    endPoint.x = sinf(DEGREES_TO_RADIANS(angle)) * distance;
    endPoint.y = - cosf(DEGREES_TO_RADIANS(angle)) * distance;
    
    endPoint.x += origin.x;
    endPoint.y += origin.y;
    
    return endPoint;
}

CGFloat distanceBetweenPoints(CGPoint first, CGPoint second) {
    return hypotf(second.x - first.x, second.y - first.y);
}

- (void)resetTimer{
    
    [self.timer invalidate];
    self.timer = nil;

    self.timerCount = kTimerStart;
    
    float interval = 1.0f;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self
                                                selector:@selector(actionTimer:) userInfo:@"actionTimer" repeats:YES];
}

- (void) actionTimer:(NSTimer *)incomingTimer
{
    //paused
    if(self.gamePaused)
        return;
    

    //NSLog(@"actionTimer");
    
    if(self.timerCount <= 0) {
        //already
        return;
    }

    self.timerCount--;
    if(self.timerCount <= 0) {
        self.timerCount = 0;
        
        [self showOverlayTimesout];
    }
    
    if(self.timerCount == 0) {
        
        [kAppDelegate playSound:@"powerdown1.mp3"];
    }
    
    if(self.timerCount == 5) {
        [kAppDelegate playSound:@"gasp1.wav"];
    }
    
    //tic-toc

    if(self.timerCount <= 5 && self.timerCount > 0) {
        [kAppDelegate playSound:@"clock_tick.mp3"];
    }

    
    [self updateTimer];
}

-(void)pause:(BOOL)pause {
    
    //already
    if(self.gamePaused && pause)
        return;
    
    if(pause) {
        if(!self.pauseView) {
            self.pauseView = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:[self getBluredScreenshot]]];
            self.pauseView.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
            self.pauseView.zPosition = 400;
        }

        self.pauseView.alpha = 0;
        [self.pauseView runAction:[SKAction fadeAlphaTo:1 duration:kPauseFadeDuration]];
        
        if(![self.pauseView parent])
            [self addChild:self.pauseView];
    }
    else {
        if(self.pauseView) {
            
            self.pauseView.alpha = 1;
            [self.pauseView runAction:[SKAction fadeAlphaTo:0 duration:kPauseFadeDuration] completion:^{
                [self.pauseView removeFromParent];
            }];
            
        }
    }

    self.gamePaused = pause;
    
    if(pause)
        [kAppDelegate stopMusic];
    else
        [kAppDelegate playMusic:@"music1.wav"];
    
}

- (UIImage *)getBluredScreenshot {
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 1);
    [self.view drawViewHierarchyInRect:self.view.frame afterScreenUpdates:YES];
    UIImage *ss = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlurFilter setDefaults];
    [gaussianBlurFilter setValue:[CIImage imageWithCGImage:[ss CGImage]] forKey:kCIInputImageKey];
    [gaussianBlurFilter setValue:@10 forKey:kCIInputRadiusKey];
    
    CIImage *outputImage = [gaussianBlurFilter outputImage];
    CIContext *context   = [CIContext contextWithOptions:nil];
    CGRect rect          = [outputImage extent];
    rect.origin.x        += (rect.size.width  - ss.size.width ) / 2;
    rect.origin.y        += (rect.size.height - ss.size.height) / 2;
    rect.size            = ss.size;
    CGImageRef cgimg     = [context createCGImage:outputImage fromRect:rect];
    UIImage *image       = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    return image;
}

@end
