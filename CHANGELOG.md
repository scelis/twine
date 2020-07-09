# 1.1 (2020-07-09)

- Feature: Add --escape-all-tags option to force escaping of Android styling tags (#281)
- Improvement: Twine now requires Ruby 2.4 or greater and rubyzip 2.0 or greater (#297)
- Bugfix: Fix issues with the Django formatter (#289)

# 1.0.6 (2019-05-28)

- Improvement: Support more Android styling tags (#278)
- Improvement: Update Android output path for default language (#276)

# 1.0.5 (2019-02-24)

- Bugfix: Incorrect language detection when reading localization files (#251)
- Bugfix: Double quotes in Android files could be converted to single quotes (#254)
- Bugfix: Properly escape quotes when writing gettext files (#268)

# 1.0.4 (2018-05-30)

- Feature: Add a --quiet option (#245)
- Bugfix: Consume child HTML tags in Android formatter (#247)
- Bugfix: Let consume-localization-archive return a non-zero status (#246)

# 1.0.3 (2018-01-26)

- Bugfix: Workaround a possible crash in safe_yaml (#237)
- Bugfix: Fix an error caused by combining %@ with other placeholders (#235)

# 1.0.2 (2018-01-20)

- Improvement: Better support for placeholders in HTML styled Android strings (#212)

# 1.0.1 (2017-10-17)

- Bugfix: Always prefer the passed-in formatter (#221)

# 1.0 (2017-10-16)

- Feature: Fail twine commands if there's more than one formatter candidate (#201)
- Feature: In the Apple formatter, use developer language for the base localization (#219)
- Bugfix: Preserve basic HTML styling for Android strings (#212)
- Bugfix: `twine --version` reports "unknown" (#213)
- Bugfix: Support spaces in command line arguments (#206)
- Bugfix: 'r' missing before region code in Android output folder (#203)
- Bugfix: .po formatter language detection (#199)
- Bugfix: Add 'q' placeholder for android strings (#194)
- Bugfix: Boolean command line parameters are always true (#191)

# 0.10.1 (2017-01-19)

- Bugfix: Xcode integration (#184)
