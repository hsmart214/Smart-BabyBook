//
//  SBTWHODataTets.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/1/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SBTBaby.h"
#import "SBTEncounter.h"
#import "SBTVaccine.h"
#import "SBTVaccineSchedule.h"
#import "SBTWHODataSource.h"
#import "SBTCDCDataSource.h"

@interface SBTGrowthDataSourceTests : XCTestCase

{
    SBTWHODataSource *whoData;
    SBTCDCDataSource *cdcData;
}

@property (nonatomic, strong) SBTBaby *baby;

@end

@implementation SBTGrowthDataSourceTests

- (void)setUp
{
    [super setUp];
    
    whoData = [SBTWHODataSource sharedDataSource];
    cdcData = [SBTCDCDataSource sharedDataSource];
    
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
    // this results in the date 10/18/1996, 61 days of age.
    SBTEncounter *enc = [[SBTEncounter alloc] initWithDate:date];
    enc.weight = 5.1315f;
    enc.length = 50.786f;
    enc.headCirc = 34.513f;
    [self.baby addEncounter:enc];
    
    date = [[NSCalendar currentCalendar] dateByAddingComponents:twoMonths toDate:date options:0];
    SBTEncounter *enc2 = [[SBTEncounter alloc] initWithDate:date];
    // this results in the date 12/18/1996, 122 days of age.
    enc2.weight = 6.428;
    enc2.length = 62.1071;
    enc2.headCirc = 40.5895;
    [self.baby addEncounter:enc2];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testWHOGirlWeight
{
    double w = 5.1315;
    double pct = [whoData percentileOfMeasurement:w
                                           forAge:61
                                        parameter:SBTWeight
                                        andGender:SBTFemale];
    XCTAssert((fabs(pct-50.0)<= 0.00001), @"Not calculating 2 mo female WHO weight percentile correctly");
}

- (void)testCDCGirlWeight
{
    double w = 4.8877f;
    double pct = [cdcData percentileOfMeasurement:w
                                           forAge:61
                                        parameter:SBTWeight
                                        andGender:SBTFemale];
    XCTAssert((fabs(pct-50.0)<= 0.01), @"Not calculating 2 mo female CDC weight percentile correctly");
}

@end
