require "minitest/autorun"
require "fancy_require"

class LookUp

  def path_for feature
    Dir["#{Dir.pwd}/test/lookup/#{feature}{#{FancyRequire::SUFFIXES}}"].first
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

end

