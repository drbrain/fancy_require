require 'rubygems'

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
