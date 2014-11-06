SeaEye
======

**OSX desktop notifications for Circle CI builds**

SeaEye is a menu bar notification app for CircleCI written in Swift.

---

###Features
* SeaEye gives you desktop notifications on CircleCI build progress over multiple repos.
* You can view ongoing and past builds directly from the menu bar.
* Restrict notifications to specific users or branches using regular expressions.
* Jump directly to the CircleCI site for any build listed.

##[Download V0.2 (OSX 10.10 only)](https://github.com/nolaneo/SeaEye/blob/master/Builds/SeaEye%20v0.2.zip?raw=true)

---

![](https://raw.githubusercontent.com/nolaneo/SeaEye/master/Screenshots/builds.png)

*Builds are shown right from the menu bar.*


![](https://raw.githubusercontent.com/nolaneo/SeaEye/master/Screenshots/notification.png)

*Notifications let you know when your builds have finished.*

*Don't want notifications? The menu bar icon will still update you.*


![](https://raw.githubusercontent.com/nolaneo/SeaEye/master/Screenshots/settings.png)

*It's simple to set up*


---
### How it works
* Add your CircleCI API token.
* Name the organization and repos you want to follow.
* Optional: Add the users and branches you want to follow.
* Don't want desktop notifications? Turn them off!

---
###FAQ

*What about Mavericks support?*
* The UI for SeaEye was built using XCode's new storyboards for OSX feature. Unfortunately, this means the app will only work on Yosemitie or greater.

*I broke SeaEye, how do I force quit?*
* :( SeaEye doesn't show up in the simple Force Quit window because it's an agent app. This means you'll need to close it from Activity Monitor.

---
###TODO
* Add the ability to add application to start up programs.
* Add paste support to the settings page.
* Add retina menu bar icons.
* Add a better transparency fix.
* Change desktop notifications to have green/red icons depending on the build outcome.

