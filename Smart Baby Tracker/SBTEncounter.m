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
#import "SBTBaby.h"

@interface SBTEncounter ()

@property (nonatomic, strong) NSMutableSet *vaccines;  // set of SBTVaccine
@property (nonatomic, copy) NSDate *dateModified;

@end

@implementation SBTEncounter

-(void)addMilestone:(SBTMilestone)milestone{
    _milestones = _milestones && milestone;
}

-(NSDate *)universalDate
{
    if (!_universalDate){
        _universalDate = _dateModified;
    }
    return _universalDate;
}

-(NSDateComponents *)dateComps
{
    NSCalendarUnit unit = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    NSDateComponents *dc = [[NSCalendar currentCalendar] components:unit fromDate:self.universalDate];
    dc.calendar = [NSCalendar currentCalendar];
    return dc;
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

-(void)setWeight:(double)weight
{
    _weight = weight;
    self.dateModified = [NSDate date];
}

-(double)BMI
{
    double ht = (self.height + self.length) / 100.0;    // since we keep stature in cm, and we need meters for BMI
    if (ht <= 0.1){
        return 0.0;
    }
    return self.weight / (ht*ht);
}

-(void)setHeadCirc:(double)headCirc
{
    _headCirc = headCirc;
    self.dateModified = [NSDate date];
}

-(CGFloat)dataForParameter:(SBTGrowthParameter)param
{
    switch (param) {
        case SBTBMI:
            return self.BMI;
        case SBTWeight:
            return self.weight;
        case SBTHeadCircumference:
            return self.headCirc;
        case SBTLength:
        case SBTStature:    // for starters I will not distinguish between height and length, but I can change this later
            return self.length + self.height;
        default:
            return 0.0;  // should not reach this line
            break;
    }
}

-(NSArray *)vaccinesGiven
{
    return [self.vaccines allObjects];
}

-(NSArray *)componentsGiven
{
    NSMutableArray *given = [NSMutableArray array];
    for (SBTVaccine *vacc in self.vaccines){
        for (NSNumber *compNum in vacc.components){
            [given addObject:compNum];
        }
    }
    return given;
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

-(NSInteger)ageInDays
{
    return [self daysSinceDate:self.baby.DOB];
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
    NSData *vaccineData = [NSKeyedArchiver archivedDataWithRootObject:self.vaccines];
    [aCoder encodeObject:vaccineData forKey:@"vaccines"];
    [aCoder encodeObject:self.dateModified forKey:@"dateModified"];
}


-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSDate *date = [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"date"];
    if (self = [self initWithDate:date]){
        self->_weight = [aDecoder decodeDoubleForKey:@"weight"];
        self->_height = [aDecoder decodeDoubleForKey:@"height"];
        self->_length = [aDecoder decodeDoubleForKey:@"length"];
        self->_headCirc = [aDecoder decodeDoubleForKey:@"headCirc"];
        NSData *vaccineData = [aDecoder decodeObjectOfClass:[NSData class] forKey:@"vaccines"];
        self.vaccines = [NSKeyedUnarchiver unarchiveObjectWithData:vaccineData];
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
    newEnc.baby = self.baby;
    newEnc->_weight = self.weight;
    newEnc->_height = self.height;
    newEnc->_length = self.length;
    newEnc->_headCirc = self.headCirc;
    newEnc.vaccines = [self.vaccines copy];
    newEnc.dateModified = self.dateModified;
    return newEnc;
}

+(BOOL)supportsSecureCoding
{
    return YES;
}

-(NSString *)description
{
    NSMutableString *descr = [NSMutableString string];
    [descr appendString:[NSString stringWithFormat:@"Encounter date: %@\n", self.universalDate]];
    [descr appendString:[NSString stringWithFormat:@"Height: %1.1f cm\n", self.height]];
    [descr appendString:[NSString stringWithFormat:@"Length: %1.1f cm\n", self.length]];
    [descr appendString:[NSString stringWithFormat:@"Weight: %1.1f kg\n", self.weight]];
    [descr appendString:[NSString stringWithFormat:@"Head circ: %1.1f cm\n", self.headCirc]];
    [descr appendString:[NSString stringWithFormat:@"Vaccines: %lu", (unsigned long)[self.vaccines count]]];
    return descr;
}

@end
