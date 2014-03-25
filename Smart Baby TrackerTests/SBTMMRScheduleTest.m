//
//  SBTMMRScheduleTest.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/8/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SBTBaby.h"
#import "SBTEncounter.h"
#import "SBTVaccine.h"
#import "SBTVaccineSchedule.h"
#import "NSDateComponents+Today.h"


@interface SBTMMRScheduleTest : XCTestCase

@property (nonatomic, strong) SBTBaby *baby1yr;
@property (nonatomic, strong) SBTBaby *baby2yr;
@property (nonatomic, strong) SBTVaccineSchedule *sched;

@end

@implementation SBTMMRScheduleTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.sched = [SBTVaccineSchedule sharedSchedule];
    NSDateComponents *xMonths = [[NSDateComponents alloc] init];
    xMonths.day = -365;
    NSDate *birthday = [[NSCalendar currentCalendar] dateByAddingComponents:xMonths toDate:[NSDate date] options:0];
    self.baby1yr = [[SBTBaby alloc] initWithName:@"Baby" andDOB:birthday];
    birthday = [[NSCalendar currentCalendar] dateByAddingComponents:xMonths toDate:birthday options:0];
    self.baby2yr = [[SBTBaby alloc] initWithName:@"Toddler" andDOB:birthday];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMMROneDoseOnTime
{
    SBTVaccine *mmr = [[SBTVaccine alloc] initWithName:@"MMR-II" displayNames:@[@"MMR"] manufacturer:Wyeth andComponents:@[@(SBTComponentMMR)]];
    SBTEncounter *enc = [[SBTEncounter alloc] initWithDate:[NSDate date]];
    [enc replaceVaccines:[NSSet setWithArray:@[mmr]]];
    [self.baby1yr addEncounter:enc];
    SBTVaccinationStatus status = [self.sched vaccinationStatusForVaccineComponent:SBTComponentMMR forBaby:self.baby1yr];
    XCTAssertTrue(status == SBTVaccinationUTD , @"Incorrect calculation of DTaP status with five regular doses.");
}

-(void)testMMRTwoDosesOnTime
{
    //this test also tests adding encounters in reverse chronological order
    NSDateComponents *difference = [[NSDateComponents alloc] init];
    difference.month = -11;
    NSDate *prevEncounterDate = [[NSCalendar currentCalendar] dateByAddingComponents:difference toDate:[NSDate date] options:0];
    SBTVaccine *mmr = [[SBTVaccine alloc] initWithName:@"MMR-II" displayNames:@[@"MMR"] manufacturer:Wyeth andComponents:@[@(SBTComponentMMR)]];
    SBTEncounter *enc = [[SBTEncounter alloc] initWithDate:[NSDate date]];
    [enc replaceVaccines:[NSSet setWithArray:@[mmr]]];
    [self.baby2yr addEncounter:enc];
    enc = [[SBTEncounter alloc] initWithDate:prevEncounterDate];
    [enc replaceVaccines:[NSSet setWithArray:@[mmr]]];
    [self.baby2yr addEncounter:enc];
    SBTVaccinationStatus status = [self.sched vaccinationStatusForVaccineComponent:SBTComponentMMR forBaby:self.baby2yr];
    XCTAssertTrue(status == SBTVaccinationUTD , @"Incorrect calculation of DTaP status with five regular doses.");
}

@end
