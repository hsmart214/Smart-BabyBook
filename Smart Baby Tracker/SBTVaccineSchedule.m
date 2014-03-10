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
        case SBTComponentHepB:
            return @"Hep B";
        case SBTComponentPCV13:
        case SBTComponentPCV7:
            return @"PCV";
        default:
            break;
    }
    return nil;
}

-(SBTVaccineDoseStatus)statusOfVaccineComponent:(SBTComponent)component
                             forGivenDoseNumber:(NSInteger)doseNum
                                        forDose:(NSInteger)doseOrd
                                        forBaby:(SBTBaby *)baby
{
    NSArray *datesGiven = [baby daysGivenVaccineComponent:component];
    NSDateComponents *dayGiven = datesGiven[doseNum];
    
    if ([baby dayIsDuringLiveBlackout:dayGiven]) return SBTVaccineDoseTooSoonAfterLiveVaccine;
    
    NSAssert(doseOrd < [datesGiven count], @"Invalid dose number %ld given to status check routine.", (long)doseOrd);
    NSString *key = [SBTVaccineSchedule keyForVaccineComponent:component];
    NSArray *recommendedDoses = rules[key][REG_SCHED_KEY];
    
    NSInteger earliestAllowed = [recommendedDoses[doseOrd][MIN_AGE_KEY] integerValue];
    
    if (doseOrd > 0){
        NSDateComponents *prevDoseDay = datesGiven[doseNum - 1];
        NSInteger minInterval = [recommendedDoses[doseOrd - 1][MIN_INTERVAL_KEY] integerValue];
        earliestAllowed = MAX(earliestAllowed, prevDoseDay.day + minInterval);
    }
    if (dayGiven.day < earliestAllowed) return SBTVaccineDoseTooEarly;
    if (dayGiven.day > [recommendedDoses[doseOrd][AGE_LATE_KEY] integerValue]) return SBTVaccineDoseLate;
    return SBTVaccineDoseValid;
}

// TODO: handle alternate schedules (like DTap - only need 4 if fourth dose > 4 yrs)
-(SBTVaccinationStatus)vaccinationStatusForVaccineComponent:(SBTComponent)component
                                                    forBaby:(SBTBaby *)baby
{    
    NSMutableArray *doseStatuses = [NSMutableArray new];
    NSArray *datesGiven = [baby daysGivenVaccineComponent:component];
    NSInteger doseOrdinal = 0;
    for (int i = 0; i < [datesGiven count]; i++){
        SBTVaccineDoseStatus status = [self statusOfVaccineComponent:component
                                                  forGivenDoseNumber:i
                                                             forDose:doseOrdinal
                                                             forBaby:baby];
        if (status == SBTVaccineDoseValid || status == SBTVaccineDoseLate){
            doseOrdinal++;
        }
        [doseStatuses addObject:@(status)];
    }
    // get the count of valid doses.  It happpens to be equal to doseOrdinal at this point (lucky us)
    // get the recommended number of doses.
    NSString *key = [SBTVaccineSchedule keyForVaccineComponent:component];
    NSArray *recommendedDoses = rules[key][REG_SCHED_KEY];
    NSInteger age = [baby ageDDAtDate:[NSDate date]].day;
    NSInteger recommended = 0;
    while (recommended < [recommendedDoses count] && [recommendedDoses[recommended][REC_AGE_KEY] integerValue] <= age) recommended++;
    // if we are missing any, are we in a lockout, or too soon status right now?
    NSInteger validDoses = [[doseStatuses filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(SELF == %@) OR (SELF == %@)", @(SBTVaccineDoseValid), @(SBTVaccineDoseLate)]] count];
    if (validDoses >= recommended){
        return SBTVaccinationUTD;
    }else{ // has not had the recommended number of doses
        if ([baby dayIsDuringLiveBlackout:[baby ageDDAtDate:[NSDate date]]]) return SBTVaccinationDueLockedOut;
        return SBTVaccinationDue;
    }
}

@end
