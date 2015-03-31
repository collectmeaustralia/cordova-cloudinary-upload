#cordova-cloudinary-upload

Cordova plugin to upload images to [Cloudinary](http://cloudinary.com). Built to use in tandem with the Cordova Camera plugin.

Download the [Cloudinary iOS SDK](http://res.cloudinary.com/cloudinary/raw/upload/cloudinary_ios_v1.0.12.zip), or check the [GitHub repo](https://github.com/cloudinary/cloudinary_ios) for the latest build.

Unzip the build into ```src/ios/cloudinary_sdk``` to get the following structure:

```
	src/
		ios/
			cloudinary_sdk/
				libCloudinary.a
				include/
					Cloudinary/	
						CLCloudinary.h
						CLEagerTransformation.h
						...
```

To install:
```cordova plugin add PATH_TO_PLUGIN --variable CLOUD_NAME="xxx" --variable API_KEY="xxx" --variable API_SECRET="xxx"```

To remove:
```cordova plugin remove cordova.plugins.cloudinary```

## Usage

```javascript
navigator.camera.getPicture(onSuccess, onFail, { quality: 50,
    destinationType: Camera.DestinationType.FILE_URI
});

function onSuccess(imageData) {

	// image data should be a file:// URI, as returned from the Camera plugin
    cordova.plugins.cloudinary.upload(
        function(result){
            console.log('===== result =====');
            console.log(result);
            /*
				result is the JSON returned from Cloudinary on successful upload:

				{
				    bytes = 4299687;
				    "created_at" = "2015-03-31T05:24:52Z";
				    etag = 38825bcbea005ba3c5da79591625f098;
				    format = jpg;
				    height = 2448;
				    "public_id" = e9fz4zcrvf5n4clmlh1s;
				    "resource_type" = image;
				    "secure_url" = "https://.../e9fz4zcrvf5n4clmlh1s.jpg";
				    signature = d87e52bd9facd534cf2c6bdc3a6707a97036232c;
				    tags =     (
				    );
				    type = upload;
				    url = "http://.../e9fz4zcrvf5n4clmlh1s.jpg";
				    version = 1427779492;
				    width = 3264;
				}
            */
        },
        function(error){
            console.log('===== error =====');
            console.log(error);
        },
        function(progress){
            console.log('===== progress =====');
            console.log(progress);

            /*
				progress: {
					totalBytesWritten: [total number of bytes written so far]
					totalBytesExpectedToWrite: [total number of bytes for the file]
				}
            */
        },
        imageData
    );
}

function onFail(message) {
    console.log('Failed because: ' + message);
}
```