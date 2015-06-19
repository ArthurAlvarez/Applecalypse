//
//  FirstViewController.m
//  DoYouKnowMe
//
//  Created by Felipe Eulálio on 31/03/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "ConnectionsViewController.h"
#import "TutorialViewController.h"
#import "TabBarViewController.h"
#import "AppDelegate.h"
#import "Player.h"

#pragma mark - Private Interface

@interface ConnectionsViewController ()
{
	/// Flag to know when the game can go to the next View
	int canGoNext;
    NSString *lastNick;
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

/// Interface Activity Indicator to show that the player is waiting the other
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *waitingGoNext;

/// Table view to display the connected devices
@property (weak, nonatomic) IBOutlet UITableView *connectedDevices;

/// Button to present the tutorial
@property (weak, nonatomic) IBOutlet UIButton *presentTutorial;

@property (weak, nonatomic) IBOutlet UIButton *scoreButton;

@end

#pragma mark - Implementation

@implementation ConnectionsViewController

#pragma mark - Life Cycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
												 name:@"changeState"
											   object:nil];
	
	_game = [[Game alloc] initWithSender:self];
	
	// Set Tex Field delegate
	[_txtName setDelegate:self];
	
	// Hide buttons and labels
	_browseBtn.hidden = YES;
	_connectedDevices.hidden = YES;
	
	_connectedDevices.backgroundColor = [UIColor clearColor];
	
	_presentTutorial.layer.cornerRadius = _presentTutorial.frame.size.height/2;
	_presentTutorial.layer.borderWidth = 1;
	_presentTutorial.layer.borderColor = [UIColor whiteColor].CGColor;

	_browseBtn.layer.cornerRadius = 5;
	
	_acceptInviteView.type = 1;
    _alertInviteView.type = 3;
    
    lastNick = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	canGoNext = 0;
	
	_connecting = NO;
    
    _connected = NO;
	
	_scoreButton.enabled = YES;
	_browseBtn.enabled = YES;
	
	[_acceptInviteView hide];
	
	[_waitingGoNext stopAnimating];

	if ([self.txtName.text length] > 0) [_game initiateBrowsing];
	
	self.connectedDevices.allowsSelection = YES;

	[self reloadData];
}

#pragma mark - Action Methods

/**
 Go back to the first view 
 */
