//
//  UIColor+SBTColors.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/26/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "UIColor+SBTColors.h"

@implementation UIColor (SBTColors)


+(instancetype)SBTBabyBlue
{
    return [UIColor colorWithRed:200.0/255.0 green:230.0/255.0 blue:1.0 alpha:1.0];
}

+(instancetype)SBTBabyPink
{
    return [UIColor colorWithRed:1.0 green:200.0/255.0 blue:230.0/255.0 alpha:1.0];
}

+(instancetype)SBTSuperLightGray
{
    return [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
}

+(instancetype)SBTBoyLineColor
{
    return [UIColor blueColor];
}

+(instancetype)SBTGirlLineColor
{
    return [UIColor redColor];
}


@end
