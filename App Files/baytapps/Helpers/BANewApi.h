//
//  BANewApi.h
//  baytapps
//
//  Created by iMokhles on 25/06/2017.
//  Copyright © 2017 imokhles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITAppObject.h"
#import "URLConnection.h"

@interface BANewApi : NSObject

+(BANewApi *)sharedInstance;

- (void)downloadIPAFileForApp:(ITAppObject *)app
                      appIcon:(NSString *)appIconPath
                      appName:(NSString *)appNameString
                      appLink:(NSString *)appLink
                   appVersion:(NSString *)appVersion
                     hostName:(NSString *)host
                    duplicate:(NSInteger )dupliNumber
              completionBlock:(URLConnectionCompletionBlock)completionBlock
                   errorBlock:(URLConnectioErrorBlock)errorBlock
          uploadPorgressBlock:(URLConnectioUploadProgressBlock)uploadBlock
        downloadProgressBlock:(URLConnectioDownloadProgressBlock)downloadBlock;

@end
