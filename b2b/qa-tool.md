# The CloudCutout QA Tool

The QA tool is our web application for inspecting, correcting, and approving cutouts
after they have been computed by our system. Watch [this video](https://vimeo.com/170768166) (password is `cloudcutout`) for a quick introduction to the tool.

## System requirements
- _Browser_: Newest version of Chrome **Currently other browsers are NOT supported**
- _Operating system_: Windows 8.1 or 10, OS X El Capitan (Linux support is experimental)
- At least 2.0 GHz CPU
- At least 8GB RAM
- GPU with at least 128MB dedicated memory 
- Fast and reliable internet connection (at least 20/10 Mbit/s up/down)

If you experience the tool being slow or unresponsive, you can try changing the parameters
`maxJobCache`, `maxImageSize` and `disableWebGL`. See the following section for further instructions.

## Parameters and settings
When accessing the QA tool in the browser, different parameters can be specified for changing the settings of the tool. Parameters are specified
in the URL after the `?` character. As an example, suppose you access the QA tool using the following URL:
```
https://qa-alt.cloudcutout.com/?queue_id=GREENSCREEN&order_id=myfirstorder
```
Here two parameters are specified:
- the parameter `queue_id` is assigned the value `GREENSCREEN`
- the parameter `order_id` is assigned the value `myfirstorder`

These parameters indicate that you want to QA the order named `myfirstorder` submitted to the queue named `GREENSCREEN`.
Note the user of `=` to assign a value to a parameter. Also note that the symbol `&` is used to separate different parameters.

Suppose we additionaly would like to specify the parameter `apikey` with a value of `1234567890`, then we would append `&apikey=1234567890` to the URL, so it becomes:
```
https://qa-alt.cloudcutout.com/?queue_id=GREENSCREEN&order_id=myfirstorder&apikey=123456789
```

Parameters can be specified in any order you like, so the above is equivalent to
```
https://qa-alt.cloudcutout.com/?apikey=123456789&order_id=myfirstorder&queue_id=GREENSCREEN
```

### List of parameters
Below is a list of possible parameters. Parameters marked as *advanced* or *experimental* should only be changed if you know exactly what you are doing.
- `order_id` (default value: none, **This parameter is mandatory**) 
    Specifies the name of the order you want to QA. 

- `queue_id` (default value: none, **This parameter is mandatory**) 
    Specifies the name of the queue that your order was placed in. 

- `apikey` (default value: none)
    This parameter can be used to specify an API key belonging to the user who should QA the order. If a valid API key is specified, the
user will be taken directly into the QA tool without the need to sign in. If the API key is not invalid or missing, then the user
will be prompted to sign in with username, password and a tag.

- `qa` (default value: `false`)
    By default the QA tool will display an *Order Overview* with a thumbnail for every image in the order. To start QA'ing the order the user must click the *QA this order now* button.
By setting this parameter to `true` the *Order Overview* will be skipped and the QA process will start immediately.

- `completeWaitingTime` (default value: `30`)
    The number of seconds that must passes from the user clicks the *Complete* button until the image is submitted to our servers. By default there is a delay of 30 seconds, 
    to make it possible to undo an accidential click on the *Complete* button. The countdown to completion is shown on the image thumbnail in the order overview.

- `maxImageSize` (default value: `1500`)
    Controls the resolution of the images in shown in browser. By default images with a width or height larger than 1500 pixels will be 
scaled down so their width and height is at most 2000 pixels. Note this setting only affects how you see the images in the QA tool -- 
the cutouts are always rendered in full resolution on our servers. Setting this parameter to `0` will disable downscaling and show
images in their full resolution. Doing so might make the tool very slow.

- `maxCachedJobs` (default value: `20`)
    Controls the number of images that will be preloaded in the background. If the next image has been preloaded, it can be displayed almost immediately. Otherwise, it will first have to 
    be downloaded from the server, and the user will see the `Loading next image...` message. Preloaded jobs are stored in memory, don't specify a large value unless you are confident your
    computer and internet connection can handle it.

- `disableWebGL` (default value: `false`, *advanced* )
    By default the QA tool will try to use WebGL to display the images. This means offloading computations to the GPU, and in some rare cases this can lead to problems. By setting this
    parameter to `true` the QA tool will run in a   

- `multitask` (default value: `false`, *advanced* )
    Setting this parameter to `true` will render alternatives in the background and allow the user QA other images until all alternatives are ready.

- `singleROI` (default value: `false`, *advanced* )
    Setting this parameter to `true` will limit the user to marking a single problem at a time.

# FAQ
- **Q: How do I report a bug/problem?**
A: Send an email to `hwv@cloudcutout.com` with a detailed description of the bug/problem. Please provide as much information as possible. As a minimum provide:
    - The exact time the problem occured (time zone included)
    - The username or apikey you used
    - The queue id
    - The order id

  If the problem is visual, please also provide a screenshot

 