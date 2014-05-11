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
-(NSArray *)storedBabies;

+(instancetype)sharedStore;

@end
