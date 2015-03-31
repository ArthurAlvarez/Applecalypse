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
@property (weak, nonatomic) IBOutlet UIButton *btn_back;

///Delegate for comunications
@property (strong, nonatomic) AppDelegate *appDelegate;
@end

@implementation ResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    MCPeerID *id;
    
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    id = _appDelegate.mcManager.session.connectedPeers[0];
    self.topLabel.text = [NSString stringWithFormat:@"Quanto %@ me conhece...", id.displayName];
    NSLog(@"score final: %d", [Player getScore]);
    self.percentLabel.text = [NSString stringWithFormat:@"%d%%", (100*[Player getScore])/[GameSettings getGameLength]];
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
