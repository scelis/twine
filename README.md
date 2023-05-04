This is a hard modifition of twine tool. Original readme can be found [here](./README_ORIGINAL.md)

## Main changes:
- removed all unused formatters, left only Android, Apple and Jquery(format supported by https://i18next.com)
- added functionality to generate plurals in all 3 formatters
- changed format of the general twine file (example can be found in test folder [example](test/fixtures/twine_accent_values.txt))
- removed unused commands

## Format changes:
- sections must be wrapped into [[[`Section name`]]]
- keys must be wrapped into [[`key name`]]
- to add plurals you should wrap language into [`language code`] and add all formats in the following format: `one = value for one`, `other = value for other`, etc.

## How to use

First of all, you must have Ruby installed and Bundle as a gem. To do so run `gem install bundle`.
After that you can install all required dependencies using bundle: `bundle install --path bundle/vendor`.

Run twine commands via bundle exec, like so: `bundle exec ./twine generate-all-localization-files path/to/twine.txt output/directory/ --format android --create-fodlers`