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

#define VACCINE_SCHEDULE_FILENAME @"ACIP Schedule"

#define REG_SCHED_KEY @"Customary"
#define MIN_AGE_KEY @"doseMinimumAge"
#define MIN_INTERVAL_KEY @"doseMinimumInterval"
#define REC_AGE_KEY @"doseRecommendedAge"
#define REC_AGE_UPPER_KEY @"doseRecommendedAgeUpperLimit"
#define REC_INTERVAL_KEY @"doseRecommendedInterval"
#define AGE_LATE_KEY @"doseAgeFlagLate"
#define LIVE_LOCKOUT_KEY @"doseCausesLiveLockout"

#define LIVE_LOCKOUT_PERIOD 28


@interface SBTVaccineSchedule()

{
    NSDictionary *rules;
}

@end;

@implementation SBTVaccineSchedule

+(SBTVaccineSchedule *)sharedSchedule
{
    static SBTVaccineSchedule *vs = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!vs){
            vs = [[SBTVaccineSchedule alloc] init];
            NSURL *fileURL = [[NSBundle mainBundle] URLForResource:VACCINE_SCHEDULE_FILENAME withExtension:@"plist"];
            vs->rules = [NSDictionary dictionaryWithContentsOfURL:fileURL];
        }
    });
    return vs;
}

+(NSString *)keyForVaccineComponent:(SBTComponent)vaccineComponent
{
    switch (vaccineComponent) {
        case SBTComponentDTaP:
            return @"DTaP";
        case SBTComponentMMR:
            return @"MMR";
        default:
            break;
    }
    return nil;
}

-(SBTVaccineDoseStatus)statusOfVaccineComponent:(SBTComponent)component forDose:(NSInteger)dose forBaby:(SBTBaby *)baby
{
    NSInteger vaccineOrdinal = 0;   // we will use this to keep track of which dose we are dealing with
    SBTVaccineDoseStatus status = SBTVaccineDoseValid;
    NSArray *datesGiven = [baby daysGivenVaccineComponent:component];
    NSAssert(dose < [datesGiven count], @"Invalid dose number %ld given to status check routine.", (long)dose);
    NSString *key = [SBTVaccineSchedule keyForVaccineComponent:component];
    NSArray *recommendedDoses = rules[key][REG_SCHED_KEY];
    NSInteger earliestValidDay = [[recommendedDoses firstObject][MIN_AGE_KEY] integerValue];
    
    for (NSInteger i = 0; i <= dose; i++){
        NSDateComponents *comps = datesGiven[i];
        
        if (comps.day < earliestValidDay  || [baby dayIsDuringLiveBlackout:comps]){
            if (dose == vaccineOrdinal){
                if ([baby dayIsDuringLiveBlackout:comps]) status = SBTVaccineDoseTooSoonAfterLiveVaccine;
                if (comps.day < earliestValidDay) status = SBTVaccineDoseTooEarly;
                break;
            }
            continue;     // the dose was too early, skip it like it never happened
        }
        if (vaccineOrdinal == dose){
            if ([datesGiven[dose] integerValue] < [recommendedDoses[dose][AGE_LATE_KEY] integerValue]){
                status = SBTVaccineDoseValid;
            }else{
                status = SBTVaccineDoseLate;
            }
            break;
        }else{
            earliestValidDay = comps.day + [recommendedDoses[vaccineOrdinal++][MIN_INTERVAL_KEY] integerValue];
        }
    }
    return status;
}


-(SBTVaccinationStatus)baby:(SBTBaby *)baby vaccinationStatusForVaccineComponent:(SBTComponent)component
{    
    NSMutableArray *doseStatuses = [NSMutableArray new];
    NSArray *datesGiven = [baby daysGivenVaccineComponent:component];
    NSInteger doseOrdinal = 0;
    for (int i = 0; i < [datesGiven count]; i++){
        SBTVaccineDoseStatus status = [self statusOfVaccineComponent:component forDose:doseOrdinal forBaby:baby];
        if (status != SBTVaccineDoseTooEarly && status != SBTVaccineDoseTooSoonAfterLiveVaccine){
            doseOrdinal++;
        }
        [doseStatuses addObject:@(status)];
    }
    // get the count of valid doses.  It happpens to be equal to doseOrdinal at this point (lucky us)
    // get the recommended number of doses.
    NSString *key = [SBTVaccineSchedule keyForVaccineComponent:component];
    NSArray *recommendedDoses = rules[key][REG_SCHED_KEY];
    NSInteger age = [baby ageDDAtDate:[NSDate date]].day;
    NSInteger i = 0;
    while (i < [recommendedDoses count] && [recommendedDoses[i++][REC_AGE_KEY] integerValue] < age);
    // if we are missing any, are we in a lockout, or too soon status right now?
    NSInteger validDoses = [[doseStatuses filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(SELF == %@) OR (SELF == %@)", @(SBTVaccineDoseValid), @(SBTVaccineDoseLate)]] count];
    if (i >= validDoses){
        return SBTVaccinationUTD;
    }else{
        if ([baby dayIsDuringLiveBlackout:[baby ageDDAtDate:[NSDate date]]]) return SBTVaccinationDueLockedOut;
        return SBTVaccinationDue;
    }
}

@end
