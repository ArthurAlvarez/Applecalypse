//
//  FirstViewController.m
//  DoYouKnowMe
//
//  Created by Felipe Eulálio on 31/03/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "ConnectionsViewController.h"
#import "TutorialViewController.h"
#import "AppDelegate.h"
#import "Player.h"

#pragma mark - Private Interface

@interface ConnectionsViewController ()
{
	/// Flag to know when the game can go to the next View
	int canGoNext;
}

#pragma mark - Interface Properties
/// Interface Text Field to edit the display name from the device
@property (weak, nonatomic) IBOutlet UITextField *txtName;

/// Label to say hello to the player
@property (weak, nonatomic) IBOutlet UILabel *helloLabel;

/// Label to ask the player's name
@property (weak, nonatomic) IBOutlet UILabel *askNameLabel;

/// Interface Button to look for another device
@property (weak, nonatomic) IBOutlet UIButton *browseBtn;

/// Interface Button to disconect with the other device
@property (weak, nonatomic) IBOutlet UIButton *disconectBtn;

/// Interface Activity Indicator to show that the player is waiting the other
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *waitingGoNext;

/// Table view to display the connected devices
@property (weak, nonatomic) IBOutlet UITableView *connectedDevices;

@end

#pragma mark - Implementation

@implementation ConnectionsViewController

#pragma mark - Life Cycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(peerDidChangeStateWithNotification)
												 name:@"changeState"
											   object:nil];
	
	_game = [[Game alloc] initWithSender:self];
	
	// Set Tex Field delegate
	[_txtName setDelegate:self];
	
	// Hide buttons and labels
	_browseBtn.hidden = YES;
	_disconectBtn.hidden = YES;
	_connectedDevices.hidden = YES;

	_browseBtn.layer.cornerRadius = 5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	canGoNext = 0;
	[_waitingGoNext stopAnimating];
	
	
	if ([_game.connectedDevices count] == 0) {
		self.connectedDevices.hidden = true;
	}

	if ([self.txtName.text length] > 0) [_game initiateBrowsing];
	
	self.connectedDevices.allowsSelection = YES;

	[self.connectedDevices reloadData];
}

#pragma mark - Action Methods

/**
 Go back to the first view 
 */
- (IBAction)goBack:(id)sender
{
	[_game finishSession];
    NSLog(@"%d", self.cameFromTutorial);
    if(self.cameFromTutorial){
        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
/**
 Go to tutorial page
 */
- (IBAction)goToTutorial:(id)sender {
    [self performSegueWithIdentifier:@"seeTutorial" sender:self];
}

/**
 Method to browse for new devices
 **/
- (IBAction)browseForDevices:(id)sender
{
	[_game initiateBrowsing];
}

/**
 Method to disconnect with the other device
 **/
- (IBAction)Disconect:(id)sender
{
	[_game finishSession];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		_disconectBtn.hidden = YES;
	});
	
	[_waitingGoNext stopAnimating];
	
	canGoNext = 0;
	
	[self.connectedDevices reloadData];
}

#pragma mark - Selectors

/**
 Method to when the device change the state of the connection
 **/
-(void)peerDidChangeStateWithNotification
{
	BOOL peersExist = ([_game.connectedDevices count] == 0);
	[_txtName setEnabled:peersExist];
	
	dispatch_async(dispatch_get_main_queue(),
	^{
		if (!peersExist) {
			[_browseBtn setEnabled:NO];
			_disconectBtn.hidden = NO;
			if (canGoNext == 0) _connectedDevices.allowsSelection = YES;
		} else {
			[_browseBtn setEnabled:YES];
			_disconectBtn.hidden = YES;
			[_waitingGoNext stopAnimating];
		}
		
		[self.connectedDevices reloadData];
	});
}

#pragma mark - Auxiliary Methods

/**
 Perform a shake animation at the textfield when it is empty
 */
- (void) performShakeAnimation:(UIView *)object {
	
	CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
	
	[shake setDuration:0.1];
	[shake setRepeatCount:2];
	[shake setAutoreverses:YES];
	
	[shake setFromValue:[NSValue valueWithCGPoint: CGPointMake(object.center.x - 5, object.center.y)]];
	
	[shake setToValue:[NSValue valueWithCGPoint: CGPointMake(object.center.x + 5, object.center.y)]];
	
	[object.layer addAnimation:shake forKey:@"position"];
}

/**
 Method to the device receive some data
 **/
- (void) canGoNext
{
    NSLog(@"Can go next");
	if (canGoNext == 0) canGoNext = 1;
	else [self performSegueWithIdentifier:@"goNext" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	UIViewController *vc = segue.destinationViewController;
	
	if ([vc isKindOfClass:[SettingsViewController class]]) {
		((SettingsViewController*) vc).game = _game;
	}
    else if([vc isKindOfClass:[TutorialViewController class]]){
        ((TutorialViewController *) vc).cameFromFirstScreen = NO;
    }
}

-(void) connectToPlayer:(NSString *)playerName{
    for (MCPeerID *peer in _game.connectedDevices) {
        if ([peer.displayName isEqualToString:playerName]) {
            _game.otherPlayer = peer;
            NSLog(@"connected to %@", playerName);
        }
    }
}

-(void) acceptInvitation{
    [_game pauseBrowsing];
    [_game sendData:@"acceptedNext" fromViewController:self];
    NSLog(@"accepted invitation");
}

-(void) rejectedInvitation{
    canGoNext = 0;
    [_waitingGoNext stopAnimating];
    _game.otherPlayer = nil;
    [_game initiateBrowsing];
    self.connectedDevices.allowsSelection = YES;
    
}

-(void) sendReject{
    [_game sendData:@"rejected" fromViewController:self];
}

#pragma mark - Delegates
#pragma mark - Text Field Delegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if ([textField.text length] > 0) {
		
		[_txtName resignFirstResponder];
		
		[self.game initiateSession:textField.text];
		
		_browseBtn.hidden = NO;
		
	} else [self performShakeAnimation:_txtName];
	
	return YES;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	for (MCPeerID *peer in _game.connectedDevices) {
		if ([peer.displayName isEqualToString:[tableView cellForRowAtIndexPath:indexPath].textLabel.text]) {
			_game.otherPlayer = peer;
		}
	}
	
	[self canGoNext];
	
	[_waitingGoNext startAnimating];
	
	[_game pauseBrowsing];
	
	self.connectedDevices.allowsSelection = NO;
	
	[_game sendData:[NSString stringWithFormat:@"goNext%@", _game.appDelegate.mcManager.session.myPeerID.displayName] fromViewController:self];
}


#pragma mark - Datasources
#pragma mark - TableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger size = [_game.connectedDevices count];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		
		if (size == 0) tableView.hidden = true;
		else tableView.hidden = false;
		
	});
	
	return size;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	cell.backgroundColor = tableView.backgroundColor;
	
	cell.textLabel.font = self.helloLabel.font;
	cell.textLabel.textColor = self.helloLabel.textColor;
	cell.textLabel.text = ((MCPeerID*)[_game.connectedDevices objectAtIndex:indexPath.row]).displayName;
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

@end
