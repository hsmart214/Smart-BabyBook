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

//#define REG_SCHED_KEY @"Customary"
#define MIN_AGE_KEY @"doseMinimumAge"
#define MIN_INTERVAL_KEY @"doseMinimumInterval"
#define REC_AGE_KEY @"doseRecommendedAge"
#define REC_AGE_UPPER_KEY @"doseRecommendedAgeUpperLimit"
#define REC_INTERVAL_KEY @"doseRecommendedInterval"
#define AGE_LATE_KEY @"doseAgeFlagLate"

/*
 My convention for the rules:
 Top level NSDictionary with NSString keys such as "DTaP"
 Each value is a NSArray of valid dose series, in most cases only one series is valid, in some there are many
 By this convention the LAST series in the NSArray is the conventional dose series
 Each dose series is also an NSArray of dose information dictionaries
 Each dose dictionary has keys listed above, whose values are NSNumber objects wrapping integer values of ages in DAYS.
 */

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
        case SBTComponentDTP:
        case SBTComponentDTwP:
            return @"DTaP";
        case SBTComponentMMR:
            return @"MMR";
        case SBTComponentHepB:
            return @"Hep B";
        case SBTComponentPCV13:
        case SBTComponentPCV7:
            return @"PCV";
        case SBTComponentVZV:
            return @"VZV";
        case SBTComponentHiB:
        case SBTComponentPRP_OMP:
        case SBTComponentPRP_T:
            return @"HiB";
        case SBTComponentHepA:
            return @"Hep A";
        case SBTComponentHPV2:
        case SBTComponentHPV4:
            return @"HPV";
        case SBTComponentRota:
            return @"Rota";
        case SBTComponentIPV:
        case SBTComponentOPV:
            return @"IPV";
        case SBTComponentMCV4:
            return @"MCV";
        case SBTComponentTdap:
            return @"Tdap";
        default:
            break;
    }
    return nil;
}

+(NSArray *)recommendedVaccines
{
    return  @[
              @(SBTComponentDTaP),
              @(SBTComponentMMR),
              @(SBTComponentHepB),
              @(SBTComponentPCV13),
              @(SBTComponentVZV),
              @(SBTComponentHiB),
              @(SBTComponentHepA),
              @(SBTComponentHPV4),
              @(SBTComponentRota),
              @(SBTComponentIPV),
              @(SBTComponentMCV4),
              @(SBTComponentTdap),
              ];
}

-(SBTVaccineDoseStatus)statusOfVaccineComponent:(SBTComponent)component
                             forGivenDoseNumber:(NSInteger)doseNum
                                        forDose:(NSInteger)doseOrd
                                        forBaby:(SBTBaby *)baby
                                usingDoseSeries:(NSArray *)recommendedDoses
{
    NSArray *datesGiven = [baby daysGivenVaccineComponent:component];
    NSDateComponents *dayGiven = datesGiven[doseNum];
    
    if ([[SBTVaccine liveVaccineComponents] containsObject:@(component)] && [baby dayIsDuringLiveBlackout:dayGiven]) return SBTVaccineDoseInvalidTooSoonAfterLiveVaccine;
    
    NSAssert(doseOrd < [datesGiven count], @"Invalid dose number %ld given to status check routine.", (long)doseOrd);
    //    NSString *key = [SBTVaccineSchedule keyForVaccineComponent:component];
    //    NSArray *recommendedDoses = [rules[key] lastObject];
    
    NSInteger earliestAllowed = [recommendedDoses[doseOrd][MIN_AGE_KEY] integerValue];
    
    if (doseOrd > 0){
        NSDateComponents *prevDoseDay = datesGiven[doseNum - 1];
        NSInteger minInterval = [recommendedDoses[doseOrd - 1][MIN_INTERVAL_KEY] integerValue];
        earliestAllowed = MAX(earliestAllowed, prevDoseDay.day + minInterval);
    }
    if (dayGiven.day < earliestAllowed){
        return SBTVaccineDoseInvalidTooEarly;
        
    }else if (dayGiven.day > [recommendedDoses[doseOrd][AGE_LATE_KEY] integerValue]){
        return SBTVaccineDoseValidLate;
        
    }else{
        return SBTVaccineDoseValid;
    }
}

