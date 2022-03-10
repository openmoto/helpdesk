To add new domain to manage, create a new folder with the domain name and copy the contents of template folder to it.
Instructions for setting up the config file adapted from here [https://psgsuite.io/Initial%20Setup/]
1. Login to https://console.developers.google.com/ using administrator@domain.tdl
2. Copy and paste the URL https://console.developers.google.com/flows/enableapi?apiid=admin,contacts,driveactivity.googleapis.com,licensing,gmail,calendar,classroom.googleapis.com,docs.googleapis.com,drive,sheets.googleapis.com,slides.googleapis.com,groupssettings,chat.googleapis.com,people.googleapis.com,tasks 
3. Click on the Projects dropdown > New or Create > Name "PSGSuite" > Click Create > Select the new project > Next > Enable
5. Go back to Projects home > APIs & Services > Credentials > Create Credentials > Service Account
6. Set service Account Name "manage", description : "For Managing google workspace using PSGSuite"
7. Click "Create and continue", Set Role : Owner 
8. Click Done
9. Click the new service account and collect information
9. a. On the details page, the Unique ID is the "ServiceAccountClientID"
9. b. Email is the "AppEmail"
9. c. Go to Keys tab, Add Key > Create new Key > P12
9. d. Move the P12 certificate to the domain folder, the file name with extension is the "P12KeyPath", do not use full path
10. On the account that has access to manage security settings, go to https://admin.google.com/ac/owl/domainwidedelegation
11. Add New > Paste client ID from #9
12. In OAuth Scopes paste:
https://apps-apis.google.com/a/feeds/emailsettings/2.0/,
https://mail.google.com/,
https://sites.google.com/feeds,
https://www.google.com/m8/feeds/contacts,
https://www.googleapis.com/auth/activity,
https://www.googleapis.com/auth/admin.datatransfer,
https://www.googleapis.com/auth/admin.directory.customer,
https://www.googleapis.com/auth/admin.directory.device.chromeos,
https://www.googleapis.com/auth/admin.directory.device.mobile,
https://www.googleapis.com/auth/admin.directory.domain,
https://www.googleapis.com/auth/admin.directory.group,
https://www.googleapis.com/auth/admin.directory.orgunit,
https://www.googleapis.com/auth/admin.directory.resource.calendar,
https://www.googleapis.com/auth/admin.directory.rolemanagement,
https://www.googleapis.com/auth/admin.directory.rolemanagement.readonly,
https://www.googleapis.com/auth/admin.directory.user,
https://www.googleapis.com/auth/admin.directory.user.readonly,
https://www.googleapis.com/auth/admin.directory.user.security,
https://www.googleapis.com/auth/admin.directory.userschema,
https://www.googleapis.com/auth/admin.reports.audit.readonly,
https://www.googleapis.com/auth/admin.reports.usage.readonly,
https://www.googleapis.com/auth/apps.groups.settings,
https://www.googleapis.com/auth/apps.licensing,
https://www.googleapis.com/auth/calendar,
https://www.googleapis.com/auth/chat.bot,
https://www.googleapis.com/auth/classroom.announcements,
https://www.googleapis.com/auth/classroom.courses,
https://www.googleapis.com/auth/classroom.coursework.me,
https://www.googleapis.com/auth/classroom.coursework.students,
https://www.googleapis.com/auth/classroom.guardianlinks.students,
https://www.googleapis.com/auth/classroom.profile.emails,
https://www.googleapis.com/auth/classroom.profile.photos,
https://www.googleapis.com/auth/classroom.push-notifications,
https://www.googleapis.com/auth/classroom.rosters,
https://www.googleapis.com/auth/classroom.rosters.readonly,
https://www.googleapis.com/auth/drive,
https://www.googleapis.com/auth/gmail.settings.basic,
https://www.googleapis.com/auth/gmail.settings.sharing,
https://www.googleapis.com/auth/plus.login,
https://www.googleapis.com/auth/plus.me,
https://www.googleapis.com/auth/tasks,
https://www.googleapis.com/auth/tasks.readonly,
https://www.googleapis.com/auth/userinfo.email,
https://www.googleapis.com/auth/userinfo.profile
13. Click Authorize
14. Still on the account from #11, Go to Account > Account Settings > customer ID is the "CustomerID", Name is the "Name"
15. Open the config file and populate the fields collected from #9, admin email is the account from #1, name and Customer ID from #14, domain is the domain being managed
16. Save and test PSGSuite Commands


**Folder Structure**  
PSGSuite/  
├─ domains/  
│  ├─ yourfirstdomain.com/  
│  │  ├─ config  
│  │  ├─ signature-template/  
│  │  │  ├─ signature1.html  
│  ├─ yourseconddomain.com/  
│  │  ├─ signature-template/  
│  │  │  ├─ signature1.html  
│  │  ├─ config  
CalendarACLTool.ps1  
Update-CalendarACL.ps1  
config  

**Tools:**
1. Update-CalendarACL.ps1 :
In a scenario where each team, business unit or sub-companies have their individual Google workspace accounts, there seems to be no easy (GUI) way for admin to allow everyone to see everyone elses calendar and when they are available to make meeting scheduling easier.
This script assumes the folders under domain are your actual domain names for all the domains you want to see each other's calendars.
It accepts variable $domain, connects to the given domain, and shares each person's calendar with the other domains grabbed from the domain folders name.
1a. Usage : .\Update-CalendarACL -domain $domain 
where domain is the domain name with users who's calendars are being shared

2. CalendarACLTool can be scheduled with taskmanager to run Update-CalendarACL for all your domains
