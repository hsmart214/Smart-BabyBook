//
//  SBTVaccineGridEntry.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/21/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

#import "SBTVaccineGridEntry.h"

@implementation SBTVaccineGridEntry

-(NSInteger)ageInDays{
    return [self.encounter ageInDays];
}

@end
