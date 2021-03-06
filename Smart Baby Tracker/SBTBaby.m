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
#define PREMATURE_TWIN_DAYS_EARLY 28
#define LIVE_VACCINE_BLACKOUT 28

@interface SBTBaby ()

@property (nonatomic, strong) NSMutableArray *encounters;
@property (nonatomic, copy) NSDate *dateCreated;
@property (nonatomic, copy) NSDate *dateModified;
@property (nonatomic, strong) NSDateFormatter *df;
@property (nonatomic, strong, readwrite) NSDate *DOB;
@property (nonatomic, strong) NSMutableArray<SBTDocumentImage *> *documentImages;

@end

@implementation SBTBaby

-(BOOL)isPremature
{   //TODO: fix the prematurity calculation
    if (!_dueDate) return  NO;
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSCalendarUnit unitFlag = NSCalendarUnitDay;
    NSDateComponents *comps = [cal components:unitFlag fromDate:self.DOB toDate:self.dueDate.date options:0];
    return [comps day] > PREMATURE_DAYS_EARLY;
}

-(NSDateComponents *)ageYYDDAtDate:(NSDate *)date
{
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitDay;
    return [self ageAtDate:date withCalendarUnits:unitFlags];
}

-(NSDateComponents *)ageDDAtDate:(NSDate *)date
{
    NSCalendarUnit unitFlags = NSCalendarUnitDay;
    return [self ageAtDate:date withCalendarUnits:unitFlags];
}

-(NSDateComponents *)ageMDYAtDate:(NSDate *)date
{
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    return [self ageAtDate:date withCalendarUnits:unitFlags];
}

-(NSDateComponents *)ageAtDate:(NSDate *)date withCalendarUnits:(NSCalendarUnit)units
{
    NSCalendar *cal = self.DOBComponents.calendar;
    if (!cal) cal = [NSCalendar currentCalendar];
    // strip the birth time out of the DOB components
    NSDateComponents *simpleDOBcomps = [[NSDateComponents alloc] init];
    simpleDOBcomps.year = self.DOBComponents.year;
    simpleDOBcomps.month = self.DOBComponents.month;
    simpleDOBcomps.day = self.DOBComponents.day;
    NSDate *simpleDOB = [cal dateFromComponents:simpleDOBcomps];
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:units fromDate:simpleDOB toDate:date options:0];
    return comps;
}

-(NSString *)ageDescriptionAtDate:(NSDate *)date
{
    NSString *age;
    NSDateComponents *comps = [self ageMDYAtDate:date];
    if (comps.year < 2){
        if (comps.year < 1){
            if (comps.month < 1){
                age = [NSString stringWithFormat:@"%ld day", (long)comps.day];
                if (comps.day > 1) age = [age stringByAppendingString:@"s"];
            }else{
                age = [NSString stringWithFormat:@"%ld mo", (long)comps.month];
                if (comps.month > 1) age = [age stringByAppendingString:@"s"];
            }
        }else{
            age = [NSString stringWithFormat:@"%ld mos", (long)(comps.month + 12 * comps.year)];
        }
    }else{
        age = [NSString stringWithFormat:@"%ld yrs", (long)comps.year];
    }
    return age;
}

-(NSDateFormatter *)df{
    if (!_df){
        _df = [[NSDateFormatter alloc] init];
        [_df setDateStyle:NSDateFormatterShortStyle];
        [_df setTimeStyle:NSDateFormatterNoStyle];
    }
    return _df;
}

