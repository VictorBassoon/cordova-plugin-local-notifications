/*
 * Copyright (c) 2013-2015 by appPlant UG. All rights reserved.
 *
 * @APPPLANT_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apache License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://opensource.org/licenses/Apache-2.0/ and read it before using this
 * file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPPLANT_LICENSE_HEADER_END@
 */

#import "UNMutableNotificationContent+APPLocalNotification.h"
#import "APPLocalNotificationOptions.h"
#import <objc/runtime.h>

@import UserNotifications;

static char optionsKey;

@implementation UNMutableNotificationContent (APPLocalNotification)

#pragma mark -
#pragma mark Init

/**
 * Initialize a notification with the given options.
 *
 * @param [ NSDictionary* ] dict A key-value property map.
 *
 * @return [ UNMutableNotificationContent ]
 */
- (id) initWithOptions:(NSDictionary*)dict
{
    self = [self init];

    [self setUserInfo:dict];
    [self __init];

    return self;
}

/**
 * Initialize a notification by using the options found under userInfo.
 *
 * @return [ Void ]
 */
- (void) __init
{
    APPLocalNotificationOptions* options = self.options;

    self.title    = options.title;
    self.subtitle = options.subtitle;
    self.body     = options.text;
    self.sound    = options.sound;
    self.badge    = options.badge;
}

#pragma mark -
#pragma mark Public

/**
 * The options used to initialize the notification.
 *
 * @return [ APPLocalNotificationOptions* ] options
 */
- (APPLocalNotificationOptions*) options
{
    APPLocalNotificationOptions* options = [self getOptions];

    if (!options) {
        options = [[APPLocalNotificationOptions alloc]
                   initWithDict:[self userInfo]];

        [self setOptions:options];
    }

    return options;
}

/**
 * The notifcations request ready to add to the notification center including
 * all informations about trigger behavior.
 *
 * @return [ UNNotificationRequest* ]
 */
- (UNNotificationRequest*) request
{
    APPLocalNotificationOptions* opts = [self getOptions];
    
    return [UNNotificationRequest requestWithIdentifier:opts.identifier
                                                content:self
                                                trigger:opts.trigger];
}

/**
 * Encode the user info dict to JSON.
 *
 * @return [ NSString* ]
 */
- (NSString*) encodeToJSON
{
    NSString* json;
    NSData* data;
    NSMutableDictionary* obj = [self.userInfo mutableCopy];
    
    [obj removeObjectForKey:@"updatedAt"];
    
    if (obj == NULL || obj.count == 0)
        return json;
    
    data = [NSJSONSerialization dataWithJSONObject:obj
                                           options:NSJSONWritingPrettyPrinted
                                             error:NULL];
    
    json = [[NSString alloc] initWithData:data
                                 encoding:NSUTF8StringEncoding];
    
    return [json stringByReplacingOccurrencesOfString:@"\n"
                                           withString:@""];
}

#pragma mark -
#pragma mark Private

/**
 * The options used to initialize the notification.
 *
 * @return [ APPLocalNotificationOptions* ]
 */
- (APPLocalNotificationOptions*) getOptions
{
    return objc_getAssociatedObject(self, &optionsKey);
}

/**
 * Set the options used to initialize the notification.
 *
 * @param [ NSDictionary* ] dict A key-value property map.
 *
 * @return [ Void ]
 */
- (void) setOptions:(APPLocalNotificationOptions*)options
{
    objc_setAssociatedObject(self, &optionsKey,
                             options, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
