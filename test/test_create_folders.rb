require 'twine_test_case'

# TODO: maybe this should be part of generate_all_test?
class TestCreateFolders < TwineTestCase
  def test_generate_all_fails_if_output_folder_does_not_exist
    assert_raises Twine::Error do
      execute "generate-all-string-files #{f 'twine_key1_en_es.txt'} #{@output_dir} -f apple"
    end
  end

  def test_generate_all_creates_output_folder
    # implicitly assert nothing raised
    execute "generate-all-string-files #{f 'twine_key1_en_es.txt'} #{@output_dir} -f apple --create-folders"
  end

  def test_generate_all_does_not_create_folders
    Dir.mkdir File.join @output_dir, 'en.lproj'
    execute "generate-all-string-files #{f 'twine_key1_en_es.txt'} #{@output_dir} -f apple"
    assert !File.exists?(File.join(@output_dir, 'es.lproj')), "language folder should not be created"
  end

  def test_generate_all_creates_folders
    execute "generate-all-string-files #{f 'twine_key1_en_es.txt'} #{@output_dir} -f apple --create-folders"
    assert File.exists?(File.join(@output_dir, 'en.lproj')), "language folder 'en.lproj' should be created"
    assert File.exists?(File.join(@output_dir, 'es.lproj')), "language folder 'es.lproj' should be created"
  end
end
