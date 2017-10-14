//
//  SBTDataStore.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/17/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

@import Foundation;
@class SBTDataStore;
@class SBTBaby;

@interface SBTDataStore : NSObject

// this method will ADD the baby if the name is new, and REPLACE the baby if the name exists
-(void)storeBaby:(SBTBaby *)baby;
-(BOOL)removeBaby:(SBTBaby *)baby;  // returns a boolean YES if the baby was in the list and removed, otherwise NO
-(void)removeBabyByName:(NSString *)name; // used to remove the reference to the baby under the wrong key after the name has been changed
-(NSArray *)storedBabies;

+(instancetype)sharedStore;

@end
