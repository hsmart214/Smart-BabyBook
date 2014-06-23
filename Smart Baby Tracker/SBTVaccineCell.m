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

#define VACCINE_CELL_CORNER_RADIUS 6.0

@interface SBTVaccineCell()

@property (weak, nonatomic) IBOutlet UILabel *label;


@end

@implementation SBTVaccineCell

-(void)setEncounter:(SBTEncounter *)encounter
{
    if (encounter){
        self.label.text = [encounter.baby ageDescriptionAtDate:encounter.universalDate];
        self.statusImageView.image = [UIImage imageNamed:@"greenCheck"];
    }else{
        self.label.text = NSLocalizedString(@"Due now", @"Due now");
        self.statusImageView.image = [UIImage imageNamed:@"vaccine"];
    }
}

-(void)awakeFromNib
{
    [self.contentView.layer setCornerRadius:VACCINE_CELL_CORNER_RADIUS];
    [self.contentView.layer setMasksToBounds:YES];
}

@end
