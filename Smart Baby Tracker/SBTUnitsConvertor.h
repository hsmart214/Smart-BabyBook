//
//  SBTUnitsConvertor.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/16/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#define MASS_UNIT_KEY @"kMassUnitKey"
#define LENGTH_UNIT_KEY @"kLengthUnitKey"
#define HC_UNIT_KEY @"kHeadCircUnitKey"

@import Foundation;

@interface SBTUnitsConvertor : NSObject

+(NSString *)defaultUnitForKey:(NSString *)key;

+(void)setDefaultUnit:(NSString *)unit forKey:(NSString *)key;

+(double)metricStandardOf:(double)dimension forKey:(NSString *)dimKey;

+(double)displayUnitsOf:(double)dimension forKey:(NSString *)dimKey;

+(NSString *)displayStringForKey:(NSString *)dimKey;

@end
