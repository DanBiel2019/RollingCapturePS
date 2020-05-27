# RollingCapturePS
Rolling Capture using netsh

Please review the script and make changes as needed to conform to your requirements.  This script is not an official Microsoft script and it is provided as a reference only.  It needs to be adapted and validated to run in your specific environment.  As this is an unsupported script, using it and troubleshooting issues will be on your own.  

If you are new to running custom functions, please follow these steps.
First, load the function into your PS Session
Let’s assume you downloaded the script to c:\downloads
You would run PowerShell as admin and then enter  . c:\downloads\RollingCapture.ps1
Then, you would run the script, which is Start-RollingCapture -hours 4 (assuming you want to keep 4 hours of captures)
 
Again, the above steps are assuming the script was unmodified.   The actual script functionality will depend upon customizations done to fit to your environment.
