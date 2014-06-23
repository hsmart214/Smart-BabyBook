//
//  SBTVaccineCell.h
//  Smart Baby Tracker
//
//  Created by J. Howard Smart on 5/10/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

@import UIKit;
#import "SBTVaccineSchedule.h"

@class SBTEncounter;

@interface SBTVaccineCell : UICollectionViewCell

@property (nonatomic, weak) SBTEncounter *encounter;
@property (nonatomic) SBTVaccineDoseStatus status;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;

@end
