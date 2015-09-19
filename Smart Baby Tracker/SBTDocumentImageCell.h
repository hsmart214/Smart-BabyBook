//
//  SBTDocumentImageCell.h
//  Smart BabyBook
//
//  Created by J. HOWARD SMART on 9/18/15.
//  Copyright © 2015 J. HOWARD SMART. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBTDocumentImageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *docThumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;

@end
