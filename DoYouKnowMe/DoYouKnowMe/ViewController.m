//
//  ViewController.m
//  DoYouKnowMe
//
//  Created by Arthur Alvarez on 3/24/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "ViewController.h"
#import "Game.h"
#import "ConnectionsViewController.h"
#import "TutorialViewController.h"

@interface ViewController ()
{
    BOOL skipTutorial;
}
/// Interface button in the initial screen. (Screen label: 'Jogar')
@property (weak, nonatomic) IBOutlet UIButton *btn_StartApp;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    skipTutorial = [defaults boolForKey:@"passedTutorial"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"skipTutorial"]){
        UINavigationController *navController = [segue destinationViewController];
        ConnectionsViewController *vc = (ConnectionsViewController *)([navController viewControllers][0]);
        vc.cameFromTutorial = NO;
    }
    else if([segue.identifier isEqualToString:@"showTutorial"]){
        TutorialViewController *vc = [segue destinationViewController];
        vc.cameFromFirstScreen = YES;
    }
}


/**
 Starts the application from the initial view. This method is called when the user presses 'btn_StartButton'.
 @param sender: The object that called the method
 @author Arthur Alvarez
 */
- (IBAction)btnPressed:(id)sender {
    if(skipTutorial) {
        [self performSegueWithIdentifier:@"skipTutorial" sender:self];
    }
    else {
        [self performSegueWithIdentifier:@"showTutorial" sender:self];
    }
    
}


@end
