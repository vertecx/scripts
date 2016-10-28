# Intel SSD 910 temperature monitoring and alerting
This script parses the output of Intel Solid-State Drive Data Center Tool (isdct.exe) and writes the current temperatures to the Windows event log.

If a configurable critical temperature is exceeded, the script will shut down the computer to prevent damage to the SSD.

The script does not run continuously. It is instead intended to be started by the Windows Task Scheduler at an interval of your choosing.
An example task that logs the temperatures every 5 minutes is provided in SSD910Monitor.xml. The file can be imported inside Task Scheduler.

The two example tasks in SSD910MonitorWarning.xml and SSD910MonitorCritical.xml shows how it is possible to use [Notify](https://github.com/vertecx/notify) to show notifications on the desktop if the temperature passes set thresholds.
