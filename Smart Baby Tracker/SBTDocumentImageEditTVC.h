//
//  SBTDocumentImageEditTVC.h
//  Smart BabyBook
//
//  Created by J. HOWARD SMART on 9/18/15.
//  Copyright © 2015 J. HOWARD SMART. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBTDocumentImage.h"
#import "SBTDocumentsTVC.h"

@interface SBTDocumentImageEditTVC : UITableViewController

@property (weak, nonatomic) SBTDocumentImage *document;
@property (weak, nonatomic) id<SBTDocumentEditor> delegate;

@end
