//
//  ScoresCell.m
//  DoIKnowYou
//
//  Created by Felipe Eulalio on 17/06/15.
//  Copyright © 2015 Arthur Alvarez. All rights reserved.
//

#import "ScoresCell.h"

@implementation ScoresCell

@synthesize name = _name;
@synthesize score = _score;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
