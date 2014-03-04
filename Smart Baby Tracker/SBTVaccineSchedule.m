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
#define AGE_ALT_TRIGGER_KEY @"doseAgeForAlternateCatchUp"
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


-(SBTVaccinationStatus)baby:(SBTBaby *)baby vaccinationStatusForVaccineComponent:(SBTComponent)component
{
    NSDateComponents *ageComponents = [baby ageAtDate:[NSDate date]];
    NSInteger years = [ageComponents year];
    NSInteger months = [ageComponents month];
    NSInteger days = [ageComponents day];
    
    NSArray *datesGiven = [baby daysGivenVaccineComponent:component];   // these are NSDateComponents * with only DAYS
    NSString *key = [SBTVaccineSchedule keyForVaccineComponent:component];
    
    SBTVaccineDoseStatus currentStatus;
    for (int i = 0; i < [datesGiven count]; i++){
        NSInteger dayGiven = ((NSDateComponents *)datesGiven[i]).day;
        
        NSArray *recDoses = rules[key][REG_SCHED_KEY];
        
        NSInteger minAge = [recDoses[i][MIN_AGE_KEY] integerValue];
        NSInteger lateAge = [recDoses[i][AGE_LATE_KEY] integerValue];
        
        if (dayGiven >= minAge) currentStatus = SBTVaccineDoseOnTime;
        if (dayGiven > lateAge) currentStatus = SBTVaccineDoseLate;
        
        if (i > 0){
            NSDictionary *prevDose = recDoses[i-1];
            NSInteger prevDayGiven = ((NSDateComponents *)datesGiven[i-1]).day;
            NSInteger interval = dayGiven - prevDayGiven;
            if (interval < [prevDose[MIN_INTERVAL_KEY] integerValue]){
                currentStatus = SBTVaccineDoseTooEarly;
            }else if ([prevDose[LIVE_LOCKOUT_KEY] boolValue] && interval < LIVE_LOCKOUT_PERIOD){
                currentStatus = SBTVaccineTooSoonAfterLiveVaccine;
            }
        }
    }
    // TODO: track the overall vaccine component status and return the final determination
    
    return SBTVaccinationUTD;
}

@end
