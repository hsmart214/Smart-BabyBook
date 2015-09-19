//
//  SBTDocumentsTVC.h
//  Smart BabyBook
//
//  Created by J. HOWARD SMART on 9/13/15.
//  Copyright © 2015 J. HOWARD SMART. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBTBabyEditDelegate.h"
#import "SBTDocumentImage.h"
@class SBTBaby;

@protocol SBTDocumentEditor <NSObject>

-(void)documentEditor:(id<SBTDocumentEditor>)editor changedDocument:(SBTDocumentImage *)document newDocument:(BOOL)isNew;

@end

@interface SBTDocumentsTVC : UITableViewController <SBTDocumentEditor>

@property (weak, nonatomic) id<SBTBabyEditDelegate> delegate;
@property (weak, nonatomic) SBTBaby *baby;

@end
