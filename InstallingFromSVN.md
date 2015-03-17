# Introduction #

Development for the OTR is continuously underway, but if you want to try it out now (and we'd love it if you would!), you can grab the code from Subversion (SVN) and run it on your instance of OpenBD.

**NOTE:** Do NOT run bleeding edge code on a production or otherwise important instance of OpenBD! There is currently no security in place on the OTR, and any bugs that exist in the bleeding edge code could cause problems with your Oracle Databases

## SVN Clients ##

If you don't have an SVN client, you'll need to get one. If you're a developer and you're already using [Eclipse](http://www.eclipse.org/), probably the simplest one to grab is [Subclipse](http://subclipse.tigris.org/). It will work on any platform (Linux, Mac, or Windows).

If you aren't on Eclipse, native clients are available for any platform, or you can run SVN from a terminal or DOS window.

One client that seems to be nice that is available for Linux, Mac, and Windows is [SyncroSVN](http://www.syncrosvnclient.com/). I haven't personally used it but a few Mac bloggers swear by it.

For Windows, the most popular client is [TortoiseSVN](http://tortoisesvn.tigris.org/), which integrates directly into Windows file explorer.

For Mac, [Versions](http://versionsapp.com/) looks very nice, but again, I haven't personally tried it. [svnX](http://www.lachoseinteractive.net/en/community/subversion/svnx/features/) is another popular client for Mac.

## Getting the Code from SVN ##

Once you have an SVN client installed, do a checkout from the SVN repository for this project. Details are available on the [checkout](http://code.google.com/p/oracle-tablespace-report/source/checkout) page. You'll want to grab the trunk.

## Where to put the OTR ##

The OTR code resides in the webapps directory at the top of your OpenBD instance.

The easiest way to configure things is to have your local directory for the SVN project be the root of the instance of OpenBD on which you want to try out the OTR.

## Reporting Bugs ##


Since development is still happening rapidly at this point, expect to see a few bugs here and there, and also expect to be pulling the code down regularly to get the latest version of things.

If you do see a bug that's keeping you from using the admin console or think it might be something we aren't aware of, please report it on the [issues](http://code.google.com/p/oracle-tablespace-report/issues/list) page.

## Requesting Features ##
If you have ideas for features you'd like to see in the admin console, no matter how big or small, we'd love to hear them! Please create an issue on the [issues](http://code.google.com/p/oracle-tablespace-report/issues/list) page and use the label Type-Enhancement