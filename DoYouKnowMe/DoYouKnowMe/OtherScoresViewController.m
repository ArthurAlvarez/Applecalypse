//
//  OtherSocresViewController.m
//  DoIKnowYou
//
//  Created by Felipe Eulalio on 16/06/15.
//  Copyright © 2015 Arthur Alvarez. All rights reserved.
//

#import "OtherScoresViewController.h"
#import "ScoresCell.h"

@interface OtherScoresViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *logo;

@end

@implementation OtherScoresViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	TabBarViewController *tabVC = (TabBarViewController*) [self tabBarController];
	
	_game = tabVC.game;
	
	_tableView.backgroundColor = self.view.backgroundColor;
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[_game load:OtherScore sortedBy:KnowingPercent];
	[_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)goBack:(id)sender {
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return 1;
}

- (IBAction)changeSort:(UISegmentedControl*)sender {
	
	if (sender.selectedSegmentIndex == 0) [_game load:OtherScore sortedBy:KnowingPercent];
	else if (sender.selectedSegmentIndex == 1) [_game load:OtherScore sortedBy:Date];
	else [_game load:OtherScore sortedBy:Name];
	
	[_tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger size = _game.scores.count;
	BOOL hide = size == 0;
	
	tableView.hidden = hide;
	_logo.hidden = !hide;
	
	return size;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Other";
	
	ScoresCell *cell = (ScoresCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[ScoresCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	// Configure the cell...
	NSManagedObject *device = [_game.scores objectAtIndex:indexPath.row];
	cell.name.text = [device valueForKey:@"name"];
	float score = [[device valueForKey:@"knowingPercent"] floatValue];
	cell.score.text = [NSString stringWithFormat:@"%.0f%%", score * 100];
	cell.backgroundColor = self.view.backgroundColor;
	cell.contentView.backgroundColor = self.view.backgroundColor;
	
	return cell;
}
@end
