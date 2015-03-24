//
//  ConnectionsViewController.m
//  DoYouKnowMe
//
//  Created by Felipe Eulalio on 24/03/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "ConnectionsViewController.h"
#import "AppDelegate.h"

#pragma mark - Private Interface

@interface ConnectionsViewController ()

@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UISwitch *swVisible;
@property (weak, nonatomic) IBOutlet UITableView *tblConnectedDevices;
@property (weak, nonatomic) IBOutlet UITableView *btnDisconnect;
@property (nonatomic, strong) AppDelegate *appDelegate;

@end

#pragma mark - Implementation

@implementation ConnectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	_appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[[_appDelegate mcManager] setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
	[[_appDelegate mcManager] advertiseSelf:_swVisible.isOn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Methods

- (IBAction)browseForDevices:(id)sender
{
	[[_appDelegate mcManager] setupMCBrowser];
	[[[_appDelegate mcManager] browser] setDelegate:self];
	[self presentViewController:[[_appDelegate mcManager] browser] animated:YES completion:nil];
}

- (IBAction)toggleVisibility:(id)sender
{
	
}

- (IBAction)disconnect:(id)sender
{
	
}

#pragma mark - MCBrowserViewController Delegate

-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
	[_appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
}


-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
	[_appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
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
