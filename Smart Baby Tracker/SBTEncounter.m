//
//  SBTEncounter.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 1/25/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTEncounter.h"
#import "SBTVaccine.h"

@interface SBTEncounter ()

@property (nonatomic, strong) NSMutableSet *vaccines;

@end

@implementation SBTEncounter

-(void)setLength:(float)length
{
    _length = length;
    _height = 0.0F;
}

-(void)setHeight:(float)height
{
    _height = height;
    _length = 0.0F;
}

-(NSArray *)vaccinesGiven
{
    return [self.vaccines allObjects];
}

-(void)addVaccines:(NSArray *)vaccinesGiven
{
    [self.vaccines addObjectsFromArray:vaccinesGiven];
}

-(void)removeVaccines:(NSArray *)vaccinesToRemove
{
    for (SBTVaccine *vacc in vaccinesToRemove){
        [self.vaccines removeObject:vacc];
    }
}

-(NSTimeInterval)timeIntervalSinceEncounter:(SBTEncounter *)encounter
{
    return [self.date timeIntervalSinceDate:encounter.date];
}

-(instancetype)init{
    return [self initWithDate:[NSDate date]];
}

-(instancetype)initWithDate:(NSDate *)date
{
    if (self = [super init]){
        self.date = date;
        self.vaccines = [NSMutableSet set];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeFloat:self.weight forKey:@"weight"];
    [aCoder encodeFloat:self.length forKey:@"length"];
    [aCoder encodeFloat:self.height forKey:@"height"];
    [aCoder encodeObject:self.vaccines forKey:@"vaccines"];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]){
        self.date = [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"date"];
        self.weight = [aDecoder decodeFloatForKey:@"weight"];
        self.height = [aDecoder decodeFloatForKey:@"height"];
        self.length = [aDecoder decodeFloatForKey:@"length"];
        self.vaccines = [aDecoder decodeObjectOfClass:[NSMutableSet class] forKey:@"vaccines"];
    }
    return self;
}

-(instancetype)copy{
    return [self copyWithZone:nil];
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    SBTEncounter *newEnc = [[SBTEncounter alloc] initWithDate:self.date];
    newEnc.weight = self.weight;
    newEnc.height = self.height;
    newEnc.length = self.length;
    newEnc.vaccines = [self.vaccines copy];
    return newEnc;
}

+(BOOL)supportsSecureCoding
{
    return YES;
}

@end
