//
//  SBTDocumentImage.h
//  Smart BabyBook
//
//  Created by J. HOWARD SMART on 9/13/15.
//  Copyright © 2015 J. HOWARD SMART. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBTDocumentImage : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong, readonly) NSDate *dateRecorded;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *comments;

@end
