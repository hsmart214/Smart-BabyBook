//
//  SBTEncounter.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 1/25/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

@import Foundation;

@interface SBTEncounter : NSObject <NSSecureCoding, NSCopying>

@property (nonatomic, copy) NSDate *date;
// measurements in metric units
@property (nonatomic, assign) float weight;
// only one linear growth measurement per encounter, the other will be ZERO
@property (nonatomic, assign) float length;    // supine length
@property (nonatomic, assign) float height;    // standing height

-(instancetype)initWithDate:(NSDate *)date; // Designated initializer
-(instancetype)init;
-(instancetype)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;

-(void)addVaccines:(NSArray *)vaccinesGiven;
-(void)removeVaccines:(NSArray *)vaccinesToRemove;

-(NSTimeInterval)timeIntervalSinceEncounter:(SBTEncounter *)encounter;

-(NSArray *)vaccinesGiven;

+(BOOL)supportsSecureCoding;

@end