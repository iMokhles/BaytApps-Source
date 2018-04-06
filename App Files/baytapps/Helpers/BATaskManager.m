//
//  BATaskManager.m
//  baytapps
//
//  Created by iMokhles on 08/11/2016.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BATaskManager.h"
#import "ITHelper.h"
#import "BAHelper.h"

@implementation BATaskManager

+ (NSString *)identifier {
    return NSStringFromClass(self);
}

+ (NSOperation *)operationWithCompletion:(SLNTaskCompletion_t)completion {
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        if ([PFUser currentUser] == nil) {
//            // // NSLog(@"*********** didn't logIN");
        } else {
//            // // NSLog(@"*********** already loggedIN");
        }
        completion(UIBackgroundFetchResultNoData);
    }];
    return operation;
}

+ (CGFloat)averageResponseTime {
    return 5.0;
}

+ (SLNTaskPriority)priority {
    return SLNTaskPriorityHigh;
}

@end