-(NSString *)dobDescription{
    return [self.df stringFromDate:self.DOB];
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

-(NSArray *)encountersWithGivenVaccineComponent:(SBTComponent)component
{
    NSMutableArray *encounters = [NSMutableArray array];
    
    for (SBTEncounter *enc in self.encounters){
        for (SBTVaccine *vacc in enc.vaccinesGiven){
            if ([vacc includesExactComponent:component]){
                [encounters addObject:enc];
            }
        }
    }
    return encounters;

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

-(NSArray *)encountersList
{
    return self.encounters;
}

-(NSArray *)vaccinesGiven{
    NSMutableArray *build = [NSMutableArray new];
    for (SBTEncounter *enc in self.encounters){
        for (SBTVaccine *vac in enc.vaccinesGiven){
            [build addObject:vac];
        }
    }
    return [build copy];
}

-(SBTMilestone)milestones{
    SBTMilestone stone = SBTMilestoneNone;
    for (SBTEncounter *enc in self.encounters){
        stone = stone || enc.milestones;
    }
    return stone;
}

-(NSArray<SBTDocumentImage *> *)documents{
    return self.documentImages;
}

-(void)addDocument:(SBTDocumentImage *)document{
    if (![self.documentImages containsObject:document]){
        [self.documentImages addObject:document];
    }
}

-(BOOL)removeDocument:(SBTDocumentImage *)document{
    if ([self.documentImages containsObject:document]){
        [self.documentImages removeObject:document];
        return YES;
    }else{
        return NO;
    }
}

-(void)addEncounter:(SBTEncounter *)encounter
{
    if (!encounter) return;
    if ([self.encounters containsObject:encounter]) return;
    encounter.baby = self;
    [self.encounters addObject:encounter];
    [_encounters sortUsingSelector:@selector(compare:)];
    self.dateModified = [NSDate date];
}

-(BOOL)replaceBirthEncounterWithEncounter:(SBTEncounter *)encounter
{
    // the boolean result indicates success.  This method will fail if you try to
    // put in a birth encounter with a date that is later than an existing non-birth encounter
    if ([self.encounters count] < 2){
        _encounters = [@[encounter] mutableCopy];
    }else{
        SBTEncounter *second = self.encounters[1];
        if ([encounter.universalDate compare:second.universalDate] == NSOrderedDescending){
            return NO;
        }else{
            [self removeEncounter:[self.encountersList firstObject]];
            [self addEncounter:encounter];
            NSAssert([[self encountersList] firstObject] == encounter, @"Failed to add birth encounter in the first position.");
        }
    }
    self.DOB = encounter.universalDate;
    self.dateModified = [NSDate date];
    
    return YES;
}

-(BOOL)removeEncounter:(SBTEncounter *)encounter
{
    if (!encounter) return NO;
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
    for (SBTEncounter *enc in newBaby.encounters){
        enc.baby = newBaby;
    }
    return newBaby;
}

-(instancetype)copy{
    return [self copyWithZone:nil];
}

-(instancetype)copyWithNewName:(NSString *)name andDOB:(NSDate *)dob
{
    SBTBaby *newBaby = [[SBTBaby alloc] initWithName:name andDOB:dob];
    newBaby.dueDate = self.dueDate;
    newBaby.gender = self.gender;
    newBaby.encounters = [self.encounters mutableCopy];
    for (SBTEncounter *enc in newBaby.encounters){
        enc.baby = newBaby;
    }
    return newBaby;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.DOBComponents forKey:@"DOBComponents"];
    [aCoder encodeObject:self.dueDate forKey:@"dueDate"];
    [aCoder encodeInteger:self.gender forKey:@"gender"];
    NSData *encounterData = [NSKeyedArchiver archivedDataWithRootObject:self.encounters];
    [aCoder encodeObject:encounterData forKey:@"encounters"];
    [aCoder encodeObject:self.dateCreated forKey:@"dateCreated"];
    [aCoder encodeObject:self.dateModified forKey:@"dateModified"];
    NSData *imageData = UIImageJPEGRepresentation(self.thumbnail, 1.0);
    [aCoder encodeObject:imageData forKey:@"thumbnailImageData"];
    NSData *documentData = [NSKeyedArchiver archivedDataWithRootObject:self.documentImages];
    [aCoder encodeObject:documentData forKey:@"documentImages"];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSString *name = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"name"];
    NSDateComponents *dobcomps = [aDecoder decodeObjectOfClass:[NSDateComponents class] forKey:@"DOBComponents"];
    NSDate *date = [dobcomps.calendar dateFromComponents:dobcomps];
    if (self = [self initWithName:name andDOB:date]){
        self.dueDate = [aDecoder decodeObjectOfClass:[NSDateComponents class] forKey:@"dueDate"];
        self.gender = (SBTGender)[aDecoder decodeIntegerForKey:@"gender"];
        NSData *encounterData = [aDecoder decodeObjectOfClass:[NSData class] forKey:@"encounters"];
        self.encounters = [NSKeyedUnarchiver unarchiveObjectWithData:encounterData];
        for (SBTEncounter *enc in self.encounters){
            enc.baby = self;
        }
        self.dateCreated = [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"dateCreated"];
        self.dateModified = [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"dateModified"];
        NSData *imageData = [aDecoder decodeObjectOfClass:[NSData class] forKey:@"thumbnailImageData"];
        self.thumbnail = [UIImage imageWithData:imageData];
        NSData *documentData = [aDecoder decodeObjectOfClass:[NSData class] forKey:@"documentImages"];
        self.documentImages = [NSKeyedUnarchiver unarchiveObjectWithData:documentData];
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
            self.DOBComponents.calendar = [NSCalendar currentCalendar];
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

-(NSString *)description{
    return [NSString stringWithFormat:@"Baby: %@, DOB %@, %ld encounters",[self name], [self dobDescription], (unsigned long)[self.encounters count]];
}

-(void)dealloc
{
    self.df = nil;
}

@end
