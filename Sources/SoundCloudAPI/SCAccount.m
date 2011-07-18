//
//  SCAccount.m
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 15.07.11.
//  Copyright 2011 Nxtbgthng. All rights reserved.
//

#if TARGET_OS_IPHONE
#import "NXOAuth2.h"
#else
#import <OAuth2Client/NXOAuth2.h>
#endif

#import "SCRequest.h"
#import "SCConstants.h"

#import "SCAccount+Private.h"
#import "SCAccount.h"

@implementation SCAccount

//@synthesize oauthAccount;

- (void)dealloc;
{
    [oauthAccount release];
    [super dealloc];
}

#pragma mark Accessors

- (NSString *)identifier;
{
    return self.oauthAccount.identifier;
}

- (NSDictionary *)userInfo;
{
    return (NSDictionary *)self.oauthAccount.userData;
}

- (void)setUserInfo:(NSDictionary *)userInfo;
{
    self.oauthAccount.userData = userInfo;
}

- (void)fetchUserInfoWithComplitionHandler:(void(^)(BOOL success, SCAccount *account, NSError * error))handler;
{
    [[handler copy] autorelease];
    
    [SCRequest requestWithPath:@"/me.json"
                   parameters:nil
                requestMethod:@"GET"
                      account:self
              responseHandler:^(NSData *data, NSError *error){
                  if (error) {
                      handler(NO, self, error);
                  } else {
                      NSError *jsonError = nil;
                      NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                      if (result) {
                          self.userInfo = result;
                          [[NSNotificationCenter defaultCenter] postNotificationName:SCAccountDidChangeUserInfo object:self];
                          handler(YES, self, nil);
                      } else {
                          handler(NO, self, jsonError);
                      }
                  }
              }];
}

@end