-(NSDictionary *)vaccinationStatusForVaccineComponent:(SBTComponent)component
                                                    forBaby:(SBTBaby *)baby
{
    NSMutableArray *alternateStatusDictionaries = [NSMutableArray new];
    /* 
     A status dictionary will have the following keys:
     SBTVaccineSeriesRulesUsedKey   NSArray * pointing to the recommendedDoses in use at the time
     SBTVaccineSeriesStatusKey      SBTVaccinationStatus of the overall recommendedDoses in question
     SBTVaccineSeriesDoseStatusKey        NSArray * of SBTVaccineDoseStatus, one for each dose in the recommendedDoses
     */
    NSMutableArray *doseStatuses = [NSMutableArray new];
    NSArray *datesGiven = [baby daysGivenVaccineComponent:component];
    NSString *key = [SBTVaccineSchedule keyForVaccineComponent:component];
    NSArray *validSeries = rules[key];
    for (int seriesIndex = 0; seriesIndex < [validSeries count]; seriesIndex++){
        NSMutableDictionary *seriesStatusDict = [NSMutableDictionary new];
        NSInteger doseOrdinal = 0;
        NSArray *recommendedDoses = validSeries[seriesIndex];
        if ([[recommendedDoses firstObject][MIN_AGE_KEY] integerValue] > [baby ageDDAtDate:[NSDate date]].day){
            seriesStatusDict[SBTVaccineSeriesRulesUsedKey] = recommendedDoses;
            seriesStatusDict[SBTVaccineSeriesStatusKey] = @(SBTVaccinationNotYetDue);
            [alternateStatusDictionaries addObject:seriesStatusDict];
            continue;
        }
        for (int i = 0; i < [datesGiven count]; i++){
            SBTVaccineDoseStatus status = [self statusOfVaccineComponent:component
                                                      forGivenDoseNumber:i
                                                                 forDose:doseOrdinal
                                                                 forBaby:baby
                                                         usingDoseSeries:recommendedDoses];
            if (status == SBTVaccineDoseValid || status == SBTVaccineDoseValidLate){
                doseOrdinal++;
            }
            [doseStatuses addObject:@(status)];
        }
        // get the count of valid doses.  It happens to be equal to doseOrdinal at this point (lucky us)
        // get the recommended number of doses.
        NSInteger age = [baby ageDDAtDate:[NSDate date]].day;
        NSInteger recommended = 0;
        while (recommended < [recommendedDoses count] && [recommendedDoses[recommended][REC_AGE_KEY] integerValue] <= age) recommended++;
        // if we are missing any, are we in a lockout, or too soon status right now?
        NSInteger validDoses = [[doseStatuses filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(SELF == %@) OR (SELF == %@)", @(SBTVaccineDoseValid), @(SBTVaccineDoseValidLate)]] count];
        
        // fix up a result dictionary for this set of rules
        seriesStatusDict[SBTVaccineSeriesRulesUsedKey] = [recommendedDoses copy];
        seriesStatusDict[SBTVaccineSeriesDoseStatusKey] = [doseStatuses copy];
        SBTVaccinationStatus seriesStatus;
        if (validDoses >= recommended){
            seriesStatus = SBTVaccinationUTD;
        }else{ // has not had the recommended number of doses
            if ([[SBTVaccine liveVaccineComponents] containsObject:@(component)] && [baby dayIsDuringLiveBlackout:[baby ageDDAtDate:[NSDate date]]]){
                seriesStatus = SBTVaccinationDueLockedOut;
            }else{
                seriesStatus = SBTVaccinationDue;
            }
        }
        seriesStatusDict[SBTVaccineSeriesStatusKey] = @(seriesStatus);
        [alternateStatusDictionaries addObject:seriesStatusDict];
        [doseStatuses removeAllObjects];
    }
    
    // now we have an array of one or more series statuses, we need to return the MOST OPTIMISTIC one.
    SBTVaccinationStatus bestStatus = SBTVaccinationNoData;
    int bestIndex = -1;
    for (int ruleIndex = 0; ruleIndex < [validSeries count]; ruleIndex++){
        SBTVaccinationStatus thisStatus = (SBTVaccinationStatus)[alternateStatusDictionaries[ruleIndex][SBTVaccineSeriesStatusKey] integerValue];
        if (thisStatus >= bestStatus){
            bestStatus = thisStatus;
            bestIndex = ruleIndex;
        }
    }
    return alternateStatusDictionaries[bestIndex];
}

@end
