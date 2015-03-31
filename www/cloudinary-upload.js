var exec = require('cordova/exec');

function CDVCloudinaryUpload() {}

CDVCloudinaryUpload.prototype.upload = function(successCallback, errorCallback, progressCallback, file) {
	if (typeof errorCallback != 'function') {
        console.log('CDVCloudinaryUpload.upload failure: failure parameter not a function');
        return;
    }

    if (typeof successCallback != 'function') {
        console.log('CDVCloudinaryUpload.upload failure: success callback parameter must be a function');
        return;
    }

    console.log(file);

    /*
		this is how we can support an "on progress" callback - just call the success callback from Objective C, and pass in different params.
    */
    var successOrProgressCallback = function(result) {
        if (typeof result.totalBytesWritten != "undefined") {
            if (progressCallback) {
                progressCallback({
                    totalBytesWritten: result.totalBytesWritten,
                    totalBytesExpectedToWrite: result.totalBytesExpectedToWrite
                });
            }
        } else {
            successCallback && successCallback(result);
        }
    };

    exec(successOrProgressCallback, errorCallback, 'Cloudinary', 'upload', [file]);
}

module.exports = new CDVCloudinaryUpload();