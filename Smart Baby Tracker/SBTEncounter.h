//
//  SBTEncounter.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 1/25/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

/// Used to encapsulate any dated information put into an SBTBaby's record
/// date of the SBTEncounter is based on the number of whole days since
/// the birth date.

@import Foundation;

@interface SBTEncounter : NSObject <NSSecureCoding, NSCopying>

@property (nonatomic, strong) NSDate *universalDate;
@property (nonatomic, readonly) NSDateComponents *dateComps;
// measurements in metric units
@property (nonatomic, assign) double weight;
// only one linear growth measurement per encounter, the other will be ZERO
@property (nonatomic, assign) double length;    // supine length
@property (nonatomic, assign) double height;    // standing height
@property (nonatomic, assign) double headCirc;
@property (nonatomic, readonly) double BMI;

-(instancetype)initWithDate:(NSDate *)date; // Designated initializer
-(instancetype)init;
-(instancetype)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;

-(void)replaceVaccines:(NSSet *)newVaccineSet;

-(NSInteger)daysSinceEncounter:(SBTEncounter *)encounter;
-(NSInteger)daysSinceDate:(NSDate *)date;
-(NSComparisonResult)compare:(SBTEncounter *)encounter;

// an array of SBTVaccine * objects
-(NSArray *)vaccinesGiven;

@end
