//
//  BCRVaccineCode.m
//  Smart Baby Book
//
//  Created by J. HOWARD SMART on 2/27/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

#import "BCRVaccineCodeLoader.h"
#define VACCINE_CODE_FILENAME @"NDC_Unit_Use.txt"
#define VACCINE_DICT_FILENAME @"come.mysmartsoftware.BabyBook.vaccineNDCDictionary.plist"

@implementation BCRVaccineCodeLoader

+(NSDictionary *)vaccines{
    NSMutableDictionary * sVaccines = [NSMutableDictionary new];
    if (![sVaccines count]) {
        //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //NSInteger currentMotorsVersion = [defaults integerForKey:MOTOR_FILE_VERSION_KEY];
        NSBundle *mainBundle = [NSBundle mainBundle];
        //NSInteger bundleMotorVersion = [[NSString stringWithContentsOfURL:[mainBundle URLForResource:MOTOR_VERSION_FILENAME withExtension:@"txt"] encoding:NSUTF8StringEncoding error:nil]integerValue];
        
        // Check to see if the vaccine information is already cached.  Return it
        NSURL *cacheURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *vaccineFileURL = [cacheURL URLByAppendingPathComponent:VACCINE_DICT_FILENAME];
        if ([[NSFileManager defaultManager]fileExistsAtPath:[vaccineFileURL path]]){
            NSDictionary *allVaccines = [[NSDictionary alloc] initWithContentsOfURL:vaccineFileURL];
            return allVaccines;
        }
        
        // Load the vaccine information from the raw data file and parse it into a usable dictionary, cache the dictionary
        NSURL *vaccineRawURL = [mainBundle URLForResource:VACCINE_CODE_FILENAME withExtension:nil];
        NSError *err;
        NSString *vaccineData = [NSString stringWithContentsOfURL:vaccineRawURL encoding:NSUTF8StringEncoding error:&err];
        if (err){
            NSLog(@"%@, %@", @"Error reading NDC data from bundle file",[err debugDescription]);
        }
        NSMutableArray *textLines = [NSMutableArray arrayWithArray:[vaccineData componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\r"]]];
        
        /* This is the first line of the data file, which will be the keys in the dictionary
         NDCInnerID,UseUnitLabeler,UseUnitProduct,UseUnitPackage,UseUnitPropName,UseUnitGenericName,UseUnitLabelerName, UseUnitstartDate,UseUnitEndDate,UseUnitGTIN,CVX Code,CVX Short Description,NoInner,NDC11,last_updated_date,GTIN
         */
        NSArray *keys;
        if ([textLines count]){
            keys = [textLines[0] componentsSeparatedByString:@"\t"];
            [textLines removeObjectAtIndex:0];
        }
        
        while ([textLines count] > 0) {
            NSMutableDictionary *singleVaccineEntry = [NSMutableDictionary dictionary];
            NSString *line = [textLines lastObject];
            [textLines removeLastObject];
            NSArray *chunks = [line componentsSeparatedByString:@"\t"];
            
            // have to be careful about empty entries in the array
            // doing the for loop the old fashioned way takes care of a missing last entry
            for (int i = 0; i < [chunks count]; i++){
                NSAssert(i < [keys count], @"Too many entries in line in data file.");
                // this keeps us from trying to store a nil value in the dictionary
                if (chunks[i]){
                    NSString *chunk;
                    if ([chunks[i] length] > 2 && [[chunks[i] substringToIndex:1] isEqualToString:@"\""]){
                        NSRange rng = NSMakeRange(1, [chunks[i] length]-2);
                        chunk = [chunks[i] substringWithRange:rng];
                    }else{
                        chunk = chunks[i];
                    }
                    singleVaccineEntry[keys[i]] = chunk;
                }
            }
            if (singleVaccineEntry[@"NDC11"]){
                [sVaccines setObject:singleVaccineEntry forKey:singleVaccineEntry[@"NDC11"]];
            }
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [sVaccines writeToURL:vaccineFileURL atomically:YES];
        });
        
        
    }
    return sVaccines;
}

@end

