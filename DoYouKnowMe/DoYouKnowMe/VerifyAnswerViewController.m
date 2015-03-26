//
//  VerifyAnswerViewController.m
//  DoYouKnowMe
//
//  Created by Arthur Alvarez on 3/25/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "VerifyAnswerViewController.h"

@interface VerifyAnswerViewController ()
///Interface Button where the user Accepts the answer
@property (weak, nonatomic) IBOutlet UIButton *btnAcceptAnswer;

///Interface Button where the user Rejects the answer
@property (weak, nonatomic) IBOutlet UIButton *btnRejectAnswer;


@end

@implementation VerifyAnswerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 This method is called when the user presses btnAcceptAnswer
@author Arthur Alvarez
 */
- (IBAction)acceptAnswer:(id)sender {
    [self performSegueWithIdentifier:@"backToGame" sender:self];
}

/**
 This method is called when the user presses btnRejectAnswer
 @author Arthur Alvarez
 */
- (IBAction)rejectAnswer:(id)sender {
    [self performSegueWithIdentifier:@"backToGame" sender:self];
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
