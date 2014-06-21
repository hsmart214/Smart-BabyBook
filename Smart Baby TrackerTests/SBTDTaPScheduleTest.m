//
//  SBTDTaPScheduleTest.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 2/24/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SBTBaby.h"
#import "SBTEncounter.h"
#import "SBTVaccine.h"
#import "SBTVaccineSchedule.h"
#import "NSDateComponents+Today.h"

@interface SBTDTaPScheduleTest : XCTestCase

@property (nonatomic, strong) SBTBaby *baby;
@property (nonatomic, strong) SBTBaby *sevenYearOld;

@end

@implementation SBTDTaPScheduleTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    NSDateComponents *twoMonths = [[NSDateComponents alloc] init];
    twoMonths.month = 2;
    twoMonths.calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.month = 8;
    comps.day = 18;
    comps.year = 1996;
    comps.calendar = [NSCalendar currentCalendar];
    comps.timeZone = [NSTimeZone localTimeZone];
    self.baby = [[SBTBaby alloc] initWithName:@"Jennifer" andDOB:comps.date];
    self.baby.gender = SBTFemale;
    self.baby.dueDate = [comps copy];
    NSDate *birth = [comps.calendar dateFromComponents:comps];
    
    
    NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:twoMonths toDate:birth options:0];
    SBTEncounter *enc = [[SBTEncounter alloc] initWithDate:date];
    SBTVaccine *vaccine = [[SBTVaccine alloc] initWithName:@"Daptacel" displayNames:@[@"DTaP"] manufacturer:Sanofi andComponents:@[@(SBTComponentDTaP)]];
    vaccine.route = Intramuscular;
    [enc replaceVaccines:[NSSet setWithArray:@[vaccine]]];
    [self.baby addEncounter:enc];
    
    date = [[NSCalendar currentCalendar] dateByAddingComponents:twoMonths toDate:date options:0];
    SBTEncounter *enc2 = [[SBTEncounter alloc] initWithDate:date];
    [enc replaceVaccines:[NSSet setWithArray:@[[vaccine copy]]]];
    [self.baby addEncounter:enc2];
    
    NSDateComponents *minus7y = [NSDateComponents new];
    minus7y.year = -7;
    NSDate *birthday7 = [[NSCalendar currentCalendar] dateByAddingComponents:minus7y toDate:[NSDate date] options:0];
    self.sevenYearOld = [[SBTBaby alloc] initWithName:@"Seven" andDOB:birthday7];
    
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testDTaPStatus2doses
{
    SBTVaccineSchedule *sched = [SBTVaccineSchedule sharedSchedule];
    SBTVaccinationStatus status = (SBTVaccinationStatus)[[sched vaccinationStatusForVaccineComponent:SBTComponentDTaP forBaby:self.baby][SBTVaccineSeriesStatusKey] integerValue];
    XCTAssertTrue(status == SBTVaccinationDue , @"Incorrect calculation of DTaP status with two doses.");
}

