//
//  ResultsViewController.m
//  DoYouKnowMe
//
//  Created by Arthur Alvarez on 3/30/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "ResultsViewController.h"
#import "AppDelegate.h"
#import "GameSettings.h"
#import "Player.h"
#import "GameViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ResultsViewController ()
{
	BOOL _right;
}

///Interface label that shows title
@property (weak, nonatomic) IBOutlet UILabel *topLabel;

///Interface label that shows percent
@property (weak, nonatomic) IBOutlet UILabel *percentLabel;

///Interface button
@property (weak, nonatomic) IBOutlet UIButton *btnBack1;

///Interface button
@property (weak, nonatomic) IBOutlet UIButton *btnBack2;

/// ProgressView to display the results
@property (weak, nonatomic) IBOutlet UIProgressView *rate;

@property (weak, nonatomic) IBOutlet UIImageView *showWOrR;

/// Feedback sound
@property SystemSoundID rightAudio;

/// Feedback sound
@property SystemSoundID wrongAudio;

@end

@implementation ResultsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    if([Player getPlayerID] == 1){
        self.topLabel.text = [NSString stringWithFormat:@"Quanto %@ me conhece...", _game.otherPlayer.displayName];
    }
    else if([Player getPlayerID] == 2){
        self.topLabel.text = [NSString stringWithFormat:@"Quanto conheço %@...", _game.otherPlayer.displayName];
    }
    
    NSLog(@"score final: %d", [Player getScore]);
    NSLog(@"knowing percent: %f", [Player knowingPercent]);
	
	if ([Player knowingPercent] <= 0.2f) _percentLabel.text = [NSString stringWithFormat:@"Muito pouco...\n\nTente novamente!"];
	else if ([Player knowingPercent] <= 0.4f) _percentLabel.text = [NSString stringWithFormat:@"Pouco...\n\nDá para melhorar bastante isso, hein?"];
	else if ([Player knowingPercent] <= 0.6f) _percentLabel.text = [NSString stringWithFormat:@"Nem muito, nem pouco...\n\nAinda dá para melhorar isso!"];
	else if ([Player knowingPercent] <= 0.8f) _percentLabel.text = [NSString stringWithFormat:@"Bem!"];
	else _percentLabel.text = [NSString stringWithFormat:@"Muito bem!!\n\nVocês são grandes amigos!!"];
	
	_btnBack1.layer.cornerRadius = 5;
	_btnBack2.layer.cornerRadius = 5;
    
    NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"sound_error"
                                              withExtension:@"aiff"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_wrongAudio);
    
    NSURL *soundURL2 = [[NSBundle mainBundle] URLForResource:@"sound_right"
                                               withExtension:@"aiff"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL2, &_rightAudio);
    
	
	if ([Player getPlayerID] == 2) {
		if (_right) {
			self.showWOrR.image = [UIImage imageNamed:@"right-mark"];
			self.showWOrR.hidden = NO;
            AudioServicesPlaySystemSound(_rightAudio);
		}
		else {
			self.showWOrR.image = [UIImage imageNamed:@"wrong-mark"];
			self.showWOrR.hidden = NO;
            AudioServicesPlayAlertSound(_wrongAudio);
		}
	} else {
		self.showWOrR.hidden = YES;
	}
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self.rate setProgress:[Player knowingPercent] animated:YES];
	
	[super viewDidAppear:animated];
	
	if (![self.showWOrR isHidden]) {
		[UIView animateWithDuration:0.1
						 animations:^{
							 self.showWOrR.alpha = 0;
						 }
						 completion:^(BOOL completed){
							 self.showWOrR.hidden = YES;
							 self.showWOrR.alpha = 1;
						 }];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)playWithSame:(id)sender
{
	UIViewController *viewController = self.navigationController.viewControllers[1];
	
	if ([sender isKindOfClass:[UIButton class]]) [_game sendData:@"playAgain" fromViewController:self];
	
	[self.navigationController popToViewController:viewController animated:NO];
}

- (IBAction)playWithOther:(id)sender
{
	if ([sender isKindOfClass:[UIButton class]]) [_game sendData:@"endGame" fromViewController:self];

	[self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark - VerifyAnswerControllerDelegate Delegate

-(void)didShowImage:(BOOL)right
{
	_right = right;
}

- (IBAction)saveScreenShot:(id)sender {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIGraphicsBeginImageContext(screenRect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextFillRect(ctx, screenRect);
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [window.layer renderInContext:ctx];
    UIImage *screengrab = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(screengrab, nil, nil, nil);
}

@end
