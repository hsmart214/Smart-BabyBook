//
//  SBTBaby.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 1/25/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTEncounter.h"
@import Foundation;
@import UIKit;

@class SBTDocumentImage;
@class SBTVaccine;

@interface SBTBaby : NSObject <NSSecureCoding, NSCopying>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSDateComponents *DOBComponents;
@property (nonatomic, readonly) NSDate *DOB;
@property (nonatomic, strong) UIImage *thumbnail;

@property (nonatomic, copy) NSDateComponents *dueDate;    // this is optional.  If no due date, assume full term baby.
@property (nonatomic, assign) SBTGender gender;

-(BOOL)isPremature;

// years, days only (no months)
-(NSDateComponents *)ageYYDDAtDate:(NSDate *)date;
-(NSDateComponents *)ageDDAtDate:(NSDate *)date;
-(NSDateComponents *)ageMDYAtDate:(NSDate *)date;
-(NSString *)ageDescriptionAtDate:(NSDate *)date;
-(NSString *)dobDescription;

// this DOB should have its calendar property set to the local calendar used to create it.
// if the DOB has a time as well, its timeZone property should also be set.
// Designated initializer
-(instancetype)initWithName:(NSString *)name andDOB:(NSDate *)dob;
-(instancetype)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;

-(instancetype)copyWithZone:(NSZone *)zone;
-(instancetype)copy;
-(instancetype)copyWithNewName:(NSString *)name andDOB:(NSDate *)dob;

-(void)addEncounter:(SBTEncounter *)encounter;
-(BOOL)removeEncounter:(SBTEncounter *)encounter;   // returns NO if encounter not present in the Baby's set of encounters
-(BOOL)replaceBirthEncounterWithEncounter:(SBTEncounter *)encounter; // returns a success boolean.  Cannot put birth date after existing encounters
-(NSDateComponents *)ageInYearsAndDaysAtEncounter:(SBTEncounter *)encounter;
-(NSDateComponents *)ageInMonthsAndDaysAtEncounter:(SBTEncounter *)encounter;
-(NSDateComponents *)ageInDaysAtEncounter:(SBTEncounter *)encounter;

// will return an EMPTY ARRAY (not nil) if never received the component
// to simplify, the ages are given in DAYS as NSDateComponents * objects (not NSTimeIntervals or NSIntegers)
-(NSArray *)daysGivenVaccineComponent:(SBTComponent)component;
-(NSArray <SBTEncounter *>*)encountersWithGivenVaccineComponent:(SBTComponent)component;
-(NSArray *)daysGivenLiveVaccineComponent;
-(BOOL)dayIsDuringLiveBlackout:(NSDateComponents *)dayOfLife;
-(NSArray <SBTEncounter *>*)encountersList;
-(NSArray <SBTVaccine *>*)vaccinesGiven;  // a list of every SBTVaccine * given (used to check for recalls)
-(SBTMilestone)milestones;

-(NSArray<SBTDocumentImage *> *)documents;
-(void)addDocument:(SBTDocumentImage *)document;
-(BOOL)removeDocument:(SBTDocumentImage *)document;  // returns NO if the document was not removed (not in the list?)
@end
