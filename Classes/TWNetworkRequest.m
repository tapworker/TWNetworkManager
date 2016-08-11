//
//  TWNetworkRequest.m
//  Pods
//
//  Created by Christian Menschel on 16/02/16.
//
//

#import "TWNetworkRequest.h"

@implementation TWNetworkRequest
{
    NSString *_postParametersAsString;
}

#pragma mark - LifeCycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _timeout = 60.0;
    }
    return self;
}

#pragma mark - Setter

- (void)setPostParameters:(NSDictionary *)postParameters {
    if (![_postParameters isEqual:postParameters]) {
        _postParameters = postParameters;
        if (!postParameters) {
            _postParametersAsString = nil;
        } else {
            NSMutableString *postString = nil;
            for (NSString *key in postParameters) {
                if (!postString) {
                    [postString appendString:@"&"];
                }
                NSString *value = postParameters[key];
                [postString appendFormat:@"%@=%@", key, value];
            }
            _postParametersAsString = postString;
        }
    }
}

#pragma mark - Getter

- (NSString *)HTTPMethod
{
    NSString *HTTPMethod = @"GET";
    switch (self.type) {
        case TWNetworkHTTPMethodGET:
            HTTPMethod = @"GET";
            break;
        case TWNetworkHTTPMethodPOST:
            HTTPMethod = @"POST";
            break;
        case TWNetworkHTTPMethodDELETE:
            HTTPMethod = @"DELETE";
            break;
        case TWNetworkHTTPMethodPUT:
            HTTPMethod = @"PUT";
            break;
        case TWNetworkHTTPMethodHEAD:
            HTTPMethod = @"HEAD";
            break;
        case TWNetworkHTTPMethodPatch:
            HTTPMethod = @"PATCH";
            break;
    }

    return HTTPMethod;
}

- (NSString *)HTTPAuth
{
    if (_URLRequest.HTTPMethod) {
        return _URLRequest.HTTPMethod;
    }
    NSString *authStr = nil;
    if (self.username) {
        authStr = self.username;
    }
    if (self.password) {
        authStr = [authStr stringByAppendingFormat:@":%@", self.password];
    }
    if (!authStr) {

        return nil;
    }

    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [authData base64Encoding];

    return authValue;
}

- (NSTimeInterval)timeout
{
    if (_URLRequest) {
        return _URLRequest.timeoutInterval;
    }

    return _timeout;
}

- (NSURL *)URL
{
    if (_URLRequest.URL) {
        return _URLRequest.URL;
    }

    return _URL;
}

- (NSURLRequest *)URLRequest
{
    if (_URLRequest) {
        return _URLRequest;
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:self.URL
                                    cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                    timeoutInterval:self.timeout];

    [request setHTTPMethod:self.HTTPMethod];
    if ([self HTTPAuth]) {
        NSString *value = [NSString stringWithFormat:@"Basic %@", [self HTTPAuth]];
        [request setValue:value forHTTPHeaderField:@"Authorization"];
    }
    if (self.postParameters && _postParametersAsString) {
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[_postParametersAsString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return request;
}

@end
