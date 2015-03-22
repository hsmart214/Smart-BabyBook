//
//  SBTVaccineGridEntry.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/21/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

@import Foundation;
#import "SBTEncounter.h"
#import "SBTVaccine.h"

@interface SBTVaccineGridEntry : NSObject

@property (nonatomic, strong) SBTVaccine *vaccine;
@property (nonatomic, strong) SBTEncounter *encounter;
@property (nonatomic) SBTComponent component;
@property (nonatomic, readonly) NSInteger ageInDays;

@end
