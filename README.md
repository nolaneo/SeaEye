SeaEye
======

**OSX desktop notifications for Circle CI builds**

SeaEye is a menu bar notification app for CircleCI written in Swift.

---

### Features
* SeaEye gives you desktop notifications on CircleCI build progress over multiple repos.
* You can view ongoing and past builds directly from the menu bar.
* Restrict notifications to specific users or branches using regular expressions.
* Jump directly to the CircleCI site for any build listed.

##[Download V0.5 (OSX Yosemite +)](https://github.com/nolaneo/SeaEye/blob/master/Builds/SeaEye%20v0.5.zip?raw=true)

### Updates for v0.4
* Fixed crash after entering API key.
* Removed Mavericks support.

### Updates for v0.3
* Mavericks support!
* Adding SeaEye to your start up apps can now be done at the click of a button.
* Nicer notifications with green ticks for passed builds and red X's for failed builds.
* An updates system to notify you of changes and new versions.
* Retina menu bar icons.
* Better error handling for incorrect API keys or repo names.

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
### FAQ

*My builds won't load*
* Make sure you're using your own personal Circle CI token and not the repo specific token. Otherwise ensure that you've spelt the names of your projects correctly. If that doesnt work, try use cURL to hit the Circle API with your token and open an issue if you get back good data.

*I broke SeaEye, how do I force quit?*
* :( SeaEye doesn't show up in the simple Force Quit window because it's an agent app. This means you'll need to close it from Activity Monitor.

---
### TODO
* Add paste support to the settings page.

