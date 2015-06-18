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
	[[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithHue:7/360 saturation:0.66 brightness:0.98 alpha:1.0] }
											 forState:UIControlStateSelected];
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
