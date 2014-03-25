//
//  Smart_Baby_TrackerTests.m
//  Smart Baby TrackerTests
//
//  Created by J. HOWARD SMART on 1/24/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SBTBaby.h"
#import "SBTEncounter.h"
#import "SBTVaccine.h"
#import "SBTVaccineSchedule.h"

@interface Smart_Baby_TrackerTests : XCTestCase

@property (nonatomic, strong) NSMutableArray *babies;

@end

@implementation Smart_Baby_TrackerTests
{
    NSCalendar *cal;
    NSDateComponents *comps;
    SBTEncounter *enc1;
    SBTEncounter *enc2;
    SBTVaccine *vac1;
    SBTVaccine *vac2;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    cal = [NSCalendar currentCalendar];
    comps = [[NSDateComponents alloc] init];
    comps.year = 1994;
    comps.month = 11;
    comps.day = 20;
    comps.calendar = cal;
    
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
}

- (void)testBaby
{
    SBTBaby *baby = [[SBTBaby alloc] initWithName:@"Hayley" andDOB:comps.date];
    [self.babies addObject:baby];
    XCTAssertNotNil(baby, @"Failed to create a SBTBaby object.");
    XCTAssertEqualObjects(baby.name, @"Hayley", @"SBTBaby initWithName: did not set name properly.");
    XCTAssertTrue([[baby ageYYDDAtDate:[NSDate date]] year] == 19, @"SBTBaby ageAtDate: not returning correct years.");
    NSDateComponents *dc = [[NSDateComponents alloc] init];
    dc.year = 1994;
    dc.month = 11;
    dc.day = 21;
    dc.calendar = [NSCalendar currentCalendar];
    enc1 = [[SBTEncounter alloc] initWithDate:[dc.calendar dateFromComponents:dc]];
    vac1 = [[SBTVaccine alloc] initWithName:@"TriHiBit" displayNames:@[@"DTaP", @"HiB"] andComponents:@[@(SBTComponentDTaP), @(SBTComponentHiB)]];
    vac2 = [[SBTVaccine alloc] initWithName:@"IPOL" displayNames:@[@"IPV"] andComponents:@[@(SBTComponentIPV)]];
    [enc1 replaceVaccines:[NSSet setWithArray:@[vac1, vac2]]];
    dc.year = 1995;
    dc.month = 1;
    dc.day = 23;
    enc2 = [[SBTEncounter alloc] initWithDate:[dc.calendar dateFromComponents:dc]];
    [enc2 replaceVaccines:[NSSet setWithArray:@[vac1, vac2]]];
    [baby addEncounter:enc1];
    [baby addEncounter:enc2];
    NSArray *days = [baby daysGivenVaccineComponent:SBTComponentDTaP];
    XCTAssertTrue(days.count == 2, @"SBTBaby daysGivenVaccineComponent not counting DTaP correctly");
    days = [baby daysGivenVaccineComponent:SBTComponentHiB];
    XCTAssertTrue(days.count == 2, @"SBTBaby daysGivenVaccineComponent not counting HiB correctly");
    days = [baby daysGivenVaccineComponent:SBTComponentIPV];
    XCTAssertTrue(days.count == 2, @"SBTBaby daysGivenVaccineComponent not counting IPV correctly");
}

-(void)testEncounter
{
    
}

@end
