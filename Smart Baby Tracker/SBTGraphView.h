//
//  SBTGraphView.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/24/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBTGrowthDataSource.h"

typedef struct {CGFloat beginAge;
                CGFloat endAge;} SBTAgeRange;

@protocol SBTGraphViewDataSource <NSObject>

@required

-(NSArray *)dataPointsInRange:(SBTAgeRange)ageRange;
-(CGFloat)valueForPercentile:(SBTPercentile)percentile
                      forAge:(CGFloat)age
                  forMeasure:(SBTGrowthParameter)parameter;
-(SBTAgeRange)horizRange;
-(CGFloat)vertRange;
-(SBTGender)gender;

@end

@interface SBTGraphView : UIView<UIScrollViewDelegate>

@property (nonatomic, weak) id<SBTGraphViewDataSource> dataSource;
@property (nonatomic, assign) SBTGrowthParameter measure;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

-(void)setUpOnce;

@end
