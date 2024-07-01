# chrome-profile-view

A Python web app for previewing data in Chrome/Chromium profile folder.

The tool is still very much in development, so if you find a bug or have a 
feature request, please submit them on the Issues tab in the GitHub repo. 

In the current version the following data types are supported (more coming 
soon!):

* History (including experimental browsing chains visualization)
* Cache
* Local Storage
* Session Storage
* IndexedDB

This tool also acts as an example application for our 
[ccl_chromium_reader](https://github.com/cclgroupltd/ccl_chromium_reader)
library for accessing data in a Chrom(e|ium) profile folder. 

## Screenshots
![Front page in v0.0.6](https://github.com/cclgroupltd/chrome-profile-view/assets/13645548/e91cba8a-a52f-4354-840f-f52381ec551e)

![History chain view in v0.0.6](https://github.com/cclgroupltd/chrome-profile-view/assets/13645548/eba94b30-26f5-49bd-a91c-10d3b8e5a8d8)

![Session Storage in v0.0.6](https://github.com/cclgroupltd/chrome-profile-view/assets/13645548/9d983911-0295-45ea-a0cd-3c9475893f71)



## Setting up the tool
The tool requires [Python](https://python.org) 3.10 or above. Once this is 
installed, download the code from this repository and put it in a folder.

The tool has a couple of dependencies which will need to be downloaded. We
recommend using a Python venv (virtual environment) for this.

From within a shell for the folder containing the source code you would do 
the following (substitute "py" for "python" if not on Windows):

```commandline
py -m venv .venv
./.venv/Scripts/activiate
pip install -r requirements.txt
```

Line by line this:
1. Initializes a new venv
2. Activates the venv
3. Installs the dependencies listed in the requirements.txt file

The first and final step is only required once per installation. The middle
step is required each time you open a new shell to run the tool.

### PowerShell Issues?

If you are using powershell and get an error message at step two, this is 
usually due to an execution policy violation. This can usually be fixed by
executing the following ahead of the operations listed above:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted
```

And once you're done, for safety, set the policy back to default:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Default
```

## Using the tool

Once the tool is set up launch it by providing the profile folder of interest
as a command-line argument, for example, on Windows:

```commandline
py chrome-profile-view "c:\Users\you\AppData\Local\Google\Chrome\User Data\Profile 1"
```

You can also provide a second argument which is the path to an external
cache folder if it is not stored directly within the profile folder (such
as is the case on Android). 

This will launch the local web-service; open a browser and point it to 
`http://localhost:40539`. Port `40539` is the default port that will be used, 
but this can be changed in the source code by setting the PORT variable to a 
different value.

Data is loaded on demand as you move between different views so a short delay
may be expected on occasion.
