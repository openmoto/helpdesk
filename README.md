# Helpdesk Admin Scripts
Windows Automation Scripts for the Helpdesk Admin

Github has been a great resource for me in learning powershell, still have lots to learn but figure it's about time I stated contributing back. The plan for this repo is to clean up some of my usable scripts to make them suitable for public consumption so it takes little or no work to implement in your own environment.
These scripts are no where near perfect but they work, so feel free to fork, modify and re-share.
If you run into issues, feel free to let me know but no guarantees.

# Projects : 

# Printer Automation
Print servers are great but have their own unique issues. A single print server issue can mean your users can't print across the board.
With network printers, you can install printers directly on computers, but that can be a pain to manage on it's own which is why companies like printlogic exist. This script provides an easier way of handling printer installations without the use of a print server or third party paid service.
One of the advantages to local printer installs is that you usually know exaclty where the issue is when someone can't print.
Really, 1 computer can't print but it can ping the printer, the issue is likely on the computer, more than one can't print and you can ping the printer it's more than likely a printer error. No need to introduce an extra server to maintain and troubleshoot
I understand that both print servers and local printer installations have their advantages and disadvantages, always weigh your options and risks then decide which works best with your situation. If your business revolves around being able to print and you can't afford printer downtime, I'm not sure it's a good idea to introduce another single point of failure in your printing process. If you have the budget for it, look at papercut or printlogic.

Below is a screenshot of what you get when you run Install-Printer, once you select a printer, it gets installed
![alt text](https://github.com/openmoto/helpdesk/blob/master/PrinterAutomation/PrinterSelection.png)

# PSLauncher - Powershell based application launcher
This script elevates approved applications using local Administrator credentials
Pretty much ready to use in any environment without editting it.
Ideally, your LOB (end user) applications should not require admin rights to run, in my opinion, it's a horrible design.. But that's just me. However, you don't just hand out admin passwords or make users admin because of a poor software design, you're probably not in a position to change to a software that does same things without admin rights either, but you can allow specific apps to run as admin and there are probably over a dozen ways to do it including some paid solutions. This solution is just my way of solving the same problem. If you've seen my scripts it's pretty obvious I got a lot of help with this one.

# TinyUserManager - Powershell based GUI tool for managing Active Directory users
While there is no shortage of Acrive Directory management powershell tools, I built this one as a part of my learning process as well as handle user management the way my current workplace does it. I open it once I start my day and it stays open till I'm done for the day and provides me a quick way to pick user when they call in for account related issues and see in one view all the information about that user that's important for me to troubleshoot their account related issue.
