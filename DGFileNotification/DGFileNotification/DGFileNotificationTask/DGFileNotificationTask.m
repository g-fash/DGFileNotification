//
//  FileStoreTask.m
//  Example_MDS
//
//  Created by Дмитрий Голубев on 21/01/16.
//  Copyright © 2016 Golubev Dmitry. All rights reserved.
//

#import "DGFileNotificationTask.h"
#import "DGFileNotificationCenter.h"
#import "DGFileNotificationCenter+PrivateInterface.h"

@interface DGFileNotificationTask ()

@property (strong, nonatomic, readwrite) DGFileNotificationHandler handler;
@property (assign, nonatomic, readwrite) BOOL running;

@end

@implementation DGFileNotificationTask

- (void) runTasK:(BOOL)run handler:(DGFileNotificationHandler)handler
{
    self.running = run;
    self.handler = handler;
}

- (void) removeFromCenter
{
    [[DGFileNotificationCenter defaultCenter] removeTask:self];
}
- (void)cancel
{
    self.running = NO;
}
- (void)resume
{
    self.running = YES;
}

@end
