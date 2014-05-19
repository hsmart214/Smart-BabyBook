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
    self.label.text = [encounter.baby ageDescriptionAtDate:encounter.universalDate];
}

-(void)awakeFromNib
{
    [self.contentView.layer setCornerRadius:VACCINE_CELL_CORNER_RADIUS];
    [self.contentView.layer setMasksToBounds:YES];
}

@end
