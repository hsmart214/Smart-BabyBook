//
//  NSDateComponents+Today.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 2/2/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateComponents (Today)

// using the current calendar construct a NSDateComponents object with just the MMDDYYYY info
+(instancetype)today;

@end
