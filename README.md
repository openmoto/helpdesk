# Helpdesk Admin Scripts
Windows Automation Scripts for the Helpdesk Admin

Github has been a great resource for me in learning powershell, still have lots to learn but figure it's about time I stated contributing back. The plan for this repo is to clean up some of my usable scripts to make them suitable for public consumption so it takes little or no work to implement in your own environment.
These scripts are no where near perfect but they work, so feel free to fork, modify and re-share.
If you run into issues, feel free to let me know but no guarantees.

# Projects : 

# Printer Automation
# Why: 
Print servers are great but have their own unique issues. A single print server issue can mean your users can't print across the board.
With network printers, you can install printers directly on computers, but that can be a pain to manage on it's own which is why companies like printlogic exist. This script provides an easier way of handling printer installations without the use of a print server or third party paid service.
One of the advantages to local printer installs is that you usually know exaclty where the issue is when someone can't print.
Really, 1 computer can't print but it can ping the printer, the issue is likely on the computer, more than one can't print and you can ping the printer it's more than likely a printer error. No need to introduce an extra server to maintain and troubleshoot
I understand that both print servers and local printer installations have their advantages and disadvantages, always weigh your options and risks then decide which works best with your situation. If your business revolves around being able to print and you can't afford printer downtime, I'm not sure it's a good idea to introduce another single point of failure in your printing process. If you have the budget for it, look at papercut or printlogic.

# How:
If you are just starting off or wish to migrate from print servers to direct installation of network printers locally on your machines, this two part script would help.
Edit lists.txt and list all the computers that already have the printers installed (or your print server)
Run Get-PrinterList.ps1 to gets list of printers from those computers and store in a CSV file
sample-printerreport.csv shows what your exported printer list would look like. Feel free to edit it and enter the exact prrinter drivers as they are named in the inf files. Editting the print driver names may be necessary if you are exporting from a very old install and using newer drivers. Also, you can update your printer name to use specific naming convention now.
On the end user side, run Install-Printer.ps1 to get a "Out-Grideview" of the list of printers, selecting a printer from this list will then install the printer.

Below is a screenshot of what you get when you run Install-Printer, once you select a printer, it gets installed
![alt text](https://github.com/openmoto/helpdesk/blob/master/PrinterAutomation/PrinterSelection.png)

# Notes:
Some improvements I would like to make is being able to install multiple printers at once, you can select multiple from the list but only one gets installed. This would be helpful for new deployments, but oh well. Feel free to fork and fix and I'll add the updated one.
Script requires to be run as admin, if you wish to allow users to install printers themselves, you can install the PSLauncher script and allow it to launch your scripts.
Even though you can use PSSession to run this on a remote computer, it would be great too to have a GUI to enter the computer name then select the printer(s) you want to install on it to kick off the job.
Errors for the Install-Printer script would be at C:\setup\printerlogs.txt, need to add timestamps at some point.


# PSLauncher - Powershell based application launcher
This script elevates approved applications using local Administrator credentials
Pretty much ready to use in any environment without editting it.

# Why:
Ideally, your LOB (end user) applications should not require admin rights to run, in my opinion, it's a horrible design.. But that's just me. However, you don't just hand out admin passwords or make users admin because of a poor software design, you're probably not in a position to change to a software that does same things without admin rights either, but you can allow specific apps to run as admin and there are probably over a dozen ways to do it including some paid solutions. This solution is just my way of solving the same problem. If you've seen my scripts it's pretty obvious I got a lot of help with this one.

# How:
The Manifest.json is a list of application you want users to be able to run as admin, it is pretty self explanatory. Just copy the json file to a web server where your client's can reach, edit the file to include all the apps you want them to be able to run as admin, on a computer that has those apps installed, run "Get-FileHash -Algorithm MD5 -Path 'exe file'", copy the file hash to the MD5 field for the program. This allows you to disable or allow only specific versions.
Once you are done, edit the PSLauncher.ps1 file to add your new json file and the local admin user account ($Script:username = "Admin"). Once you are ready, open powershell as admin in same folder then run  .\PSLauncher.ps1 -Application none -USPW "your local admin password".
This will copy the script to "C:\ProgramData\PSLauncher" and all log files will be added there, create a desktop shortcut on "C:\Users\Public\Desktop", add a registry key at "HKLM:\Software\PSLauncher", this includes the encrypted password (note that if you change $Script:AppName variable, the name of the path and files changes to whatever you put in there. 
To use the script, your users just need to drag and drop an approved app to the shortcut and it will launch as the admin specified.

# Warning:
Make sure you're the only one that has access to the json file or other apps can be allowed to run as admin
This script is probably best converted to an exe before use as someone can easily edit the ps1 file and link to a different json, you should notice that editting the ps1 file requires admin rights, so if a malicious actor is able to edit the file on your computers, you probably have bigger things to worry about.
Admin password is accepted in plain text so beware of SOS (someone over shoulder). you can always psexec or PSSession to the computer to install it.
If you open task manager and go to Details page, you will see the application running as the specified admin, so probably a very bad idea to run on a remote desktop server where multiple users may need to open the app at the same time.

