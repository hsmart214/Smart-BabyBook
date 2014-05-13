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

typedef enum {SBTVaccinationNoData, SBTVaccinationUTD, SBTVaccinationDue, SBTVaccinationDueLockedOut, SBTVaccinationOverdue} SBTVaccinationStatus;
typedef enum {SBTVaccineDoseNoData, SBTVaccineDoseValid, SBTVaccineDoseTooEarly, SBTVaccineDoseLate, SBTVaccineDoseTooSoonAfterLiveVaccine} SBTVaccineDoseStatus;


@interface SBTVaccineSchedule : NSObject

-(SBTVaccinationStatus)vaccinationStatusForVaccineComponent:(SBTComponent)component
                                                    forBaby:(SBTBaby *)baby;
-(SBTVaccineDoseStatus)statusOfVaccineComponent:(SBTComponent)component
                             forGivenDoseNumber:(NSInteger)doseNum
                                        forDose:(NSInteger)doseOrd
                                        forBaby:(SBTBaby *)baby;
+(SBTVaccineSchedule *)sharedSchedule;

@end
