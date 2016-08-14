//
//  GDFileStoreNotificationCenter+PrivateInteface.h
//  Example_MDS
//
//  Created by Дмитрий Голубев on 21/01/16.
//  Copyright © 2016 Golubev Dmitry. All rights reserved.
//


#import "DGFileNotificationCenter.h"
#import "DGFileNotificationTask.h"

@interface DGFileNotificationCenter (PrivateInterface)

@property (strong, nonatomic) NSMutableArray <DGFileNotificationTask *> *tasks;

-(void)removeTask:(DGFileNotificationTask *)task;

@end
