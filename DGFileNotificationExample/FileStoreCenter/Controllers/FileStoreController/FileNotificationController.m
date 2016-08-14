//
//  ViewController.m
//  Example_MDS
//
//  Created by Golubev Dmitry on 09.01.16.
//  Copyright © 2016 Golubev Dmitry. All rights reserved.
//

#import "FileNotificationController.h"

#import <DGFileNotification/DGFileNotificationCenter.h>
#import <DGFileNotification/DGFileNotificationTask.h>

@interface FileNotificationController () <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (strong, nonatomic) DGFileNotificationCenter *center;
@property (strong, nonatomic) DGFileNotificationTask *task;
@property (strong, nonatomic) NSMutableArray *notificatons;

@end

@implementation FileNotificationController

-(void)awakeFromNib
{
    self.task = [[DGFileNotificationCenter defaultCenter] newTask];
    self.notificatons = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    [self.task runTasK:YES handler:^(NSDictionary *userInfo) {
        __strong typeof(self) strongSelf = weakSelf;
        if(strongSelf) {
            [strongSelf.notificatons addObject:userInfo];
            [strongSelf.infoLabel removeFromSuperview];
            [strongSelf.tableView reloadData];
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60;
    self.tableView.tableFooterView = self.infoLabel;
    
    [self.tableView registerClass:UITableViewCell.class
           forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
}

- (IBAction) actionResume:(id)sender
{
    [self.task resume];
}

- (IBAction) actionCancel:(id)sender
{
    [self.task cancel];
}

#pragma mark - UITableViewController data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.notificatons count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIndetifier = NSStringFromClass(UITableViewCell.class);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndetifier
                                                            forIndexPath:indexPath];
    NSString *type = self.notificatons[indexPath.row][DGNotification];
    NSString *link = self.notificatons[indexPath.row][DGFilePath];
    NSString *textCell = [NSString stringWithFormat:@"LINK : %@ \n\nTYPE : %@", link, type];
    cell.textLabel.text = textCell;
    cell.textLabel.numberOfLines = 0;
    return cell;
}

-(void)dealloc
{
    [self.task removeFromCenter];
}

@end
