//
//  ITAppObject.m
//  ioteam
//
//  Created by iMokhles on 02/06/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "ITAppObject.h"

@implementation ITAppObject
- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.appSection forKey:@"appSection"];
    [encoder encodeObject:self.appTrackID forKey:@"appTrackID"];
    [encoder encodeObject:self.appName forKey:@"appName"];
    
    [encoder encodeObject:self.appID forKey:@"appID"];
    [encoder encodeObject:self.appVersion forKey:@"appVersion"];
    [encoder encodeObject:self.appIcon forKey:@"appIcon"];
    [encoder encodeObject:self.appPrice forKey:@"appPrice"];
    [encoder encodeObject:self.appStore forKey:@"appStore"];
    [encoder encodeObject:self.appDescription forKey:@"appDescription"];
    [encoder encodeObject:self.appScreenshots forKey:@"appScreenshots"];
    [encoder encodeObject:self.fileSizeBytes forKey:@"fileSizeBytes"];
    [encoder encodeObject:self.appInfo forKey:@"appInfo"];
    [encoder encodeObject:self.locallink forKey:@"locallink"];

}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.appSection = [decoder decodeObjectForKey:@"appSection"];
        self.appTrackID = [decoder decodeObjectForKey:@"appTrackID"];
        self.appName = [decoder decodeObjectForKey:@"appName"];
        
        self.appID = [decoder decodeObjectForKey:@"appID"];
        self.appVersion = [decoder decodeObjectForKey:@"appVersion"];
        self.appIcon = [decoder decodeObjectForKey:@"appIcon"];
        self.appPrice = [decoder decodeObjectForKey:@"appPrice"];
        self.appStore = [decoder decodeObjectForKey:@"appStore"];
        self.appDescription = [decoder decodeObjectForKey:@"appDescription"];
        self.appScreenshots = [decoder decodeObjectForKey:@"appScreenshots"];
        self.fileSizeBytes = [decoder decodeObjectForKey:@"fileSizeBytes"];
        self.appInfo = [decoder decodeObjectForKey:@"appInfo"];
        self.locallink = [decoder decodeObjectForKey:@"locallink"];

        
    }
    return self;
}
@end
