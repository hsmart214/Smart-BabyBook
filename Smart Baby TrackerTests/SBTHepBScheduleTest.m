//
//  SBTHepBScheduleTest.m
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


@interface SBTHepBScheduleTest : XCTestCase

@property (nonatomic, strong) SBTBaby *baby;
@property (nonatomic, strong) SBTBaby *baby2;
@property (nonatomic, strong) SBTBaby *toddler;
@property (nonatomic, strong) SBTVaccineSchedule *sched;

@end

@implementation SBTHepBScheduleTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.sched = [SBTVaccineSchedule sharedSchedule];
    NSDateComponents *xMonths = [[NSDateComponents alloc] init];
    xMonths.day = -70;
    NSDate *birthday = [[NSCalendar currentCalendar] dateByAddingComponents:xMonths toDate:[NSDate date] options:0];
    self.baby = [[SBTBaby alloc] initWithName:@"Baby" andDOB:birthday];
    xMonths.day = 0;
    xMonths.month = -15;    // this makes this toddler 17 months old so dose is not "Late" but just "Due"
    birthday = [[NSCalendar currentCalendar] dateByAddingComponents:xMonths toDate:birthday options:0];
    self.toddler = [[SBTBaby alloc] initWithName:@"Toddler" andDOB:birthday];
    xMonths.month = 0;
    xMonths.day = -180;
    birthday = [[NSCalendar currentCalendar] dateByAddingComponents:xMonths toDate:[NSDate date] options:0];
    self.baby2 = [[SBTBaby alloc] initWithName:@"UCSD-Baby" andDOB:birthday];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testHepBRegular2Dose_NotDueYet
{
    NSDateComponents *difference = [[NSDateComponents alloc] init];
    difference.month = -2;
    NSDate *prevEncounterDate = [[NSCalendar currentCalendar] dateByAddingComponents:difference toDate:[NSDate date] options:0];
    SBTVaccine *hepB = [SBTVaccine vaccinesByTradeName][@"Engerix-B"];
    XCTAssertNotNil(hepB, @"Failed to find Engerix-B by name in the trade name dictionary.");
    SBTEncounter *enc = [[SBTEncounter alloc] initWithDate:[NSDate date]];
    [enc replaceVaccines:[NSSet setWithArray:@[hepB]]];
    [self.baby addEncounter:enc];
    enc = [[SBTEncounter alloc] initWithDate:prevEncounterDate];
    [enc replaceVaccines:[NSSet setWithArray:@[hepB]]];
    [self.baby addEncounter:enc];
    SBTVaccinationStatus status = [self.sched vaccinationStatusForVaccineComponent:SBTComponentHepB forBaby:self.baby];
    XCTAssertTrue(status == SBTVaccinationUTD , @"Incorrect calculation of Hep B status with two valid doses, not due yet.");
}

- (void)testHepBRegular3Dose_OneTooCloseToLive
{
    SBTVaccine *hepB = [SBTVaccine vaccinesByTradeName][@"Engerix-B"];
    SBTVaccine *mmr = [SBTVaccine vaccinesByTradeName][@"MMR-II"];
    
    XCTAssertNotNil(hepB, @"Failed to find Engerix-B by name in the trade name dictionary.");
    XCTAssertNotNil(mmr, @"Failed to find MMR-II by name in the trade name dictionary.");
    
    NSDateComponents *difference = [[NSDateComponents alloc] init];
    difference.month = -16;
    NSDate *encounter1date = [[NSCalendar currentCalendar] dateByAddingComponents:difference toDate:[NSDate date] options:0];
    difference.month = 2;
    NSDate *encounter2date = [[NSCalendar currentCalendar] dateByAddingComponents:difference toDate:encounter1date options:0];
    difference.month = 10;
    NSDate *encounterMMRdate = [[NSCalendar currentCalendar] dateByAddingComponents:difference toDate:encounter2date options:0];
    difference.month = 0;
    difference.day = 20;
    NSDate *encounter3date = [[NSCalendar currentCalendar] dateByAddingComponents:difference toDate:encounterMMRdate options:0];

    SBTEncounter *enc = [[SBTEncounter alloc] initWithDate:encounter1date];
    [enc replaceVaccines:[NSSet setWithArray:@[hepB]]];
    [self.toddler addEncounter:enc];
    enc = [[SBTEncounter alloc] initWithDate:encounter2date];
    [enc replaceVaccines:[NSSet setWithArray:@[hepB]]];
    [self.toddler addEncounter:enc];
    enc = [[SBTEncounter alloc] initWithDate:encounterMMRdate];
    [enc replaceVaccines:[NSSet setWithArray:@[mmr]]];
    [self.toddler addEncounter:enc];
    enc = [[SBTEncounter alloc] initWithDate:encounter3date];
    [enc replaceVaccines:[NSSet setWithArray:@[hepB]]];
    [self.toddler addEncounter:enc];
    SBTVaccinationStatus status = [self.sched vaccinationStatusForVaccineComponent:SBTComponentHepB forBaby:self.toddler];
    XCTAssertTrue(status == SBTVaccinationDue , @"Incorrect calculation of Hep B status with two valid doses, not due yet.");
}

- (void)testHepB4DosesLikeUCSD
{
    SBTVaccine *hepB = [SBTVaccine vaccinesByTradeName][@"Engerix-B"];
    
    XCTAssertNotNil(hepB, @"Failed to find Engerix-B by name in the trade name dictionary.");
    
    NSDateComponents *difference = [[NSDateComponents alloc] init];
    difference.day = -179;
    NSDate *encounter1date = [[NSCalendar currentCalendar] dateByAddingComponents:difference toDate:[NSDate date] options:0];
    difference.day = 0;
    difference.month = 2;
    NSDate *encounter2date = [[NSCalendar currentCalendar] dateByAddingComponents:difference toDate:encounter1date options:0];
    NSDate *encounter4date = [[NSCalendar currentCalendar] dateByAddingComponents:difference toDate:encounter2date options:0];
    NSDate *encounter3date = [[NSCalendar currentCalendar] dateByAddingComponents:difference toDate:encounter4date options:0];
    
    SBTEncounter *enc = [[SBTEncounter alloc] initWithDate:encounter1date];
    [enc replaceVaccines:[NSSet setWithArray:@[hepB]]];
    [self.baby2 addEncounter:enc];
    enc = [[SBTEncounter alloc] initWithDate:encounter2date];
    [enc replaceVaccines:[NSSet setWithArray:@[hepB]]];
    [self.baby2 addEncounter:enc];
    enc = [[SBTEncounter alloc] initWithDate:encounter4date];
    [enc replaceVaccines:[NSSet setWithArray:@[hepB]]];
    [self.baby2 addEncounter:enc];
    enc = [[SBTEncounter alloc] initWithDate:encounter3date];
    [enc replaceVaccines:[NSSet setWithArray:@[hepB]]];
    [self.baby2 addEncounter:enc];
    SBTVaccinationStatus status = [self.sched vaccinationStatusForVaccineComponent:SBTComponentHepB forBaby:self.baby2];
    XCTAssertTrue(status == SBTVaccinationUTD , @"Incorrect calculation of Hep B status with four doses, third too soon.");
}


@end
