require 'rubygems'

##
# FancyRequire allows you to push an object onto $LOAD_PATH that will find
# files to load.  You can use this to implement fancier require behavior
# without overriding Kernel#require.
#
# The object you push onto $LOAD_PATH must respond to #path_for and return a
# file name or nil.  The feature being required will be passed in by
# FancyRequire.
#
# The easiest way to use FancyRequire is to require it everywhere (include it
# in Kernel):
#
#   require 'fancy_require/everywhere'
# 
#   class LookUp
#     def initialize directory
#       @directory = directory
#     end
# 
#     def path_for feature
#       Dir["#{Dir.pwd}/#{directory}/lookup/#{feature}{#{FancyRequire::SUFFIXES}}"].first
#     end
#   end
# 
#   $LOAD_PATH.unshift LookUp.new 'test'
# 
#   require 'toad' # looks for ./test/lookup/toad.rb

module FancyRequire
  VERSION = '1.0.0'

  SUFFIXES = Gem.suffixes.join ','

  def require feature
    return false if
      RUBY_VERSION < '1.9' and $LOADED_FEATURES.include? feature

    path = nil

    $LOAD_PATH.each do |obj|
      path = case obj
             when String then
               Dir["#{obj}/#{feature}{#{Gem.suffixes}}"].first
             else
               obj.path_for feature
             end

      break if path
    end

    return false if
      RUBY_VERSION > '1.9' and $LOADED_FEATURES.include? path

    load path

    if RUBY_VERSION > '1.9' then
      $LOADED_FEATURES << path
    else
      $LOADED_FEATURES << File.basename(path)
    end

    true
  end

end
