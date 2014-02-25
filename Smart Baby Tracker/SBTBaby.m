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

@interface SBTBaby ()

@property (nonatomic, strong) NSMutableSet *encounters;
@property (nonatomic, copy) NSDate *dateCreated;
@property (nonatomic, copy) NSDate *dateModified;

@end

@implementation SBTBaby

-(BOOL)isPremature
{   //TODO: fix the prematurity calculation
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSCalendarUnit unitFlag = NSCalendarUnitDay;
    NSDateComponents *comps = [cal components:unitFlag fromDate:self.dueDate.date toDate:self.DOB.date options:0];
    return [comps day] > PREMATURE_DAYS_EARLY;
}

-(NSDateComponents *)ageAtDate:(NSDate *)date
{
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitDay;
    NSCalendar *cal = [NSCalendar currentCalendar];
    // strip the birth time out of the DOB components
    NSDateComponents *simpleDOBcomps = [[NSDateComponents alloc] init];
    simpleDOBcomps.year = self.DOB.year;
    simpleDOBcomps.month = self.DOB.month;
    simpleDOBcomps.day = self.DOB.day;
    NSDate *simpleDOB = [self.DOB.calendar dateFromComponents:simpleDOBcomps];
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

-(void)setDOB:(NSDateComponents *)DOB
{
    // DOB.calendar = [NSCalendar currentCalendar];
    _DOB = DOB;
    self.dateModified = [NSDate date];
}

-(void)setDueDate:(NSDateComponents *)dueDate
{
    _dueDate = dueDate;
    self.dateModified = [NSDate date];
}

-(NSMutableSet *)encounters
{
    if (!_encounters){
        _encounters = [NSMutableSet set];
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
    return [days copy];
}

-(void)addEncounter:(SBTEncounter *)encounter
{
    [self.encounters addObject:encounter];
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
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:(NSCalendarUnitDay | NSCalendarUnitYear) fromDate:encounter.dateComps.date toDate:self.DOB.date options:0];
    return comps;
}

-(NSDateComponents *)ageInMonthsAndDaysAtEncounter:(SBTEncounter *)encounter
{
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:(NSCalendarUnitDay | NSCalendarUnitMonth) fromDate:encounter.dateComps.date toDate:self.DOB.date options:0];
    return comps;
}


-(NSDateComponents *)ageInDaysAtEncounter:(SBTEncounter *)encounter
{
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:(NSCalendarUnitDay) fromDate:encounter.dateComps.date toDate:self.DOB.date options:0];
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
    [aCoder encodeObject:self.DOB forKey:@"DOB"];
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
        self.DOB = [aDecoder decodeObjectOfClass:[NSDateComponents class] forKey:@"DOB"];
        self.dueDate = [aDecoder decodeObjectOfClass:[NSDateComponents class] forKey:@"dueDate"];
        self.gender = (SBTGender)[aDecoder decodeIntegerForKey:@"gender"];
        self.encounters = [aDecoder decodeObjectOfClass:[NSMutableSet class] forKey:@"encounters"];
        self.dateCreated = [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"dateCreated"];
        self.dateModified = [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"dateModified"];
    }
    return self;
}

-(instancetype)initWithName:(NSString *)name andDOB:(NSDateComponents *)dob
{
    if (self = [super init]){
        self.name = name;
        if (dob){
            self.DOB = dob;
        }else{
            NSCalendarUnit unit = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
            self.DOB = [[NSCalendar currentCalendar] components:unit fromDate:[NSDate date]];
            self.DOB.calendar = [NSCalendar currentCalendar];
        }
        self.dateCreated = [NSDate date];
        self.dateModified = [NSDate date];
    }
    return self;
}

-(instancetype)init{
    return [self initWithName:nil andDOB:nil];
}

+(BOOL)supportsSecureCoding
{
    return YES;
}

@end
