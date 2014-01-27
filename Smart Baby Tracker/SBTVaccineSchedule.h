//
//  SBTVaccineSchedule.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 1/26/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

@import Foundation;
@class SBTBaby;
@class SBTVaccine;

@interface SBTVaccineSchedule : NSObject

-(BOOL)baby:(SBTBaby *)baby isUTDforVaccineComponent:(SBTComponent)component;

+(SBTVaccineSchedule *)sharedSchedule;

@end
