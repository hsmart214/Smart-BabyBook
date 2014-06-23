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
    _encounter = encounter;
    if (encounter){
        self.label.text = [encounter.baby ageDescriptionAtDate:encounter.universalDate];
    }else{
        self.label.text = NSLocalizedString(@"Due now", @"Due now");
        self.statusImageView.image = [UIImage imageNamed:@"vaccine"];
    }
}

-(void)setStatus:(SBTVaccineDoseStatus)status
{
    _status = status;
    switch (status) {
        case SBTVaccineDoseInvalidTooEarly:
        case SBTVaccineDoseInvalidTooSoonAfterLiveVaccine:
            self.statusImageView.image = [UIImage imageNamed:@"redX"];
            break;
        case SBTVaccineDoseValid:
            self.statusImageView.image = [UIImage imageNamed:@"greenCheck"];
            break;
        case SBTVaccineDoseValidLate:
            self.statusImageView.image = [UIImage imageNamed:@"yellowCheck"];
            break;
        default:
            break;
    }
}

-(void)awakeFromNib
{
    [self.contentView.layer setCornerRadius:VACCINE_CELL_CORNER_RADIUS];
    [self.contentView.layer setMasksToBounds:YES];
}

@end
