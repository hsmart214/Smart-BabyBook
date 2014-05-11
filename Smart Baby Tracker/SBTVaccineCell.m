//
//  SBTVaccineCell.m
//  Smart Baby Tracker
//
//  Created by J. Howard Smart on 5/10/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTVaccineCell.h"
#import "SBTEncounter.h"
#import "SBTBaby.h"

@interface SBTVaccineCell()

@property (weak, nonatomic) IBOutlet UILabel *label;


@end

@implementation SBTVaccineCell

-(void)setEncounter:(SBTEncounter *)encounter
{
    self.label.text = [encounter.baby ageDescriptionAtDate:encounter.universalDate];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
