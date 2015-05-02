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

	MCPeerID *id;
	float knowingPercent;
    
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    id = _appDelegate.mcManager.session.connectedPeers[0];
    
    if([Player getPlayerID] == 1){
        self.topLabel.text = [NSString stringWithFormat:@"Quanto %@ me conhece...", id.displayName];
    }
    
    else if([Player getPlayerID] == 2){
        self.topLabel.text = [NSString stringWithFormat:@"Quanto conheço %@...", id.displayName];
    }
    
    NSLog(@"score final: %d", [Player getScore]);
	
	knowingPercent = (float)[Player getScore]/[GameSettings getGameLength]; // Calculates the percentage of correct answers
    NSLog(@"knowing percent: %f", knowingPercent);
	
	if (knowingPercent <= 0.2f) _percentLabel.text = @"Muito pouco...";
	else if (knowingPercent <= 0.4f) _percentLabel.text = @"Pouco...";
	else if (knowingPercent <= 0.6f) _percentLabel.text = @"Mais ou menos";
	else if (knowingPercent <= 0.8f) _percentLabel.text = @"Bem!!";
	else _percentLabel.text = @"Muito bem!!\nVocês são grandes amigos!!";
	
	_btnBack1.layer.cornerRadius = 5;
	_btnBack2.layer.cornerRadius = 5;
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:NO];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