- (IBAction)goBack:(id)sender
{
	[_game finishSession];
	
    NSLog(@"%d", self.cameFromTutorial);
	
    if (self.cameFromTutorial) [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    else [self dismissViewControllerAnimated:YES completion:nil];
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
	canGoNext = 0;
    self.connecting = NO;
    self.connected = NO;
	
	[_game initiateSession:_txtName.text];
		
	[self reloadData];
}

#pragma mark - Selectors

/**
 Method to when the device change the state of the connection
 **/
-(void)peerDidChangeStateWithNotification:(NSNotification *)notification
{
	BOOL peersExist = ([_game.connectedDevices count] == 0);
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *status = [[notification userInfo] objectForKey:@"status"];
    
	dispatch_async(dispatch_get_main_queue(),
	^{
		if (!peersExist) {
			if (canGoNext == 0) _connectedDevices.allowsSelection = YES;
		} else {
			[_waitingGoNext stopAnimating];
		}
		
        if([status isEqualToString:@"connected"]){
            [_game sendData:@"getNick" fromViewController:self toPeer:peerID.displayName];
        }
        else{
            [self reloadData];
        }
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
    else {
        [self performSegueWithIdentifier:@"goNext" sender:self];
        _connected = YES;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	UIViewController *vc = segue.destinationViewController;
    self.connected = YES;
    
	if ([vc isKindOfClass:[SettingsViewController class]]) {
		((SettingsViewController*) vc).game = _game;
	}
    else if([vc isKindOfClass:[TutorialViewController class]]){
        ((TutorialViewController *) vc).cameFromFirstScreen = NO;
	} else if ([vc isKindOfClass:[TabBarViewController class]]){
		((TabBarViewController*) vc).game = _game;
	}
}

#pragma mark - Conectivity Methods
/*
    Connects to other peer to play togheter
 */
-(void) connectToPlayer:(NSString *)playerName {
    for (OnlinePeer *peer in _game.connectedDevices) {
        if ([peer.peerID.displayName isEqualToString:playerName]) {
            _game.otherPlayer = peer;
            NSLog(@"connected to %@", playerName);
        }
    }
}

/*
    Reloads list of connected peers and displays in a list view
 */

- (void) reloadData
{
	[_connectedDevices reloadData];
	
	self.connectedDevices.allowsSelection = YES;
}

/*
 Shows game invitations
 */
-(void) showInviteFrom:(MCPeerID *)peer{
    for(OnlinePeer *p in _game.connectedDevices){
        if(p.peerID == peer){
            
            self.acceptInviteView.peerName = p.nickName;
            [self.acceptInviteView show];
            break;
        }
    }
}

/*
    Accepts invitation to play togheter
 */

-(void) acceptInvitation {
    [_game pauseBrowsing];
    [_game sendData:@"acceptedNext" fromViewController:self to:ConnectedPeer];
    NSLog(@"accepted invitation");
}

/*
    When other user rejects invitation
 */
-(void) rejectedInvitationWith:(RejectCause)cause {
    canGoNext = 0;
    [_waitingGoNext stopAnimating];
    _game.otherPlayer = nil;
    [_game initiateBrowsing];
	self.connecting = NO;
    self.connectedDevices.allowsSelection = YES;
    
    if(cause == REJECT){
        _alertInviteView.messageTag = @"rejectCause1";
        _alertInviteView.leftButtonTag = @"ok";
        
        [_alertInviteView show];
    }
    
    else if(cause == BUSY){
        _alertInviteView.messageTag = @"rejectCause2";
        _alertInviteView.leftButtonTag = @"ok";
        
        [_alertInviteView show];
    }
    
    else if(cause == INGAME){
        _alertInviteView.messageTag = @"rejectCause3";
        _alertInviteView.leftButtonTag = @"ok";
        
        [_alertInviteView show];
    }

	_scoreButton.enabled = YES;
	_browseBtn.enabled = YES;
}

/*
    Rejects invitation from others
 */

-(void) sendRejectTo:(NSString*)peerName {
    [_game sendData:@"rejected" fromViewController:self toPeer:peerName];
}

/*
    Rejects invitation from connected peer
 */
-(void) sendReject{
	[_game sendData:@"rejected" fromViewController:self to:ConnectedPeer];
}

/*
    Tells other users that the device is currently connecting to someone
 */
-(void) sendBusyTo:(NSString*)peerName{
    [_game sendData:@"busy" fromViewController:self toPeer:peerName];
}

/*
    Tells other users that the device is already in a game session
 */
-(void) sendInGameTo:(NSString*)peerName{
    [_game sendData:@"busy2" fromViewController:self toPeer:peerName];
}

/*
    Handles changes of nicknames
 */
-(void) ChangePeer:(MCPeerID *)Peer NicknameTo:(NSString *)Nickname{
    for (OnlinePeer *p in _game.connectedDevices) {
        if(p.peerID == Peer){
            p.nickName = Nickname;
            break;
        }
    }
    
    if(_game.otherPlayer.peerID == Peer)
        _game.otherPlayer.nickName = Nickname;
    
    [self reloadData];
}

/*
    Sends current nickname to other peer
 */
-(void) sendNickToPeer:(MCPeerID *)peer{
    [_game sendData:[NSString stringWithFormat:@"$#@%@", _txtName.text] fromViewController:self toPeer:peer.displayName];
}

/*
    Updates nickname from other peer
 */
-(void) gotNick:(NSString*)nick FromPeer:(MCPeerID *)peer{
    for(OnlinePeer *p in _game.connectedDevices){
        if(p.peerID == peer){
            p.nickName = nick;
            break;
        }
    }
    
    [self reloadData];
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
        
        if(lastNick == nil){
            [self.game initiateSession:textField.text];
            lastNick = textField.text;
        }
                //Mudança de nick
        else
            if(![textField.text isEqualToString:lastNick]){
                NSLog(@"Change nick");
                [_game sendData:[NSString stringWithFormat:@"newNick%@", textField.text] fromViewController:self to:AllPeers];
            }
		_browseBtn.hidden = NO;
		
    } else{
        [self performShakeAnimation:_txtName];
        
        if(lastNick != nil){
            textField.text = lastNick;
            [_txtName resignFirstResponder];
        }
    }
    
	return YES;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	for (OnlinePeer *peer in _game.connectedDevices) {
		if ([peer.nickName isEqualToString:[tableView cellForRowAtIndexPath:indexPath].textLabel.text]) {
			_game.otherPlayer = peer;
		}
	}
	
	_scoreButton.enabled = NO;
	_browseBtn.enabled = NO;
	
	self.connecting = YES;
	
	[self canGoNext];
	
	[_waitingGoNext startAnimating];
	
	[_game pauseBrowsing];
	
	self.connectedDevices.allowsSelection = NO;
	
	[_game sendData:[NSString stringWithFormat:@"goNext%@", _game.appDelegate.mcManager.session.myPeerID.displayName] fromViewController:self to:ConnectedPeer];
}

#pragma mark - AuxiliaryMenuView Delegate

-(void)leftButtonAction
{
    if(_acceptInviteView.hidden == NO){
        [self sendReject];
        [self rejectedInvitationWith:MYSELF];
        [_acceptInviteView hide];
    }
    
    else if(_alertInviteView.hidden == NO){
        [_alertInviteView hide];
    }
}

-(void)rightButtonAction
{
	[self acceptInvitation];
	[self canGoNext];
	[_acceptInviteView hide];
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
	
	cell.backgroundColor = self.view.backgroundColor;
	
	cell.textLabel.font = self.helloLabel.font;
	cell.textLabel.textColor = self.helloLabel.textColor;
	cell.textLabel.text = ((OnlinePeer*)[_game.connectedDevices objectAtIndex:indexPath.row]).nickName;
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

@end
