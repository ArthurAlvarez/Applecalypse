//
//  TabBarViewController.m
//  DoIKnowYou
//
//  Created by Felipe Eulalio on 16/06/15.
//  Copyright © 2015 Arthur Alvarez. All rights reserved.
//

#import "TabBarViewController.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	[[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }
											 forState:UIControlStateNormal];
	[[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithHue:12/360
																									 saturation:0.51
																									 brightness:1.0
																										  alpha:1.0] }
											 forState:UIControlStateSelected];
	
	UITabBarItem *targetTabBarItem = [[self.tabBar items] objectAtIndex:0]; // whichever tab-item
	UIImage *selectedIcon = [UIImage imageNamed:@"self_selected.png"];
	[targetTabBarItem setSelectedImage:selectedIcon];
	
	targetTabBarItem = [[self.tabBar items] objectAtIndex:1];
	selectedIcon = [UIImage imageNamed:@"friends_selected.png"];
	[targetTabBarItem setSelectedImage:selectedIcon];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
