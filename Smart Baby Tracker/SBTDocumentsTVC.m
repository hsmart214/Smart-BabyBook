//
//  SBTDocumentsTVC.m
//  Smart BabyBook
//
//  Created by J. HOWARD SMART on 9/13/15.
//  Copyright © 2015 J. HOWARD SMART. All rights reserved.
//

#import "SBTDocumentsTVC.h"
#import "SBTDocumentImage.h"

@interface SBTDocumentsTVC ()

@property (nonatomic, strong) NSArray<SBTDocumentImage*> *documents;

@end

@implementation SBTDocumentsTVC

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.documents count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Document Cell" forIndexPath:indexPath];
    cell.textLabel.text = self.documents[indexPath.row].title;
    return cell;
}

-(void)addDocument{
    NSLog(@"Pressed Add");
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addDocument)];
}

@end
