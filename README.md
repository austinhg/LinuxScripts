# LinuxScripts

A set of scripts I either made or added to for work.

### mediaportCleanup.sh

A script to clean out old media files on a Linux client machine. 
There was a problem with customers having the /home directory fill up due to video caching, this was my solution.

---

### periodicReboot.sh

A script to reboot our client devices nightly (at the business owners request) to prevent machine freeze-ups. 

---

### fourthSundayRefresh.sh

Refreshes a database on the 4th Sunday of every month. More or less kept for the logic of running on a specific (n)th date of a month.

---

### pythonDjangoSample.sh

A script created for a DevOps interview challenge. Automates installing dependencies, running the server.
Notes during the interview:	
- Pipe requirements file to pull in required dependencies automatically.
- Possibly set up GitHub project that is used as a package / container.

---

### serverCopy.sh

When it comes to my home server I grew incredibly tired of rsyncing all of my download data from the cloud. Here's a script to fix that.
NOTE: This is a kind of rushed hack-job. Take it with a grain of salt.
