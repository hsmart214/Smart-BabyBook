//
//  SBTUnitsConvertor.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/16/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTUnitsConvertor.h"

#define UNIT_PREFS_KEY @"com.mySmartSoftware.smartBabyTracker.unitPrefs"

#define K_CENTIMETERS @"cm"
#define K_INCHES @"in"
#define K_KILOGRAMS @"kg"
#define K_POUNDS @"lb"

#define INCHES_PER_CENTIMETER 2.54F
#define POUNDS_PER_KILOGRAM 2.2046226F

@implementation SBTUnitsConvertor

+(NSString *)defaultUnitForKey:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *unitDefaults = [defaults objectForKey:UNIT_PREFS_KEY];
    return unitDefaults[key];
}

+(void)setDefaultUnit:(NSString *)unit forKey:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *unitDefaults = [[defaults objectForKey:UNIT_PREFS_KEY] mutableCopy];
    unitDefaults[key] = unit;
    [defaults setObject:unitDefaults forKey:UNIT_PREFS_KEY];
    [defaults synchronize];
}

#pragma mark - Class Methods
// measurements of the rocket (and motor) will always be stored in the metric units used for calculations
// but the user can ask to see them in US or non-standard units if desired
// This class method can be called to convert a dimension from the displayed units back to the metric for storage
// [SLUnitsConvertor metricStandardOf: [self.motorDiamLabel.text floatValue] forKey: MOTOR_SIZE_UNIT_KEY];
+(double)metricStandardOf:(double)dimension forKey:(NSString *)dimKey{
    NSDictionary *standards = @{LENGTH_UNIT_KEY: K_CENTIMETERS,
                                HC_UNIT_KEY: K_CENTIMETERS,
                                MASS_UNIT_KEY: K_KILOGRAMS,
                                };
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *unitPrefs = [defaults objectForKey:UNIT_PREFS_KEY];
    
    if ([unitPrefs[dimKey] isEqualToString: standards[dimKey]]) return dimension;
    
    if ([dimKey isEqualToString:LENGTH_UNIT_KEY]){      // standard is CENTIMETERS
        if ([unitPrefs[dimKey] isEqualToString:K_INCHES]){
            return dimension / INCHES_PER_CENTIMETER;
        }
    }
    if ([dimKey isEqualToString:HC_UNIT_KEY]){    // standard is CENTIMETERS
        if ([unitPrefs[dimKey] isEqualToString:K_INCHES]){
            return dimension / (INCHES_PER_CENTIMETER);
        }
    }
    if ([dimKey isEqualToString:MASS_UNIT_KEY]){         // standard is KILOGRAMS - others may be used frequently
        if ([unitPrefs[dimKey] isEqualToString:K_POUNDS]){
            return dimension/ POUNDS_PER_KILOGRAM;
        }
    }
    return dimension;
}

// and here is the inverse function to turn the measurement back into display units
// [LSRUnitsViewController displayUnitsOf: [self.rocket.mass floatValue] forKey: MASS_UNIT_KEY];
+(double)displayUnitsOf:(double)dimension forKey:(NSString *)dimKey{
    NSDictionary *standards = @{LENGTH_UNIT_KEY: K_CENTIMETERS,
                                HC_UNIT_KEY: K_CENTIMETERS,
                                MASS_UNIT_KEY: K_KILOGRAMS,
                                };
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *unitPrefs = [defaults objectForKey:UNIT_PREFS_KEY];
    
    if ([unitPrefs[dimKey] isEqualToString: standards[dimKey]]) return dimension;
    
    if ([dimKey isEqualToString:LENGTH_UNIT_KEY]){      // standard is METERS
        if ([unitPrefs[dimKey] isEqualToString:K_INCHES]){
            return dimension * INCHES_PER_CENTIMETER;
        }
    }
    if ([dimKey isEqualToString:HC_UNIT_KEY]){    // standard is METERS
        if ([unitPrefs[dimKey] isEqualToString:K_INCHES]){
            return dimension * INCHES_PER_CENTIMETER;
        }
    }
    if ([dimKey isEqualToString:MASS_UNIT_KEY]){         // standard is KILOGRAMS - others may be used frequently
        if ([unitPrefs[dimKey] isEqualToString:K_POUNDS]){
            return dimension * POUNDS_PER_KILOGRAM;
        }
    }
    return dimension;
}

+ (NSString *)displayStringForKey:(NSString *)dimKey{
    NSDictionary *displayStrings = @{
                                     K_CENTIMETERS: @"cm",
                                     K_INCHES: @"in",
                                     K_KILOGRAMS: @"kg",
                                     K_POUNDS: @"lbs",
                                     };
    NSString *preferredUnit = [SBTUnitsConvertor defaultUnitForKey:dimKey];
    return displayStrings[preferredUnit];
}


@end
