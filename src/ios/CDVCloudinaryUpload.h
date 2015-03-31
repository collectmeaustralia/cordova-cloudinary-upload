//
//  ZBarScanner.h
//  CollectMe
//
//  Created by Michael Black on 28/01/2014.
//
//

#import <Cordova/CDVPlugin.h>

#import "Cloudinary.h"

@interface CDVCloudinaryUpload : CDVPlugin 

@property (nonatomic, copy) NSString *callbackId;

@property (nonatomic, retain) CLCloudinary *cloudinary;

- (void) upload:(CDVInvokedUrlCommand*)command;

// - (NSMutableDictionary*)createFileTransferSuccess:(NSString*) publicId;
// - (NSMutableDictionary*)createFileTransferError:(int)code AndResult:(NSString *)result;
// - (NSMutableDictionary*)createFileUploadProgressMessage:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;


@end



@interface CDVCloudinaryUploadDelegate : NSObject <CLUploaderDelegate> {}

@property (nonatomic, strong) CDVCloudinaryUpload* command;
@property (nonatomic, copy) NSString* callbackId;
@property (nonatomic, copy) NSString* uploadFilePath;
@property (nonatomic, retain) CLUploader *uploader;
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskID;

- (void)cancelUpload:(CLUploader*)upload;

// CLUploaderDelegate
- (void) uploaderSuccess:(NSDictionary*)result context:(id)context;
- (void) uploaderError:(NSString*)result code:(int) code context:(id)context;
- (void) uploaderProgress:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite context:(id)context;

@end