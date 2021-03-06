require 'rubygems'

##
# FancyRequire allows you to push an object onto $LOAD_PATH that will find
# files to load.  You can use this to implement fancier require behavior
# without overriding Kernel#require.
#
# The lookup object you push onto $LOAD_PATH must respond to #path_for.  The
# feature being required (file name) will be passed in by FancyRequire.
#
# The lookup object must return the path to the feature, true, false or nil.
#
# If nil is returned FancyRequire will continue to search down the load path.
#
# If true or false are returned the lookup object handled loading the file and
# recording it in $LOADED_FEATURES.  The boolean will be returned as plain
# require.
#
# == Example
#
# The easiest way to use FancyRequire is to require it everywhere (which
# includes it in Object):
#
#   require 'fancy_require/everywhere'
#
# Then create a LookUp object and add it to the load path.  This LookUp object
# looks in a 'lookup' directory under the current path.
#
#   class LookUp
#     def initialize directory
#       @directory = directory
#     end
#
#     def path_for feature
#       Dir["#{Dir.pwd}/#{directory}/lookup/#{feature}{#{FancyRequire::SUFFIX_GLOB}}"].first
#     end
#   end
#
#   $LOAD_PATH.unshift LookUp.new 'test'
#
# Then require works like normal.
#
#   require 'toad' # looks for ./test/lookup/toad.rb

module FancyRequire

  ##
  # The version of FancyRequire you're using... not that I know why you're
  # using FancyRequire

  VERSION = '1.0'

  ##
  # Dir#glob list of ruby file suffixes

  SUFFIX_GLOB = Gem.suffixes.join ','

  ##
  # Regexp list of ruby file suffixes

  SUFFIX_RE = Regexp.union Gem.suffixes

  ##
  # Replacement for Kernel#require
  #
  # NOTE: this method is not 100% compatible with ruby

  def require feature
    return false if loaded? feature # 1.8

    path = nil

    $LOAD_PATH.each do |obj|
      path = case obj
             when String then
               Dir["#{obj}/#{feature}{#{FancyRequire::SUFFIX_GLOB}}"].find do |item|
                 File.file? item
               end
             else
               obj.path_for feature
             end

      case path
      when true, false
        return path
      else
        break if path
      end
    end

    raise LoadError, "no such file to load -- #{feature}" unless path

    return false if loaded? path # 1.9

    load path

    if RUBY_VERSION > '1.9' then
      $LOADED_FEATURES << path
    else
      $LOADED_FEATURES << File.basename(path)
    end

    true
  end

  ##
  # Is +feature+ already in $LOADED_FEATURES?
  #
  # NOTE: this method is not 100% compatible with ruby

  def loaded? feature
    $LOADED_FEATURES.any? do |path|
      path =~ /^#{feature}#{SUFFIX_RE}$/
    end
  end

end

