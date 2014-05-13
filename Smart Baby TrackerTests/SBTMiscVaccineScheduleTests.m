//
//  SBTMiscVaccineScheduleTests.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 5/12/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SBTBaby.h"
#import "SBTEncounter.h"
#import "SBTVaccine.h"
#import "SBTVaccineSchedule.h"
#import "NSDateComponents+Today.h"

@interface SBTMiscVaccineScheduleTests : XCTestCase

@property (nonatomic, strong) SBTBaby *baby1yr;
@property (nonatomic, strong) SBTBaby *baby2yr;
@property (nonatomic, strong) SBTBaby *baby4yr;
@property (nonatomic, strong) SBTVaccineSchedule *sched;

@end

@implementation SBTMiscVaccineScheduleTests

- (void)setUp
{
    [super setUp];
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.sched = [SBTVaccineSchedule sharedSchedule];
    NSDateComponents *xMonths = [[NSDateComponents alloc] init];
    xMonths.day = -365;
    NSDate *birthday = [[NSCalendar currentCalendar] dateByAddingComponents:xMonths toDate:[NSDate date] options:0];
    self.baby1yr = [[SBTBaby alloc] initWithName:@"Baby" andDOB:birthday];
    birthday = [[NSCalendar currentCalendar] dateByAddingComponents:xMonths toDate:birthday options:0];
    self.baby2yr = [[SBTBaby alloc] initWithName:@"Toddler" andDOB:birthday];
    xMonths.day = 2 * xMonths.day - 5;
    birthday = [[NSCalendar currentCalendar] dateByAddingComponents:xMonths toDate:birthday options:0];
    self.baby4yr = [[SBTBaby alloc] initWithName:@"PreSchooler" andDOB:birthday];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)test
{
    
}

@end
