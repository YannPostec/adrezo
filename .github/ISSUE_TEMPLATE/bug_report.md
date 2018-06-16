---
name: Bug report
about: Create a report to help us improve

---

**Describe the bug**
A clear and concise description of what the bug is.
Steps to reproduce the behavior if possible.

**Logs/Screenshots**
If applicable, add screenshots to help explain your problem.
You can put application logs if some contains error related to your issue.

**Putting logs in debug mode**
Modify WEB-INF/classes/log4j.xml to place the log in debug mode and reproduce the issue.
Change `<log4j:configuration threshold="all" debug="false">` to `<log4j:configuration threshold="all" debug="true">`
Change `<level value="info" />` to `<level value="debug" />` in the needed `<logger>` sections

**Client (please complete the following information) :**
 - Application Server [tomcat, weblogic]
 - Database Server [postgresql, oracle]
 - Browser [vivaldi, firefox, chrome, ...] and version
 - Adrezo Version [e.g. 1.9.7]
