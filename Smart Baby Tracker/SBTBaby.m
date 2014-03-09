//
//  SBTBaby.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 1/25/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTBaby.h"
#import "SBTEncounter.h"
#import "SBTVaccine.h"
#import "NSDateComponents+Today.h"

#define PREMATURE_DAYS_EARLY 21
#define LIVE_VACCINE_BLACKOUT 28

@interface SBTBaby ()

@property (nonatomic, strong) NSMutableArray *encounters;
@property (nonatomic, copy) NSDate *dateCreated;
@property (nonatomic, copy) NSDate *dateModified;

@end

@implementation SBTBaby

-(BOOL)isPremature
{   //TODO: fix the prematurity calculation
    if (!_dueDate) return  NO;
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSCalendarUnit unitFlag = NSCalendarUnitDay;
    NSDateComponents *comps = [cal components:unitFlag fromDate:self.dueDate.date toDate:self.DOBComponents.date options:0];
    return [comps day] > PREMATURE_DAYS_EARLY;
}

-(NSDateComponents *)ageYYDDAtDate:(NSDate *)date
{
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitDay;
    NSCalendar *cal = [NSCalendar currentCalendar];
    // strip the birth time out of the DOB components
    NSDateComponents *simpleDOBcomps = [[NSDateComponents alloc] init];
    simpleDOBcomps.year = self.DOBComponents.year;
    simpleDOBcomps.month = self.DOBComponents.month;
    simpleDOBcomps.day = self.DOBComponents.day;
    NSDate *simpleDOB = [cal dateFromComponents:simpleDOBcomps];
    NSDateComponents *comps = [cal components:unitFlags fromDate:simpleDOB toDate:date options:0];
    return comps;
}

-(NSDateComponents *)ageDDAtDate:(NSDate *)date
{
    NSCalendarUnit unitFlags = NSCalendarUnitDay;
    NSCalendar *cal = [NSCalendar currentCalendar];
    // strip the birth time out of the DOB components
    NSDateComponents *simpleDOBcomps = [[NSDateComponents alloc] init];
    simpleDOBcomps.year = self.DOBComponents.year;
    simpleDOBcomps.month = self.DOBComponents.month;
    simpleDOBcomps.day = self.DOBComponents.day;
    NSDate *simpleDOB = [cal dateFromComponents:simpleDOBcomps];
    NSDateComponents *comps = [cal components:unitFlags fromDate:simpleDOB toDate:date options:0];
    return comps;
}


-(void)setName:(NSString *)name
{
    if (![name isEqualToString:_name]){
        _name = name;
        self.dateModified = [NSDate date];
    }
}

-(void)setDOBComponents:(NSDateComponents *)DOBComps
{
    // DOB.calendar = [NSCalendar currentCalendar];
    _DOBComponents = DOBComps;
    self.dateModified = [NSDate date];
}

-(void)setDueDate:(NSDateComponents *)dueDate
{
    _dueDate = dueDate;
    self.dateModified = [NSDate date];
}

-(NSMutableArray *)encounters
{
    if (!_encounters){
        _encounters = [NSMutableArray array];
    }
    return _encounters;
}

-(NSArray *)daysGivenVaccineComponent:(SBTComponent)component
{
    NSMutableArray *days = [NSMutableArray array];
    
    for (SBTEncounter *enc in self.encounters){
        for (SBTVaccine *vacc in enc.vaccinesGiven){
            if ([vacc includesEquivalentComponent:component]){
                [days addObject:[self ageInDaysAtEncounter:enc]];
            }
        }
    }
    return days;
}

-(NSArray *)daysGivenLiveVaccineComponent
{
    NSMutableArray *liveDays = [NSMutableArray array];
    
    for (SBTEncounter *enc in self.encounters){
        for (SBTVaccine *vacc in enc.vaccinesGiven){
            if ([vacc liveVaccine]){
                [liveDays addObject:[self ageInDaysAtEncounter:enc]];
            }
        }
    }
    return liveDays;
}

