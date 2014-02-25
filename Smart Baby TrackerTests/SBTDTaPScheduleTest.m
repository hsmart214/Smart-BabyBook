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

@interface SBTDTaPScheduleTest : XCTestCase

@property (nonatomic, strong) SBTBaby *baby;

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
    self.baby = [[SBTBaby alloc] initWithName:@"Jennifer" andDOB:comps];
    self.baby.gender = SBTFemale;
    self.baby.dueDate = [comps copy];
    NSDate *birth = [comps.calendar dateFromComponents:comps];
    
    
    NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:twoMonths toDate:birth options:0];
    SBTEncounter *enc = [[SBTEncounter alloc] initWithDate:date];
    SBTVaccine *vaccine = [[SBTVaccine alloc] initWithName:@"Daptacel" displayNames:@[@"DTaP"] manufacturer:Sanofi andComponents:@[@(SBTComponentDTaP)]];
    vaccine.route = Intramuscular;
    [enc addVaccines: @[vaccine]];
    [self.baby addEncounter:enc];
    
    date = [[NSCalendar currentCalendar] dateByAddingComponents:twoMonths toDate:date options:0];
    SBTEncounter *enc2 = [[SBTEncounter alloc] initWithDate:date];
    [enc2 addVaccines:@[[vaccine copy]]];
    [self.baby addEncounter:enc2];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testExample
{
    SBTVaccineSchedule *sched = [SBTVaccineSchedule sharedSchedule];
    SBTVaccinationStatus status = [sched baby:self.baby vaccinationStatusForVaccineComponent:SBTComponentDTaP];
    XCTAssertTrue(status == SBTVaccineDoseDue , @"Incorrect calculation of DTaP status with two doses.");
}

@end
