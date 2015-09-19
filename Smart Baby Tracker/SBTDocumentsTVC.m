//
//  SBTDocumentsTVC.m
//  Smart BabyBook
//
//  Created by J. HOWARD SMART on 9/13/15.
//  Copyright © 2015 J. HOWARD SMART. All rights reserved.
//

#import "SBTDocumentsTVC.h"
#import "SBTDocumentImageCell.h"
#import "SBTBaby.h"
#import "SBTDocumentImageEditTVC.h"

@interface SBTDocumentsTVC ()

@property (nonatomic, strong) NSArray<SBTDocumentImage*> *documents;

@end

@implementation SBTDocumentsTVC

-(void)setBaby:(SBTBaby *)baby{
    _baby = baby;
    self.documents = [_baby.documents copy];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.documents count];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self removeDocument:self.documents[indexPath.row]];
        
        [tableView endUpdates];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SBTDocumentImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Document Cell" forIndexPath:indexPath];
    cell.titleLabel.text = self.documents[indexPath.row].title;
    cell.commentsLabel.text = self.documents[indexPath.row].comments;
    cell.docThumbnailImageView.image = self.documents[indexPath.row].thumbnailImage;
    return cell;
}

-(BOOL)removeDocument:(SBTDocumentImage *)document{
    BOOL success = [self.baby removeDocument:document];
    if (success){
        [self.delegate babyEditor:self didSaveBaby:self.baby];
        [self updateDisplay];
    }
    return success;
}

-(void)addDocument{
    NSLog(@"Pressed Add");
    [self.delegate babyEditor:self didSaveBaby:self.baby];
}

#pragma mark - SBTDocumentEditor protocol

-(void)documentEditor:(id<SBTDocumentEditor>)editor changedDocument:(SBTDocumentImage *)document newDocument:(BOOL)isNew{
    if (isNew){
        [self.baby addDocument:document];
        [self.delegate babyEditor:self didSaveBaby:self.baby];
    }else{
        [self updateDisplay];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"Edit Document"]){
        SBTDocumentImageEditTVC *dest = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        dest.document = self.documents[indexPath.row];
        dest.delegate = self;
    }
}

-(void)updateDisplay{
    self.documents = [self.documents sortedArrayUsingSelector:@selector(documentDate)];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addDocument)];
    [self updateDisplay];
    [self.tableView reloadData];
}

@end
