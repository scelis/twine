Pod::Spec.new do |s|

  s.name         = "twine"
  s.version      = "0.10.1"
  s.summary      = "Twine is a command line tool for managing your strings and their translations."

  s.description  = <<-DESC
    Twine is a command line tool for managing your strings and their translations.
    These are all stored in a master text file and then Twine uses this file to import and export localization files in a variety of types, 
    including iOS and Mac OS X .strings files, Android .xml files, gettext .po files, and jquery-localize .json files. 
    This allows individuals and companies to easily share translations across multiple projects, as well as export localization files in any format the user wants.
  DESC

  s.homepage     = "https://github.com/scelis/twine"

  s.license      = { :type => "BSD", :file => "LICENSE" }

  s.author             = "Sebastian Celis"

  s.source       = { :http => "https://github.com/scelis/twine/archive/v#{s.version}.zip" }

  s.preserve_paths = "*"

end
