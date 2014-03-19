//
//  SBTEncounter.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 1/25/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTEncounter.h"
#import "SBTVaccine.h"
#import "NSDateComponents+Today.h"

@interface SBTEncounter ()

@property (nonatomic, strong) NSMutableSet *vaccines;
@property (nonatomic, strong) NSDate *dateModified;

@end

@implementation SBTEncounter

-(NSDateComponents *)dateComps
{
    NSCalendarUnit unit = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    return [[NSCalendar currentCalendar] components:unit fromDate:self.universalDate];
}

-(void)setLength:(double)length
{
    _length = length;
    _height = 0.0F;
    self.dateModified = [NSDate date];
}

-(void)setHeight:(double)height
{
    _height = height;
    _length = 0.0F;
    self.dateModified = [NSDate date];
}

-(double)BMI
{
    double ht = self.height + self.weight;
    if (ht <= 0.1){
        return 0.0;
    }
    return self.weight / ht*ht;
}

-(void)setHeadCirc:(double)headCirc
{
    _headCirc = headCirc;
    self.dateModified = [NSDate date];
}

-(NSArray *)vaccinesGiven
{
    return [self.vaccines allObjects];
}

-(void)addVaccines:(NSArray *)vaccinesGiven
{
    // add a copy of each vaccine given in case someone wants to reuse objects.
    for (SBTVaccine *vacc in vaccinesGiven){
        [self.vaccines addObject:[vacc copy]];
    }
    self.dateModified = [NSDate date];
}

-(void)removeVaccines:(NSArray *)vaccinesToRemove
{
    for (SBTVaccine *vacc in vaccinesToRemove){
        [self.vaccines removeObject:vacc];
    }
    self.dateModified = [NSDate date];
}

-(void)replaceVaccines:(NSSet *)newVaccineSet
{
    self.vaccines = [NSMutableSet setWithSet:newVaccineSet];
}

-(NSInteger)daysSinceEncounter:(SBTEncounter *)encounter
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitDay;
    NSDateComponents *days = [cal components:unit fromDate:encounter.universalDate toDate:self.universalDate options:0];
    return [days day];
}

-(NSInteger)daysSinceDate:(NSDate *)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitDay;
    NSDateComponents *days = [cal components:unit fromDate:date toDate:self.universalDate options:0];
    return [days day];
}

-(NSComparisonResult)compare:(SBTEncounter *)encounter
{
    NSDate *date = self.universalDate;
    NSDate *otherDate = encounter.universalDate;
    return [date compare:otherDate];
}

-(instancetype)init{
    // Give a default encounter date of today.
    NSDate *simpleDate = [[NSCalendar currentCalendar] dateFromComponents:[NSDateComponents today]];
    return [self initWithDate:simpleDate];
}

-(instancetype)initWithDate:(NSDate *)date
{
    if (self = [super init]){
        self.universalDate = date;
        self.vaccines = [NSMutableSet set];
        self.dateModified = [NSDate date];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.universalDate forKey:@"date"];
    [aCoder encodeFloat:self.weight forKey:@"weight"];
    [aCoder encodeFloat:self.length forKey:@"length"];
    [aCoder encodeFloat:self.height forKey:@"height"];
    [aCoder encodeFloat:self.headCirc forKey:@"headCirc"];
    [aCoder encodeObject:self.vaccines forKey:@"vaccines"];
    [aCoder encodeObject:self.dateModified forKey:@"dateModified"];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSDate *date = [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"date"];
    if (self = [self initWithDate:date]){
        self.weight = [aDecoder decodeDoubleForKey:@"weight"];
        self.height = [aDecoder decodeDoubleForKey:@"height"];
        self.length = [aDecoder decodeDoubleForKey:@"length"];
        self.headCirc = [aDecoder decodeDoubleForKey:@"headCirc"];
        self.vaccines = [aDecoder decodeObjectOfClass:[NSMutableSet class] forKey:@"vaccines"];
        self.dateModified = [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"dateModified"];
    }
    return self;
}

-(instancetype)copy{
    return [self copyWithZone:nil];
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    SBTEncounter *newEnc = [[SBTEncounter alloc] initWithDate:self.universalDate];
    newEnc.weight = self.weight;
    newEnc.height = self.height;
    newEnc.length = self.length;
    newEnc.headCirc = self.headCirc;
    newEnc.vaccines = [self.vaccines copy];
    return newEnc;
}

+(BOOL)supportsSecureCoding
{
    return YES;
}

@end
