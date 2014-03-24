//
//  SBTLongPressLabel.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/23/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTLongPressLabel.h"

@implementation SBTLongPressLabel

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return [sender class] == [UILongPressGestureRecognizer class];
}



@end
