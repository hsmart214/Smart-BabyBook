//
//  SBTGraphVCDelegate.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 5/17/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SBTBaby;

@protocol SBTGraphVCDelegate <NSObject>
@required

@property (weak, nonatomic) SBTBaby* baby

@end
