//
//  MyScoresViewController.m
//  DoIKnowYou
//
//  Created by Felipe Eulalio on 16/06/15.
//  Copyright © 2015 Arthur Alvarez. All rights reserved.
//

#import "MyScoresViewController.h"
#import "ScoresCell.h"

@interface MyScoresViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MyScoresViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	TabBarViewController *tabVC = (TabBarViewController*) [self tabBarController];
	
	_game = tabVC.game;
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[_game load:MyScore];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	return _game.scores.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	ScoresCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[ScoresCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	// Configure the cell...
	NSManagedObject *device = [_game.scores objectAtIndex:indexPath.row];
	[cell.name setText:[NSString stringWithFormat:@"%@", [device valueForKey:@"name"]]];
	[cell.score setText:[device valueForKey:@"knowingPercent"]];
	
	return cell;
}

@end
