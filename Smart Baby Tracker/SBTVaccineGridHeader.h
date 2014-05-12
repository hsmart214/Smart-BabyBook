//
//  SBTVaccineGridHeader.h
//  Smart Baby Tracker
//
//  Created by J. Howard Smart on 5/10/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBTVaccineSchedule.h"

@interface SBTVaccineGridHeader : UICollectionReusableView

@property (nonatomic, strong) NSString *componentName;
@property (nonatomic) SBTVaccinationStatus status;

@end
