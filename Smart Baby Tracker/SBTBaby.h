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
@property (nonatomic, copy) NSDate *DOB;
@property (nonatomic, copy) NSDate *dueDate;    // this is optional.  If no due date, assume full term baby.
@property (assign) SBTGender gender;

-(instancetype)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;

-(instancetype)copyWithZone:(NSZone *)zone;
-(instancetype)copy;

-(void)addEncounter:(SBTEncounter *)encounter;
-(NSTimeInterval)ageAtEncounter:(SBTEncounter *)encounter;

// will return an EMPTY ARRAY (not nil) if never received the component
// to simplfy, the ages are given in DAYS (not NSTimeIntervals)
-(NSArray *)daysGivenVaccineComponent:(SBTComponent)component;

+(BOOL)supportsSecureCoding;

@end
