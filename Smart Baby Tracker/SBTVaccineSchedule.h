//
//  SBTVaccineSchedule.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 1/26/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//
// This class is intended to be a singleton.  You can give it an SBTBaby object and ask it whether
// the vaccines are up to date, and when the next dose is due, if any.
// This information could be collated to form a visual representation of when doses were given, whether
// they were on time, if any were too early, too late, interfered with each other, etc.
//

@import Foundation;
@class SBTBaby;
@class SBTVaccine;
@class SBTEncounter;

typedef NS_ENUM(NSUInteger, SBTVaccineSeriesStatus) {
    SBTVaccinationNoData, SBTVaccinationNotYetDue, SBTVaccinationOverdue, SBTVaccinationDue, SBTVaccinationDueLockedOut, SBTVaccinationUTD,
};

typedef NS_ENUM(NSUInteger, SBTVaccineDoseStatus) {
    SBTVaccineDoseNoData, SBTVaccineDoseInvalidTooEarly, SBTVaccineDoseInvalidTooSoonAfterLiveVaccine, SBTVaccineDoseValidLate, SBTVaccineDoseValid,
};

@interface SBTVaccineSchedule : NSObject

/*
 A status dictionary will have the following keys:
 SBTVaccineSeriesRulesUsedKey   NSArray * pointing to the recommendedDoses in use at the time
 SBTVaccineSeriesStatusKey      SBTVaccineSeriesStatus of the overall recommendedDoses in question
 SBTVaccineSeriesDoseStatusKey  NSArray * of SBTVaccineDoseStatus, one for each dose in the recommendedDoses
 */

-(NSDictionary *)vaccinationStatusForVaccineComponent:(SBTComponent)component
                                                    forBaby:(SBTBaby *)baby;

-(SBTVaccineDoseStatus)statusOfVaccineComponent:(SBTComponent)component
                             forGivenDoseNumber:(NSInteger)doseNum
                                        forDose:(NSInteger)doseOrd
                                        forBaby:(SBTBaby *)baby
                                usingDoseSeries:(NSArray *)recommendedDoses;
+(SBTVaccineSchedule *)sharedSchedule;
+(NSArray *)recommendedVaccines;
-(NSArray *)recalledVaccines;

-(BOOL)vaccine:(SBTVaccine *)vaccine tooEarlyForEncounter:(SBTEncounter *)encounter;
-(BOOL)tooOldForVaccine:(SBTVaccine *)vaccine atEncounter:(SBTEncounter *)encounter;

@end