-(BOOL)dayIsDuringLiveBlackout:(NSDateComponents *)dayOfLife
{
    for (NSDateComponents *comps in [self daysGivenLiveVaccineComponent]){
        NSInteger interval = dayOfLife.day - comps.day;
        if (interval > 0 && interval < LIVE_VACCINE_BLACKOUT){
            return YES;
        }
    }
    return NO;
}

-(void)addEncounter:(SBTEncounter *)encounter
{
    [self.encounters addObject:encounter];
    [_encounters sortUsingSelector:@selector(compare:)];
    self.dateModified = [NSDate date];
}

-(BOOL)removeEncounter:(SBTEncounter *)encounter
{
    BOOL present = [self.encounters containsObject:encounter];
    if (present) {
        [self.encounters removeObject:encounter];
        self.dateModified = [NSDate date];
    }
    return present;
}

-(NSDateComponents *)ageInYearsAndDaysAtEncounter:(SBTEncounter *)encounter
{
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:(NSCalendarUnitDay | NSCalendarUnitYear) fromDate:self.DOB toDate:encounter.dateComps.date options:0];
    return comps;
}

-(NSDateComponents *)ageInMonthsAndDaysAtEncounter:(SBTEncounter *)encounter
{
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:(NSCalendarUnitDay | NSCalendarUnitMonth) fromDate:self.DOB toDate:encounter.dateComps.date options:0];
    return comps;
}


-(NSDateComponents *)ageInDaysAtEncounter:(SBTEncounter *)encounter
{
    
    NSDateComponents *comps = [NSDateComponents new];
    comps.day = [encounter daysSinceDate:self.DOB];
    return comps;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    // This init will automatically set the created and modified dates to now.
    SBTBaby *newBaby = [[SBTBaby alloc] initWithName:self.name andDOB:self.DOB];
    newBaby.dueDate = self.dueDate;
    newBaby.gender = self.gender;
    newBaby.encounters = [self.encounters mutableCopy];
    return newBaby;
}

-(instancetype)copy{
    return [self copyWithZone:nil];
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.DOB forKey:@"DOBComponents"];
    [aCoder encodeObject:self.dueDate forKey:@"dueDate"];
    [aCoder encodeInteger:self.gender forKey:@"gender"];
    [aCoder encodeObject:self.encounters forKey:@"encounters"];
    [aCoder encodeObject:self.dateCreated forKey:@"dateCreated"];
    [aCoder encodeObject:self.dateModified forKey:@"dateModified"];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]){
        self.name = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"name"];
        self.DOBComponents = [aDecoder decodeObjectOfClass:[NSDateComponents class] forKey:@"DOBComponents"];
        self.dueDate = [aDecoder decodeObjectOfClass:[NSDateComponents class] forKey:@"dueDate"];
        self.gender = (SBTGender)[aDecoder decodeIntegerForKey:@"gender"];
        self.encounters = [aDecoder decodeObjectOfClass:[NSMutableSet class] forKey:@"encounters"];
        self.dateCreated = [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"dateCreated"];
        self.dateModified = [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"dateModified"];
    }
    return self;
}

-(instancetype)initWithName:(NSString *)name andDOB:(NSDate *)dob
{
    NSCalendarUnit MDY_HM = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSCalendarUnit MDY = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    if (self = [super init]){
        self.name = name;
        if (dob){
            _DOB = [dob copy];
            self.DOBComponents = [[NSCalendar currentCalendar] components:MDY_HM fromDate:dob];
        }else{
            _DOB = [NSDate date];
            self.DOBComponents = [[NSCalendar currentCalendar] components:MDY fromDate:[NSDate date]];
            self.DOBComponents.calendar = [NSCalendar currentCalendar];
        }
        self.dateCreated = [NSDate date];
        self.dateModified = [NSDate date];
    }
    return self;
}

-(instancetype)init{
    return [self initWithName:@"Baby" andDOB:[NSDate date]];
}

+(BOOL)supportsSecureCoding
{
    return YES;
}

@end
