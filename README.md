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

The final step is only required once per installation. The first two
steps are required each time you open a new shell to run the tool.

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

This will launch the local web-service; open a browser and point it to 
`http://localhost:40539`. Port `40539` is the default port that will be used, 
but this can be changed in the source code by setting the PORT variable to a 
different value.

Data is loaded on demand as you move between different views so a short delay
may be expected on occasion.