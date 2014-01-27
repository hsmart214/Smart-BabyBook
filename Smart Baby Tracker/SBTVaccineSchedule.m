//
//  SBTVaccineSchedule.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 1/26/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTVaccineSchedule.h"
#import "SBTBaby.h"
#import "SBTVaccine.h"

@implementation SBTVaccineSchedule

+(SBTVaccineSchedule *)sharedSchedule
{
    static SBTVaccineSchedule *vs = nil;
    if (!vs){
        vs = [[SBTVaccineSchedule alloc] init];
    }
    return vs;
}

-(BOOL)baby:(SBTBaby *)baby isUTDforVaccineComponent:(SBTComponent)component
{
    return NO;
}

@end