-(void)testSevenYearOld_Regular
{
    NSDateComponents *xMonths = [[NSDateComponents alloc] init];
    xMonths.month = 2;
    xMonths.calendar = [NSCalendar currentCalendar];
    
    NSDate *birth = [self.sevenYearOld DOB];
    //two months
    NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:xMonths toDate:birth options:0];
    SBTEncounter *enc = [[SBTEncounter alloc] initWithDate:date];
    SBTVaccine *vaccine = [[SBTVaccine alloc] initWithName:@"Daptacel" displayNames:@[@"DTaP"] manufacturer:Sanofi andComponents:@[@(SBTComponentDTaP)]];
    SBTVaccine *vaccine2 =[[SBTVaccine alloc] initWithName:@"Pentacel" displayNames:@[@"DTaP", @"HiB", @"PCV"] manufacturer:Sanofi andComponents:@[@(SBTComponentDTaP), @(SBTComponentPRP_OMP), @(SBTComponentPCV13)]];

    vaccine.route = Intramuscular;
    vaccine2.route = Intramuscular;
    [enc replaceVaccines:[NSSet setWithArray:@[vaccine2]]];
    [self.sevenYearOld addEncounter:enc];
    //four months
    date = [[NSCalendar currentCalendar] dateByAddingComponents:xMonths toDate:date options:0];
    SBTEncounter *enc2 = [[SBTEncounter alloc] initWithDate:date];
    [enc2 replaceVaccines:[NSSet setWithArray:@[[vaccine2 copy]]]];
    [self.sevenYearOld addEncounter:enc2];
    //six months
    date = [[NSCalendar currentCalendar] dateByAddingComponents:xMonths toDate:date options:0];
    enc2 = [[SBTEncounter alloc] initWithDate:date];
    [enc2 replaceVaccines:[NSSet setWithArray:@[[vaccine2 copy]]]];
    [self.sevenYearOld addEncounter:enc2];
    //fifteen months
    xMonths.month = 9;
    date = [[NSCalendar currentCalendar] dateByAddingComponents:xMonths toDate:date options:0];
    enc2 = [[SBTEncounter alloc] initWithDate:date];
    [enc2 replaceVaccines:[NSSet setWithArray:@[[vaccine2 copy]]]];
    [self.sevenYearOld addEncounter:enc2];
    //four years
    xMonths.month = 0;
    xMonths.year = 3;
    date = [[NSCalendar currentCalendar] dateByAddingComponents:xMonths toDate:date options:0];
    enc2 = [[SBTEncounter alloc] initWithDate:date];
    [enc2 replaceVaccines:[NSSet setWithArray:@[[vaccine copy]]]];
    [self.sevenYearOld addEncounter:enc2];
    
    SBTVaccineSchedule *sched = [SBTVaccineSchedule sharedSchedule];
    SBTVaccinationStatus status = (SBTVaccinationStatus)[[sched vaccinationStatusForVaccineComponent:SBTComponentDTaP forBaby:self.sevenYearOld][SBTVaccineSeriesStatusKey] integerValue];
    XCTAssertTrue(status == SBTVaccinationUTD , @"Incorrect calculation of DTaP status with five regular doses.");
    status = (SBTVaccinationStatus)[[sched vaccinationStatusForVaccineComponent:SBTComponentHiB forBaby:self.sevenYearOld][SBTVaccineSeriesStatusKey] integerValue];
    XCTAssertTrue(status == SBTVaccinationUTD , @"Incorrect calculation of HiB status with four valid doses.");
}

-(void)testSevenYearOld_FifthDoseTooEarly
{
    NSDateComponents *xMonths = [[NSDateComponents alloc] init];
    xMonths.month = 2;
    xMonths.calendar = [NSCalendar currentCalendar];
    
    NSDate *birth = [self.sevenYearOld DOB];
    //two months
    NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:xMonths toDate:birth options:0];
    SBTEncounter *enc = [[SBTEncounter alloc] initWithDate:date];
    SBTVaccine *vaccine = [[SBTVaccine alloc] initWithName:@"Daptacel" displayNames:@[@"DTaP"] manufacturer:Sanofi andComponents:@[@(SBTComponentDTaP)]];
    SBTVaccine *vaccine2 =[[SBTVaccine alloc] initWithName:@"Pentacel" displayNames:@[@"DTaP", @"HiB", @"PCV"] manufacturer:Sanofi andComponents:@[@(SBTComponentDTaP), @(SBTComponentPRP_OMP), @(SBTComponentPCV13)]];
    
    vaccine.route = Intramuscular;
    vaccine2.route = Intramuscular;
    [enc replaceVaccines:[NSSet setWithArray:@[vaccine2]]];
    [self.sevenYearOld addEncounter:enc];
    //four months
    date = [[NSCalendar currentCalendar] dateByAddingComponents:xMonths toDate:date options:0];
    SBTEncounter *enc2 = [[SBTEncounter alloc] initWithDate:date];
    [enc replaceVaccines:[NSSet setWithArray:@[[vaccine2 copy]]]];
    [self.sevenYearOld addEncounter:enc2];
    //six months
    date = [[NSCalendar currentCalendar] dateByAddingComponents:xMonths toDate:date options:0];
    enc2 = [[SBTEncounter alloc] initWithDate:date];
    [enc replaceVaccines:[NSSet setWithArray:@[[vaccine2 copy]]]];
    [self.sevenYearOld addEncounter:enc2];
    //fifteen months
    xMonths.month = 9;
    date = [[NSCalendar currentCalendar] dateByAddingComponents:xMonths toDate:date options:0];
    enc2 = [[SBTEncounter alloc] initWithDate:date];
    [enc replaceVaccines:[NSSet setWithArray:@[[vaccine copy]]]];
    [self.sevenYearOld addEncounter:enc2];
    //three years
    xMonths.month = 0;
    xMonths.year = 2;
    date = [[NSCalendar currentCalendar] dateByAddingComponents:xMonths toDate:date options:0];
    enc2 = [[SBTEncounter alloc] initWithDate:date];
    [enc replaceVaccines:[NSSet setWithArray:@[[vaccine copy]]]];
    [self.sevenYearOld addEncounter:enc2];
    
    SBTVaccineSchedule *sched = [SBTVaccineSchedule sharedSchedule];
    SBTVaccinationStatus status = (SBTVaccinationStatus)[[sched vaccinationStatusForVaccineComponent:SBTComponentDTaP forBaby:self.sevenYearOld][SBTVaccineSeriesStatusKey] integerValue];
    XCTAssertTrue(status == SBTVaccinationDue , @"Incorrect calculation of DTaP status with five regular doses.");
}

