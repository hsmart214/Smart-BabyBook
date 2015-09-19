//
//  SBTDocumentImageEditTVC.m
//  Smart BabyBook
//
//  Created by J. HOWARD SMART on 9/18/15.
//  Copyright © 2015 J. HOWARD SMART. All rights reserved.
//

#import "SBTDocumentImageEditTVC.h"

@interface SBTDocumentImageEditTVC ()<UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) UIImage *localImage;
@property (weak, nonatomic) IBOutlet UIImageView *docImageView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation SBTDocumentImageEditTVC

-(NSDateFormatter *)dateFormatter{
    if (!_dateFormatter){
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
    return _dateFormatter;
}

-(UIImage *)localImage{
    if (!self.document.url) return nil;
    if (!_localImage){
        if (self.docImageView.frame.size.height == 0) return nil;  // geometry must not be set yet
        UIImage *image = [UIImage imageWithContentsOfFile:[self.document.url path]];
        UIGraphicsBeginImageContext(self.docImageView.frame.size);
        [image drawInRect:self.docImageView.frame];
        _localImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return _localImage;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return self.document.title;
        case 1:
            return @"Document Details";
        default:
            break;
    }
    return nil;
}

#pragma mark - UITextField/View delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    self.document.title = textField.text;
    [self updateDisplay];
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    self.document.comments = textView.text;
    [self updateDisplay];
    return YES;
}

- (IBAction)datePickerChanged:(UIDatePicker *)sender {
    self.document.documentDate = sender.date;
    [self updateDisplay];
}

#pragma mark - View Life Cycle

-(void)updateDisplay{
    self.docImageView.image = self.localImage;
    self.titleTextField.text = self.document.title;
    self.commentTextView.text = self.document.comments;
    self.dateLabel.text = [self.dateFormatter stringFromDate:self.document.documentDate];
    self.datePicker.date = self.document.documentDate;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateDisplay];
}

@end
