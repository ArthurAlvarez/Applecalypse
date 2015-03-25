//
//  GameViewController.m
//  DoYouKnowMe
//
//  Created by Arthur Alvarez on 3/25/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController ()

# pragma mark - Interface Properties
///Interface label that shows the time left for answering the game question
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

///Interface label that shows the current game question
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;

///Interface TextField where the user inputs the answer to the game question
@property (weak, nonatomic) IBOutlet UITextField *answerTextField;

///Interface Button that the user presses to submit the answer
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

#pragma mark - Controller Properties
///Number that represents the score of the current player
@property (strong, nonatomic) NSNumber *playerScore;
@end

#pragma mark - Controller Implementation
@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Initializing properties
    self.playerScore = [NSNumber numberWithInt:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
