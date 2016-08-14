//
//  GDFileStoreNotificationCenter+PrivateInteface.m
//  Example_MDS
//
//  Created by Дмитрий Голубев on 21/01/16.
//  Copyright © 2016 Golubev Dmitry. All rights reserved.
//

#import "DGFileNotificationCenter+PrivateInterface.h"
#import <pthread.h>

@implementation DGFileNotificationCenter (PrivateInterface)

@dynamic tasks;

-(void)removeTask:(DGFileNotificationTask *)task
{
    pthread_mutex_t lock;
    pthread_mutex_lock(&lock);
    [self.tasks removeObject:task];
    pthread_mutex_unlock(&lock);
}

@end
