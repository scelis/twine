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
