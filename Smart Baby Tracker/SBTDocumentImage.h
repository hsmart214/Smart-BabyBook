//
//  SBTDocumentImage.h
//  Smart BabyBook
//
//  Created by J. HOWARD SMART on 9/13/15.
//  Copyright © 2015 J. HOWARD SMART. All rights reserved.
//

@import Foundation;

@interface SBTDocumentImage : NSObject <NSSecureCoding, NSCopying>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong, readonly) NSDate *dateRecorded;
@property (nonatomic, strong) NSDate *documentDate;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *comments;
@property (nonatomic, readonly) UIImage *thumbnailImage; // this will be a small square image for the tableview cell

-(instancetype)initWithDate:(NSDate *)date;

@end
