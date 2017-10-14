//
//  SBTBabyEditDelegate.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/22/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

@import Foundation;
@class SBTBaby;

@protocol SBTBabyEditDelegate <NSObject>

@required

-(void)babyEditor:(id)babyEditor didSaveBaby:(SBTBaby *)baby;
-(void)babyEditor:(id)babyEditor didRenameBaby:(SBTBaby *)baby fromOldName:(NSString *)oldName toNewName:(NSString *)newName;

@end
