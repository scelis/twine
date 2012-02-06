# Twine

Twine is a command line tool for managing your strings and their translations. These strings are all stored in a master text file and then Twine uses this file to import and export strings in a variety of file types, including iOS and Mac OS X `.strings` files as well as Android `.xml` files. This allows individuals and companies to easily share strings across multiple projects, as well as export strings in any format the user wants.

## Install

### As a Gem

Twine is most easily installed as a Gem.

	sudo gem install twine

### From Source

You can also run Twine directly from source. However, it requires [rubyzip][rubyzip] in order to create and read standard zip files.

	sudo gem install rubyzip
	git clone git://github.com/mobiata/twine.git
	cd twine
	./twine --help

Make sure you run the `twine` executable at the root of the project as it properly sets up your Ruby library path. The `bin/twine` executable does not.

## String File Format

Twine stores all of its strings in a single file. The format of this file is a slight variant of the [Git][git] config file format, which itself is based on the old [Windows INI file][INI] format. The entire file is broken up into sections, which are created by placing the section name between two pairs of square brackets. Sections are optional, but they are a recommended way of breaking your strings into smaller, more manageable chunks.

Each grouping section contains N string definitions. These string definitions start with the string key placed within a single pair of square brackets. This string definition then contains a number of key-value pairs, including a comment, a comma-separated list of tags (which are used by Twine to select a subset of strings), and all of the translations.

### Tags

Tags are used by Twine as a way to only work with a subset of your strings at any given point in time. Each string can be assigned zero or more tags which are separated by commas. When a string has no tags, that string will never be selected by Twine. You can get a list of all strings currently missing tags by executing the `generate-report` command.

### Whitespace

Whitepace in this file is mostly ignored. If you absolutely need to put spaces at the beginning or end of your translated string, you can wrap the entire string in a pair of `` ` `` characters. If your actual string needs to start *and* end with a grave accent, you can wrap it in another pair of `` ` `` characters. See the example, below.

### Example

	[[General]]
		[yes]
			en = Yes
			es = Sí
			fr = Oui
			ja = はい
		[no]
			en = No
			fr = Non
			ja = いいえ
			
	[[Errors]]
		[path_not_found_error]
			en = The file '%@' could not be found.
			tags = app1,app6
			comment = An error describing when a path on the filesystem could not be found.
		[network_unavailable_error]
			en = The network is currently unavailable.
			tags = app1
			comment = An error describing when the device can not connect to the internet.
			
	[[Escaping Example]]
		[list_item_separator]
			en = `, `
			tags = mytag
			comment = A string that should be placed between multiple items in a list. For example: Red, Green, Blue
		[grave_accent_quoted_string]
			en = ``%@``
			tags = myothertag
			comment = This string will evaluate to `%@`.

## Usage

	Usage: twine COMMAND STRINGS_FILE [INPUT_OR_OUTPUT_PATH] [--lang LANG1,LANG2...] [--tag TAG1,TAG2,TAG3...] [--format FORMAT]
	
### Commands

#### `generate-string-file`

This command creates an Apple or Android strings file from the master strings data file.

	> twine generate-string-file /path/to/strings.txt values-ja.xml --tag common,app1
	> twine generate-string-file /path/to/strings.txt Localizable.strings --lang ja --tag mytag
	> twine generate-string-file /path/to/strings.txt all-english.strings --lang en

#### `generate-all-string-files`

This command is a convenient way to call `generate-string-file` multiple times. It uses standard Mac OS X, iOS, and Android conventions to figure out exactly which files to create given a parent directory. For example, if you point it to a parent directory containing `en.lproj`, `fr.lproj`, and `ja.lproj` subdirectories, Twine will create a `Localizable.strings` file of the appropriate language in each of them. This is often the command you will want to execute during the build phase of your project.

	> twine generate-all-string-files /path/to/strings.txt /path/to/project/locales/directory --tag common,app1

#### `consume-string-file`

This command slurps all of the strings from a `.strings` or `.xml` file and incorporates the translated text into the master strings data file. This is a simple way to incorporate any changes made to a single file by one of your translators. It will only identify strings that already exist in the master data file.

	> twine consume-string-file /path/to/strings.txt fr.strings
	> twine consume-string-file /path/to/strings.txt Localizable.strings --lang ja
	> twine consume-string-file /path/to/strings.txt es.xml

#### `generate-loc-drop`

This command is a convenient way to generate a zip file containing files created by the `generate-string-file` command. It is often used for creating a single zip containing a large number of strings in all languages which you can then hand off to your translation team.

	> twine generate-loc-drop /path/to/strings.txt LocDrop1.zip
	> twine generate-loc-drop /path/to/strings.txt LocDrop2.zip --lang en,fr,ja,ko --tag common,app1

#### `consume-loc-drop`

This command is a convenient way of taking a zip file and executing the `consume-string-file` command on each file within the archive. It is most often used to incorporate all of the changes made by the translation team after they have completed work on a localization drop.

	> twine consume-loc-drop /path/to/strings.txt LocDrop2.zip

#### `generate-report`

This command gives you useful information about your strings. It will tell you how many strings you have, how many have been translated into each language, and whether your master strings data file has any duplicate string keys.

	> twine generate-report /path/to/strings.txt

[rubyzip]: http://rubygems.org/gems/rubyzip
[git]: http://git-scm.org/
[INI]: http://en.wikipedia.org/wiki/INI_file
