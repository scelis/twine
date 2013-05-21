# Twine

Twine is a command line tool for managing your strings and their translations. These strings are all stored in a master text file and then Twine uses this file to import and export strings in a variety of file types, including iOS and Mac OS X `.strings` files, Android `.xml` files, gettext `.po` files, and [jquery-localize][jquerylocalize] `.json` files. This allows individuals and companies to easily share strings across multiple projects, as well as export strings in any format the user wants.

#####This repo provides a self-contained GUI Tool for mobiata's twine CLI application.
For Further information about twine itself checkout www.github.com/mobiata/twine

## Install

Provides a fully featured GUI App written in Java Swing. You dont need to have the command line tool installed to use the GUI App. It is self contained and only needs the jruby.jar to be present.

	$ git clone git://github.com/Daij-Djan/twine_ui.git
	$ ant run #or ant jar to get a jar which you can then move

![gui_app](https://raw.github.com/Daij-Djan/twine_ui/master/twine_gui.png)