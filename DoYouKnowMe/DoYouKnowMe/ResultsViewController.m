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

@interface ResultsViewController ()

///Interface label that shows title
@property (weak, nonatomic) IBOutlet UILabel *topLabel;

///Interface label that shows percent
@property (weak, nonatomic) IBOutlet UILabel *percentLabel;

///Interface button
@property (weak, nonatomic) IBOutlet UIButton *btnBack1;

///Interface button
@property (weak, nonatomic) IBOutlet UIButton *btnBack2;

///Delegate for comunications
@property (strong, nonatomic) AppDelegate *appDelegate;

@end

@implementation ResultsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	float knowingPercent;
    
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
	
    if([Player getPlayerID] == 1){
        self.topLabel.text = [NSString stringWithFormat:@"Quanto %@ me conhece...", self.appDelegate.connectedPeer.displayName];
    }
    
    else if([Player getPlayerID] == 2){
        self.topLabel.text = [NSString stringWithFormat:@"Quanto conheço %@...", self.appDelegate.connectedPeer.displayName];
    }
    
    NSLog(@"score final: %d", [Player getScore]);
	
	knowingPercent = (float)[Player getScore]/[GameSettings getGameLength]; // Calculates the percentage of correct answers
    NSLog(@"knowing percent: %f", knowingPercent);
	
	if (knowingPercent < 0.2f) _percentLabel.text = [NSString stringWithFormat:@"%d%%\n\nMuito pouco...", (int)(knowingPercent * 100)];
	else if (knowingPercent < 0.4f) _percentLabel.text = [NSString stringWithFormat:@"%d%%\n\nPouco...", (int)(knowingPercent * 100)];
	else if (knowingPercent < 0.6f) _percentLabel.text = [NSString stringWithFormat:@"%d%%\n\nMais ou menos", (int)(knowingPercent * 100)];
	else if (knowingPercent < 0.8f) _percentLabel.text = [NSString stringWithFormat:@"%d%%\n\nBem!!", (int)(knowingPercent * 100)];
	else _percentLabel.text = [NSString stringWithFormat:@"%d%%\n\nMuito bem!!\nVocês são grandes amigos!!", (int)(knowingPercent * 100)];
	
	_btnBack1.layer.cornerRadius = 5;
	_btnBack2.layer.cornerRadius = 5;
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)playWithSame:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (IBAction)playWithOther:(id)sender {
	[_appDelegate.mcManager.session disconnect];
	
	[self.navigationController popToRootViewControllerAnimated:NO];
}


@end
