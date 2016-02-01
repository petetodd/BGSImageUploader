//
//  BGSImageUploader.h
//  BrightAssetManager
//
//  Created by Peter Todd Air on 23/09/2015.
//  Copyright © 2015 Bright Green Star. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol BGSImageUploaderDelegate
- (void)uploadURL:(NSString*)strURL;

@end

@interface BGSImageUploader : NSObject <NSURLConnectionDelegate, NSURLSessionDelegate>
@property (weak) id <BGSImageUploaderDelegate> delegate;

-(void)retrieveUploadUrl;
-(void)postImageToURL:(UIImage*)imageToPost urlStringForPost:(NSString*)urlString;
-(void)uploadImage:(UIImage*)image toURL:(NSURL*)url;


@end
