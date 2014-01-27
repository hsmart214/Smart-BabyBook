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

@interface SBTBaby ()

@property (nonatomic, strong) NSMutableArray *encounters;
@property (nonatomic, copy) NSDate *dateCreated;
@property (nonatomic, copy) NSDate *dateModified;

@end

@implementation SBTBaby

-(NSArray *)daysGivenVaccineComponent:(SBTComponent)component
{
    NSMutableArray *dates = [NSMutableArray array];
    NSMutableArray *days = [NSMutableArray array];
    
    for (SBTEncounter *enc in self.encounters){
        for (SBTVaccine *vacc in enc.vaccinesGiven){
            if ([vacc includesEquivalentComponent:component]){
                [dates addObject:enc.date];
            }
        }
    }
    for (NSDate *date in dates){
        NSTimeInterval ageInSecs = [date timeIntervalSinceDate:self.DOB];
        double ageInDays = ageInSecs / SBT_DAY;
        [days addObject:@(ageInDays)];
    }
    return [days copy];
}

-(void)addEncounter:(SBTEncounter *)encounter
{
    [self.encounters addObject:encounter];
}

-(NSTimeInterval)ageAtEncounter:(SBTEncounter *)encounter
{
    return [encounter.date timeIntervalSinceDate:self.DOB];
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
        self.DOB = [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"DOB"];
        self.dueDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"dueDate"];
        self.gender = [aDecoder decodeIntegerForKey:@"gender"];
        self.encounters = [aDecoder decodeObjectOfClass:[NSMutableArray class] forKey:@"encounters"];
        self.dateCreated = [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"dateCreated"];
        self.dateModified = [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"dateModified"];
    }
    return self;
}

-(instancetype)initWithName:(NSString *)name andDOB:(NSDate *)dob
{
    if (self = [super init]){
        self.name = name;
        if (dob){
            self.DOB = dob;
        }else{
            self.DOB = [NSDate date];
        }
        self.dateCreated = [NSDate date];
        self.dateModified = [NSDate date];
    }
    return self;
}

-(instancetype)init{
    return [self initWithName:nil andDOB:[NSDate date]];
}

+(BOOL)supportsSecureCoding
{
    return YES;
}

@end
