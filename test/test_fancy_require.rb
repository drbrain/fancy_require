require "minitest/autorun"
require "fancy_require"

class LookUp

  def path_for feature
    case feature
    when 'true'  then true
    when 'false' then false
    when 'nil'   then nil
    else
      Dir["#{Dir.pwd}/test/lookup/#{feature}{#{FancyRequire::SUFFIX_GLOB}}"].first
    end
  end

end

class TestFancyRequire < MiniTest::Unit::TestCase

  include FancyRequire

  def setup
    @loaded_features = $LOADED_FEATURES.dup
    @load_path = $LOAD_PATH.dup
  end

  def teardown
    $LOADED_FEATURES.replace @loaded_features
    $LOAD_PATH.replace @load_path
  end

  def test_require
    $LOAD_PATH.unshift LookUp.new

    assert require 'toad'

    assert_match %r%toad\.rb$%, $LOADED_FEATURES.last
  end

  def test_require_false
    $LOAD_PATH.unshift LookUp.new

    assert_equal false, require('false')

    refute_match %r%false$%, $LOADED_FEATURES.last
  end

  def test_require_nil
    $LOAD_PATH.unshift LookUp.new

    assert_raises LoadError do
      require 'nil'
    end
  end

  def test_require_true
    $LOAD_PATH.unshift LookUp.new

    assert_equal true, require('true')

    refute_match %r%true$%, $LOADED_FEATURES.last
  end

end