-(void)testSevenYearOld_ExtraDoseTooEarly
{
    NSDateComponents *xMonths = [[NSDateComponents alloc] init];
    xMonths.month = 2;
    xMonths.calendar = [NSCalendar currentCalendar];
    
    NSDate *birth = [self.sevenYearOld DOB];
    //two months
    NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:xMonths toDate:birth options:0];
    SBTEncounter *enc = [[SBTEncounter alloc] initWithDate:date];
    SBTVaccine *vaccine = [[SBTVaccine alloc] initWithName:@"Daptacel" displayNames:@[@"DTaP"] manufacturer:Sanofi andComponents:@[@(SBTComponentDTaP)]];
    SBTVaccine *vaccine2 =[[SBTVaccine alloc] initWithName:@"Pentacel" displayNames:@[@"DTaP", @"HiB", @"PCV"] manufacturer:Sanofi andComponents:@[@(SBTComponentDTaP), @(SBTComponentPRP_OMP), @(SBTComponentPCV13)]];
    
    vaccine.route = Intramuscular;
    vaccine2.route = Intramuscular;
    [enc replaceVaccines: [NSSet setWithArray:@[vaccine2]]];
    [self.sevenYearOld addEncounter:enc];
    //four months
    date = [[NSCalendar currentCalendar] dateByAddingComponents:xMonths toDate:date options:0];
    SBTEncounter *enc2 = [[SBTEncounter alloc] initWithDate:date];
    [enc2 replaceVaccines:[NSSet setWithArray:@[[vaccine2 copy]]]];
    [self.sevenYearOld addEncounter:enc2];
    //six months
    date = [[NSCalendar currentCalendar] dateByAddingComponents:xMonths toDate:date options:0];
    enc2 = [[SBTEncounter alloc] initWithDate:date];
    [enc2 replaceVaccines:[NSSet setWithArray:@[[vaccine2 copy]]]];
    [self.sevenYearOld addEncounter:enc2];
    //nine months
    xMonths.month = 3;
    date = [[NSCalendar currentCalendar] dateByAddingComponents:xMonths toDate:date options:0];
    enc2 = [[SBTEncounter alloc] initWithDate:date];
    [enc2 replaceVaccines:[NSSet setWithArray:@[[vaccine copy]]]];
    [self.sevenYearOld addEncounter:enc2];
    //fifteen months
    xMonths.month = 6;
    date = [[NSCalendar currentCalendar] dateByAddingComponents:xMonths toDate:date options:0];
    enc2 = [[SBTEncounter alloc] initWithDate:date];
    [enc2 replaceVaccines:[NSSet setWithArray:@[[vaccine copy]]]];
    [self.sevenYearOld addEncounter:enc2];
    //four years
    xMonths.month = 0;
    xMonths.year = 3;
    date = [[NSCalendar currentCalendar] dateByAddingComponents:xMonths toDate:date options:0];
    enc2 = [[SBTEncounter alloc] initWithDate:date];
    [enc2 replaceVaccines:[NSSet setWithArray:@[[vaccine copy]]]];
    [self.sevenYearOld addEncounter:enc2];
    
    SBTVaccineSchedule *sched = [SBTVaccineSchedule sharedSchedule];
    SBTVaccinationStatus status = (SBTVaccinationStatus)[[sched vaccinationStatusForVaccineComponent:SBTComponentDTaP forBaby:self.sevenYearOld][SBTVaccineSeriesStatusKey] integerValue];
    XCTAssertTrue(status == SBTVaccinationUTD , @"Incorrect calculation of DTaP status with five regular doses.");
}


@end
