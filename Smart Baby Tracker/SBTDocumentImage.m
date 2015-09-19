//
//  SBTDocumentImage.m
//  Smart BabyBook
//
//  Created by J. HOWARD SMART on 9/13/15.
//  Copyright © 2015 J. HOWARD SMART. All rights reserved.
//

#import "SBTDocumentImage.h"

#define DocImage_imageKey @"com.mysmartsoftware.SmartBabyBook.DocumentImage.imageKey"
#define DocImage_titleKey @"com.mysmartsoftware.SmartBabyBook.DocumentImage.titleKey"
#define DocImage_dateKey @"com.mysmartsoftware.SmartBabyBook.DocumentImage.dateKey"
#define DocImage_docDateKey @"com.mysmartsoftware.SmartBabyBook.DocumentImage.docDateKey"
#define DocImage_urlKey @"com.mysmartsoftware.SmartBabyBook.DocumentImage.urlKey"
#define DocImage_commentsKey @"com.mysmartsoftware.SmartBabyBook.DocumentImage.commentsKey"

@interface SBTDocumentImage()

@property (nonatomic, strong, readwrite) NSDate *dateRecorded;
@property (nonatomic, strong) UIImage *thumb;

@end

@implementation SBTDocumentImage

-(UIImage *)thumbnailImage{
    if (!_thumb){
        _thumb = [self reducedSizeImage:self.image];
    }
    return _thumb;
}

-(UIImage *)reducedSizeImage:(UIImage *)largeImage
{
    CGSize origImageSize = [largeImage size];
    
    CGRect newRect = CGRectMake(0, 0, THUMBNAIL_DIMENSION, THUMBNAIL_DIMENSION);
    CGFloat ratio = MAX(newRect.size.width / origImageSize.width,
                        newRect.size.height / origImageSize.height);
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect
                                                    cornerRadius:5.0];
    [path addClip];
    CGRect projectRect;
    projectRect.size.width = ratio * origImageSize.width;
    projectRect.size.height = ratio * origImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;
    
    [largeImage drawInRect:projectRect];
    
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return smallImage;
}


-(instancetype)initWithDate:(NSDate *)date{
    if (self = [super init]) {
        self.dateRecorded = date;
    }
    return self;
}

-(instancetype)copy{
    SBTDocumentImage *newImage = [[SBTDocumentImage alloc] initWithDate:self.dateRecorded];
    newImage.image = self.image; // note this is data sharing of the image instance - this is intentional
    newImage.title = self.title;
    newImage.url = self.url;
    newImage.comments = self.comments;
    return newImage;
}

-(instancetype)copyWithZone:(NSZone *)zone{
    return [self copy];
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    NSData *imageData = UIImageJPEGRepresentation(self.image, 1.0);
    [aCoder encodeObject:imageData forKey:DocImage_imageKey];
    [aCoder encodeObject:self.title forKey:DocImage_titleKey];
    [aCoder encodeObject:self.dateRecorded forKey:DocImage_dateKey];
    [aCoder encodeObject:self.documentDate forKey:DocImage_docDateKey];
    [aCoder encodeObject:self.url forKey:DocImage_urlKey];
    [aCoder encodeObject:self.comments forKey:DocImage_commentsKey];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]){
        self.title = [aDecoder decodeObjectOfClass:[NSString class] forKey:DocImage_titleKey];
        NSData *imageData = [aDecoder decodeObjectOfClass:[NSData class] forKey:DocImage_imageKey];
        self.image = [UIImage imageWithData:imageData];
        self.dateRecorded = [aDecoder decodeObjectOfClass:[NSDate class] forKey:DocImage_dateKey];
        self.documentDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:DocImage_docDateKey];
        self.url = [aDecoder decodeObjectOfClass:[NSURL class] forKey:DocImage_urlKey];
        self.comments = [aDecoder decodeObjectOfClass:[NSString class] forKey:DocImage_commentsKey];
    }
    return self;
}

+(BOOL)supportsSecureCoding{
    return YES;
}

@end
