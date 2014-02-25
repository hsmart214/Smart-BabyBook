//
//  SBTBaby.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 1/25/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

@import Foundation;

@class SBTEncounter;

@interface SBTBaby : NSObject <NSSecureCoding, NSCopying>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSDateComponents *DOB;

@property (nonatomic, copy) NSDateComponents *dueDate;    // this is optional.  If no due date, assume full term baby.
@property (assign) SBTGender gender;

-(BOOL)isPremature;

// years, days only (no months)
-(NSDateComponents *)ageAtDate:(NSDate *)date;

// this DOB should have its calendar property set to the local calendar used to create it.
// if the DOB has a time as well, its timeZone property should also be set.
-(instancetype)initWithName:(NSString *)name andDOB:(NSDateComponents *)dob;
-(instancetype)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;

-(instancetype)copyWithZone:(NSZone *)zone;
-(instancetype)copy;

-(void)addEncounter:(SBTEncounter *)encounter;
-(BOOL)removeEncounter:(SBTEncounter *)encounter;   // returns NO if encounter not present in the Baby's set of encounters
-(NSDateComponents *)ageInYearsAndDaysAtEncounter:(SBTEncounter *)encounter;
-(NSDateComponents *)ageInMonthsAndDaysAtEncounter:(SBTEncounter *)encounter;
-(NSDateComponents *)ageInDaysAtEncounter:(SBTEncounter *)encounter;

// will return an EMPTY ARRAY (not nil) if never received the component
// to simplfy, the ages are given in DAYS as NSDateComponents * objects (not NSTimeIntervals)
-(NSArray *)daysGivenVaccineComponent:(SBTComponent)component;

@end
