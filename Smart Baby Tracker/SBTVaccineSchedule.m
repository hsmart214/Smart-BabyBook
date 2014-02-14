//
//  SBTVaccineSchedule.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 1/26/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTVaccineSchedule.h"
#import "SBTBaby.h"
#import "SBTVaccine.h"

#define EARLIEST_ONE_YEAR_DAY 361

@implementation SBTVaccineSchedule

+(SBTVaccineSchedule *)sharedSchedule
{
    static SBTVaccineSchedule *vs = nil;
    if (!vs){
        vs = [[SBTVaccineSchedule alloc] init];
    }
    return vs;
}


-(SBTVaccinationStatus)baby:(SBTBaby *)baby vaccinationStatusForVaccineComponent:(SBTComponent)component
{
    NSDateComponents *ageComponents = [baby ageAtDate:[NSDate date]];
    NSInteger years = [ageComponents year];
    NSInteger months = [ageComponents month];
    NSInteger days = [ageComponents day];
    
    switch (component) {
        case SBTComponentMMR:
        {
            NSArray *adminDays = [baby daysGivenVaccineComponent:component];
            NSDateComponents *dateComps = [adminDays firstObject];
            NSInteger numDoses = [adminDays count];
            if (years == 0){
                if (numDoses){
                    if (((NSDateComponents *)adminDays[0]).day >= EARLIEST_ONE_YEAR_DAY){
                        return SBTVaccineUpToDate;
                    }else{
                        return SBTVaccineDoneTooEarly;
                    }
                }else{ // under one year and no dose given
                    return SBTVaccineUpToDate;
                }
            }else if(years < 4){ // after first but before fourth birthday
                if (numDoses == 0) return SBTVaccineDoseMissing;
                if (numDoses == 1){
                    NSDateComponents *doseDateComp = (NSDateComponents *)adminDays[0];
                    if (doseDateComp.year >= 1 || doseDateComp.day >= EARLIEST_ONE_YEAR_DAY){
                        return SBTVaccineUpToDate;
                    }else{
                        return SBTVaccineDoneTooEarly;
                    }
                }else if(numDoses >= 2){
                    NSDateComponents *doseDateComp = (NSDateComponents *)[adminDays lastObject];
                    if (doseDateComp.year >= 1 || doseDateComp.day >= EARLIEST_ONE_YEAR_DAY){
                        return SBTVaccineUpToDate;
                    }else{
                        return SBTVaccineDoneTooEarly;
                    }
                }
            }

            
            break;
        }
        default:
            break;
    }
    return NO;
}

@end
