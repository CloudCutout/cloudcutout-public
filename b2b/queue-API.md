## CloudCutout API documentation
This provides documentation and [example](#demo) for the CloudCutout queue API. 

The following endpoints are provided to submit, query and download images. Replace `[TOKEN]` with the API key you receive from CloudCutout. Replace `[QUEUE_ID]` with the queue ID you receive from CloudCutout.

Prepend all endpoints with `https://api2.cloudcutout.com/cloudcutout-workflow-job-service/rest/`.

#### Submit image
Use this endpoint to submit an image for processing and obtain a job ID. `[FILENAME]` (optional) is the filename you want to register for the file. `[ORDER_ID]` (optional) is the order ID you want associated with this image. You can include a JSON structure of tags for the specific image (see [tags](#tags) below).

```
POST /queue/[QUEUE_ID]/todo?token=[TOKEN]
File as a FormDataParam
order_id as FormDataParam
job_tags as FormDataParam
Returns: The registered job UUID
```
If you submit a previously submitted image (same filename and MD5 sum), the jobid of said image will be returned.


#### Query the status of an image
Use this endpoint to get a single string describing the status of the job. 

```
GET /queue/[QUEUE_ID]/[JOBID]/status?token=[TOKEN]
Returns: String describing the status, e.g., 'processing', 'error', 'qa', 'photoshop'.
```

Note that the set of returned statuses depend on the agreement with CloudCutout.

#### Query the statuses of an entire order
Use this endpoint to get a histogram of statuses:

```
GET /queue/[QUEUE_ID]/order/[ORDER_ID]/status?token=[TOKEN]
Returns: JSON dictionary with number of jobs in each status, e.g.:
{
"processing": 10, 
"delivered": 5
}
```

#### Get download link for file
This endpoint provides the download link for the processed job. Returns an empty string if the file is not yet ready to be downloaded.
```
GET /queue/[QUEUE_ID]/[JOBID]?token=[TOKEN]
Returns: Download link for the processed file
```

#### Submit final cutout
The final corrected cutout can be submitted via this endpoint.

```
POST /queue/[QUEUE_ID]/[JOBID]/done?token=[TOKEN]
File as a FormDataParam
Returns: The job ID
```

#### Tags <a name="tags"></a>
Tags can be associated with an entire order or specific jobs. Currently supported tags are:

```
"symbol": "star"   // Show a star symbol in the QA tool 
"cropbox": "x,y,w,h,label"  // x,y,w,h should be decimal values between 0 and 1 (inclusive) indicating the position and size of the crop box relative to the width and height of the image. label is optional and specifies a string, which should be displayed in the upper left corner of the crop box.
```

The JSON structure with job tags could look like this:
```
job_tags = '{"symbol":"star","cropbox": "0.25,0.15,0.5,0.7,5-by-7 portrait"}'
```

### Example  <a name="demo"></a>
This is a live example, where you can try to submit images yourself to a demo queue. The demo is using cURL, but any client capable of performing HTTP requests can be used. 

First set the API key to use in this example (use the one you received from CloudCutout!):  
```
token=aaaabbbb-cccc-dddd-eeee-ffffgggghhhh
```
If you have not received any API key you can use this one: d0c27f91-758c-4a34-9af4-cdfe6ec93779

**(optional)** Download the files used in the demo:
```
wget https://s3-us-west-1.amazonaws.com/cloudcutout-web/bayes.jpg 
wget https://s3-us-west-1.amazonaws.com/cloudcutout-web/bayes_final.png 
```

Okay, let's see which queues are available:
```
$ curl -k -X GET "https://api2.cloudcutout.com/cloudcutout-workflow-job-service/rest/queue?token=${token}"

[{
	"customer": "demo",
	"externalQueueId": "demo",
	"description": "Publicly available demo (dummy) queue used to test REST API access and functionality",
	"due": 48.0,
	"price": 0.0
}]
```
Okay, so we have the 'demo' queue available with a processing time of 48 hours - and it's free! 

Let's submit an image to the queue. Take a JPEG of your own choice, or, if you don't have any data at hand you can always use [bayes.jpg](https://s3-us-west-1.amazonaws.com/cloudcutout-web/bayes.jpg).

And then submit it as a job for cutting out:
```
$ curl -k -F "file=@bayes.jpg;filename=thomas01.jpg" -X POST "https://api2.cloudcutout.com/cloudcutout-workflow-job-service/rest/queue/demo/todo?token=${token}"
a9a5de5a-a0ea-11e5-8994-feff819cdc9f
```
Note that you will get a different job ID each time you submit. This is the unique identifier for the job.
Also note that we here used the freedom to specify a different filename for future reference, namely "thomas01.jpg".

#### Querying the status
Now it's time to monitor the job's progress through. We'll save the job ID as a variable to make it easier to follow the example. Let's immediately get the status:
```
$ jobid=a9a5de5a-a0ea-11e5-8994-feff819cdc9f
$ curl -k -X GET "https://api2.cloudcutout.com/cloudcutout-workflow-job-service/rest/queue/demo/${jobid}/status?token=${token}"
processing
```
If you were fast enough, this returns the string _processing_. Ok, since this is a live demo you'll have to wait for the job to arrive in the expected state, before downloading. Grab some coffee, **wait 5-15 minutes**.

tic, toc...

Ok, welcome back. Now query for the status again:
```
$ curl -k -X GET "https://api2.cloudcutout.com/cloudcutout-workflow-job-service/rest/queue/demo/${jobid}/status?token=${token}"
qa
```

(note that this status can differ, depending on what you have agreed with CloudCutout on)

That means that the cutout is ready for inspection. Let's get the download URL and download the image to local disk:
```
$ url=$(curl -k -X GET "https://api2.cloudcutout.com/cloudcutout-workflow-job-service/rest/queue/demo/${jobid}?token=${token}")
$ echo ${url}
http://ddcs5o3rgr3a2.cloudfront.net/test/f9ca50bb-f09e-44fe-930e-ba8c0bce96d8_cutout.1.png?Expires=1451303442&Signature=Jjr5U0CriEJbVNoHB2NqemWoYL95WcrchUkXbHG4m7lWLA-N247SBAlG1PEFPy7Xj7-jUqx55T8VUfh9lODBmxa-dJmtEskqujliToKAkzTeORpQ9gMBCRsvEv2QUmXmsXexkUEJtne3RQlSdGjwYnzAWAKHWb0R0dSeHPmbsmz7d4fOzA-VzDEBqiMN4q36wAvSB7elXqch6V8DX4T9NgO3ng8v3qIoMeRSFJd-ngorczg1TN7q6znD~1dKxTKk~mJsXJc3kx1W7MbGmHR9e~I~YHaFpM0r89fVsSFqhExBEbURDfaVdv5~zU5OTSHz6HrVOTYdA0ZZHOnpioG4dg__&Key-Pair-Id=APKAJN3KYHX2CMAYYZOA
$ wget ${url} -O cutout.png
```
The downloaded image should look something like this:

![The produced cutout.png](https://s3-us-west-1.amazonaws.com/cloudcutout-web/bayes_cutout.png)

Note: If you are using the QA tool, the image is ready for that when it is in 'qa'. After QA'ing it will be in either 'photoshop' or 'delivered' when you query for the status.

If you have an API key, the queue ID and the order ID you can QA an entire order by going to the following link:
[https://qa-alt.cloudcutout.com/?apikey=[TOKEN]&queue_id=[QUEUE_ID]&order_id=[ORDER_ID]](https://qa-alt.cloudcutout.com/?apikey=[TOKEN]&queue_id=[QUEUE_ID]&order_id=[ORDER_ID])

That's it! You got a cutout from the system, edited/QA'ed it and submitted the final version.

Thank you for using the CloudCutout API!

### Tips & tricks
If you want cURL to output _just_ the HTTP status code (useful for branching), you can use 
```
$ curl -s -o /dev/null -w "%{http_code}" ...
[source: http://superuser.com/questions/272265/getting-curl-to-output-http-status-code]
```
