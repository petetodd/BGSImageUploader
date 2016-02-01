//
//  BGSImageUploader.m
//  BrightAssetManager
//
//  Created by Peter Todd Air on 23/09/2015.
//  Copyright © 2015 Bright Green Star. All rights reserved.
//

#import "BGSImageUploader.h"
// Google endpoints
// User
#import "GTLUserEndpoint.h"
// Company
#import "GTLCompanyEndpoint.h"

#import "GTMHTTPFetcherLogging.h"
#import "GTLUserEndpointCallbackResult.h"

#define TIMEOUT_SECONDS 10


@implementation BGSImageUploader
{
    NSTimer * _timer;
    int _timerDurationCount;
    GTLServiceTicket * _ticket;
    
    NSMutableData * _receivedData;

}

#pragma mark - Retrieve Upload URL

/*
 Retrieve the URL we need to call to upload image
 */
-(void)retrieveUploadUrl
{
    GTLServiceCompanyEndpoint *service = [self companyService];
    
    GTLQueryCompanyEndpoint *query = [GTLQueryCompanyEndpoint queryForCreateUploadUrl];

    
    
    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLCompanyEndpointCallbackResult *object, NSError *error) {
        
        int redcode = [[object JSONValueForKey:@"redcode"] intValue];
        NSString *gaeData = [object JSONValueForKey:@"data"] ;
        
        NSLog(@"DEBUG retrieveUploadUrl redcode : %i",redcode);
        NSLog(@"DEBUG retrieveUploadUrl userData : %@",gaeData);
        
        if (redcode == 1)
        {
            [self.delegate uploadURL:gaeData];
            
        }else
        {
            [self.delegate uploadURL:Nil];
        }
        
    }];
    
    
}

#pragma mark - URL Post Calls

-(void)uploadImage:(UIImage*)image toURL:(NSURL*)url
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *strToken = [prefs objectForKey:@"userToken"];
    
    
    _receivedData = [[NSMutableData alloc]init];
    //  NSData *imageData = UIImagePNGRepresentation(image);
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    // Boundary is used to seperate the parts of multipart form.  Can be any text
    NSString *boundary = @"---XXXXXXX---";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSString *fileName = @"company";
    NSMutableData *body = [NSMutableData data];
    
    
    
    
    //--------------for upload token----------------------//
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"token"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", strToken] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@.jpg\"\r\n", fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    // NSLog(@"DEBUG image string ORIGINAL : %@", [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@.jpg\"\r\n", fileName] );
    
    // NSLog(@"DEBUG image string : %@", [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\";filename=\"%@.jpg\"; token=\"%@\"\r\n", fileName, strToken] );
    //[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\";filename=\"%@.jpg\"; token=\"%@\"\r\n", fileName, strToken] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[@"Content-Type: image/jpg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    
    
    // Create url connection and fire request
    _receivedData = [NSMutableData dataWithCapacity: 0];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
    {
        _receivedData = nil;
        //NSLog(@"did not connect");
    }
    
    /*
     
     [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
     [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\";filename=\"%@.jpg\"; token=\"%@\"\r\n", fileName, strToken] dataUsingEncoding:NSUTF8StringEncoding]];
     [body appendData:[@"Content-Type: image/jpg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
     [body appendData:[NSData dataWithData:imageData]];
     [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
     
     [request setHTTPBody:body];
     
     NSError *error;
     NSString *strData = [NSJSONSerialization JSONObjectWithData:body options:0 error:&error];
     //NSLog(@"DEBUG strdata BODY: %@",strData);
     
     */
    
}


#pragma mark - URLSession Delegates

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
    NSInteger responseStatusCode = [httpResponse statusCode];
    NSLog(@"DEBUG responseStatusCode  : %li",(long)responseStatusCode );
    //  if (responseStatusCode == 201) _routePostStatus=@"CREATED";
    
    NSDictionary *headerDictionary;
    headerDictionary = [httpResponse allHeaderFields] ;
    for (int i = 0; i< headerDictionary.count;i++){
        //NSString *keyString = [[headerDictionary allKeys] objectAtIndex:i];
        //NSLog(@"Keystring : %@",keyString);
        //NSLog(@"DEBUG keyString value : %@",[headerDictionary valueForKey:keyString]);
        
    }
    
    
    
    
    //NSLog(@"### handler 1");
    //NSLog(@"DEBUG Response:%@ ", response);
    //    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
    //NSDictionary *reponseHeaders = [httpResponse allHeaderFields];
    //NSLog(@"DEBUG location : %@",[reponseHeaders objectForKey:@"Location"]);
    
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    NSLog(@"DEBUG URLSession  didReceiveData");

    if (![data bytes]){
        return;
    }else
    {
        NSError *jsonParsingError = nil;
        
        NSDictionary *urlResponseDataDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        //   _sharingRef = [[urlResponseDataDict valueForKey:@"id"] stringValue];
        
        
        for (int i = 0; i< urlResponseDataDict.count;i++){
            // NSString *keyString = [[urlResponseDataDict allKeys] objectAtIndex:i];
            //NSLog(@"Keystring : %@",keyString);
            //NSLog(@"DEBUG keyString value : %@",[urlResponseDataDict valueForKey:keyString]);
            
        }
        
    }
    
    //NSLog(@"### handler 2");
    
    //    NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"Received String %@",str);
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    NSLog(@"DEBUG handler 3");
    
    
}

-(void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    NSLog(@"DEBUG handler 5");
    NSLog(@"didReceiveChallenge session challenge");
    
}


#pragma mark - Timer

-(void)durationStart{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(increaseTimerCount) userInfo:nil repeats:YES];
}

-(void)cancelTimer
{
    [_timer invalidate];
}

-(void)durationEnd{
    [_timer invalidate];
    [_ticket cancelTicket];
}

- (void)increaseTimerCount
{
    _timerDurationCount++;
    if (_timerDurationCount > TIMEOUT_SECONDS) [self durationEnd];
}

-(void)outOfTime
{
    NSLog(@"DEBUG OUTOFTIME retrieveUploadUrl outOfTime");

}



// Remote API handling.
// Company
- (GTLServiceCompanyEndpoint *)companyService {
    static GTLServiceCompanyEndpoint *service = nil;
    if (!service) {
        service = [[GTLServiceCompanyEndpoint alloc] init];
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically
        service.retryEnabled = NO;
        
        [GTMHTTPFetcher setLoggingEnabled:YES];
    }
    return service;
}



@end
