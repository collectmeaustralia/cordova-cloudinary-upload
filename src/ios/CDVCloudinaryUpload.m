#import "CDVCloudinaryUpload.h"

@implementation CDVCloudinaryUpload

@synthesize callbackId;
@synthesize cloudinary;

- (void)pluginInitialize {
	// self.cloudinary = [[CLCloudinary alloc] initWithUrl: @"cloudinary://123456789012345:abcdeghijklmnopqrstuvwxyz12@n07t21i7"];

	NSString *CloudName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CloudinaryCloudName"];
	NSString *APIKey = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CloudinaryAPIKey"];
	NSString *APISecret = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CloudinaryAPISecret"];
	
	self.cloudinary = [[CLCloudinary alloc] init];
	[self.cloudinary.config setValue:CloudName forKey:@"cloud_name"];
	[self.cloudinary.config setValue:APIKey forKey:@"api_key"];
	[self.cloudinary.config setValue:APISecret forKey:@"api_secret"];
}

- (void)upload:(CDVInvokedUrlCommand*)command {
	// self.callbackId = command.callbackId;

	// // convert file:// URL to a file path
	// NSURL *fileURL = [NSURL URLWithString:[command argumentAtIndex:0]];
	// NSString* target = [fileURL path];

	CDVCloudinaryUploadDelegate *delegate = [self delegateForUploadCommand:command];

	// the delegate should upload
	//[self.uploader upload:target options:@{}];
}


- (CDVCloudinaryUploadDelegate*)delegateForUploadCommand:(CDVInvokedUrlCommand*)command
{
    // convert file:// URL to a file path
	NSURL *fileURL = [NSURL URLWithString:[command argumentAtIndex:0]];
	NSString* uploadFilePath = [fileURL path];

    CDVCloudinaryUploadDelegate* delegate = [[CDVCloudinaryUploadDelegate alloc] init];

    delegate.command = self;
    delegate.callbackId = command.callbackId;
    delegate.uploadFilePath = uploadFilePath;

	delegate.uploader = [[CLUploader alloc] init:self.cloudinary delegate:delegate];

    delegate.backgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [delegate cancelUpload:delegate.uploader];
    }];

    [delegate.uploader upload:delegate.uploadFilePath options:@{}];

    // delegate.direction = CDV_TRANSFER_UPLOAD;
    // delegate.objectId = objectId;
    // delegate.source = source;
    // delegate.target = server;
    // delegate.trustAllHosts = trustAllHosts;
    // delegate.filePlugin = [self.commandDelegate getCommandInstance:@"File"];

    return delegate;
}

@end

@implementation CDVCloudinaryUploadDelegate

@synthesize command, callbackId, uploader, uploadFilePath;

- (void)cancelUpload:(CLUploader*)upload {
	[upload cancel];
	[[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskID];
}

// CLUploaderDelegate implementation
- (void) uploaderSuccess:(NSDictionary*)result context:(id)context {
    NSString* publicId = [result valueForKey:@"public_id"];
    NSLog(@"Upload success. Public ID=%@, Full result=%@", publicId, result);

    /*
    	Result Dictionary:

		{
		    bytes = 4909770;
		    "created_at" = "2015-03-31T00:07:28Z";
		    etag = b597ff0c861612585116a818a501c750;
		    format = jpg;
		    height = 2448;
		    "public_id" = chwgksklnhgkhpkrejtt;
		    "resource_type" = image;
		    "secure_url" = "https://res.cloudinary.com/collectmeau/image/upload/v1427760448/chwgksklnhgkhpkrejtt.jpg";
		    signature = 95a7ef5aefd3e495ffeabfe322c23b89ca02b9b4;
		    tags =     (
		    );
		    type = upload;
		    url = "http://res.cloudinary.com/collectmeau/image/upload/v1427760448/chwgksklnhgkhpkrejtt.jpg";
		    version = 1427760448;
		    width = 3264;
		}
    */
    NSLog(@"uploaderSuccess %@", result);

    // TODO: optionally delete the original image here, once it has been uploaded

    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
    [self.command.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
    // [self.command.commandDelegate sendPluginResult:result callbackId:callbackId];

    // remove connection for activeTransfers
    // @synchronized (command.activeTransfers) {
        // [command.activeTransfers removeObjectForKey:objectId];
        // remove background id task in case our upload was done in the background
      
    // NSLog(@"%@", self.backgroundTaskID);
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskID];
        // self.backgroundTaskID = UIBackgroundTaskInvalid;

    // }
}

- (void) uploaderError:(NSString*)result code:(int) code context:(id)context {
    NSLog(@"Upload error: %@, %d", result, code);

    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:[self createFileTransferError:code AndResult:result]];
    [self.command.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

- (void) uploaderProgress:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite context:(id)context {
    NSLog(@"Upload progress: %d/%d (+%d)", totalBytesWritten, totalBytesExpectedToWrite, bytesWritten);

    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[self createFileUploadProgressMessage:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite]];
    [pluginResult setKeepCallbackAsBool:true];
    [self.command.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

- (NSMutableDictionary*)createFileTransferSuccess:(NSString*) publicId {
    NSMutableDictionary* fileUploadSuccess = [NSMutableDictionary dictionaryWithCapacity:1];

    // [fileUploadError setObject:[NSNumber numberWithInt:code] forKey:@"code"];
    if (publicId != nil) {
        [fileUploadSuccess setObject:publicId forKey:@"publicId"];
    }
    NSLog(@"FileTransferSuccess %@", fileUploadSuccess);

    return fileUploadSuccess;
}

- (NSMutableDictionary*)createFileTransferError:(int)code AndResult:(NSString *)result {
    NSMutableDictionary* fileUploadError = [NSMutableDictionary dictionaryWithCapacity:2];

    [fileUploadError setObject:[NSNumber numberWithInt:code] forKey:@"code"];
    if (result != nil) {
        [fileUploadError setObject:result forKey:@"result"];
    }
    NSLog(@"FileTransferError %@", fileUploadError);

    return fileUploadError;
}

- (NSMutableDictionary*)createFileUploadProgressMessage:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    NSMutableDictionary* fileUploadProgress = [NSMutableDictionary dictionaryWithCapacity:2];

    [fileUploadProgress setObject:[NSNumber numberWithInt:totalBytesWritten] forKey:@"totalBytesWritten"];
    [fileUploadProgress setObject:[NSNumber numberWithInt:totalBytesExpectedToWrite] forKey:@"totalBytesExpectedToWrite"];

    NSLog(@"FileUploadProgressMessage %@", fileUploadProgress);

    return fileUploadProgress;
}

@end
