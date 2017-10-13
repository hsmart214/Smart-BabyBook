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

typedef NS_OPTIONS(NSInteger, SBTMilestone) {
    SBTMilestoneNone,
    SBTMilestoneSmile,
    SBTMilestoneRolloverFront,
    SBTMilestoneRolloverBack,
    SBTMilestoneSitWithoutSupport,
    SBTMilestoneCrawl,
    SBTMilestoneFirstWord,
    SBTMilestoneFirstTooth,
    SBTMilestonePullToStand,
    SBTMilestoneCruise,
    SBTMilestoneFirstSteps,
    SBTMilestoneRun,
    SBTMilestonePhrase,
};

@class SBTBaby;
@class SBTVaccine;

@interface SBTEncounter : NSObject <NSSecureCoding, NSCopying>

@property (nonatomic, weak) SBTBaby * baby;
@property (nonatomic, strong) NSDate *universalDate;
@property (nonatomic, readonly) NSDateComponents *dateComps;
// measurements in metric units
@property (nonatomic, assign) double weight;
// only one linear growth measurement per encounter, the other will be ZERO
@property (nonatomic, assign) double length;    // supine length
@property (nonatomic, assign) double height;    // standing height
@property (nonatomic, assign) double headCirc;
@property (nonatomic, readonly) double BMI;
@property (nonatomic, readonly) SBTMilestone milestones;

-(instancetype)initWithDate:(NSDate *)date; // Designated initializer
-(instancetype)init;
-(instancetype)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;

-(void)replaceVaccines:(NSSet <SBTVaccine *>*)newVaccineSet;  // set of SBTVaccine objects
-(void)addMilestone:(SBTMilestone)milestone;
-(SBTMilestone)milestones;

-(NSInteger)daysSinceEncounter:(SBTEncounter *)encounter;
-(NSInteger)daysSinceDate:(NSDate *)date;
-(NSInteger)ageInDays;
-(NSComparisonResult)compare:(SBTEncounter *)encounter;

-(CGFloat)dataForParameter:(SBTGrowthParameter)param;

// an array of SBTVaccine * objects
-(NSArray <SBTVaccine *>*)vaccinesGiven;
// an array of the individual components given
-(NSArray <NSNumber *>*)componentsGiven; // SBTVaccineComponent raw values as NSNumber
@end
