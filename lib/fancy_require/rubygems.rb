require 'rubygems'
require 'fancy_require/everywhere'

module Kernel

  ##
  # Hide RubyGems custom require

  alias rubygems_custom_require require

  ##
  # Restore the original require behavior

  alias require gem_original_require

end

##
# A RubyGems LookUp object that does not pollute $LOAD_PATH.  Instead,
# Gem::LookUp keeps an internal load path of activated gems.
#
# Requiring fancy_require/rubygems replaces rubygems/custom_require.

class Gem::LookUp

  ##
  # Hash mapping activated gem names to their Gem::Specifications

  attr_accessor :activated

  ##
  # Load path for activated gems

  attr_accessor :load_path

  def initialize
    @activated = {}
    @load_path = []
    @stack = {}
  end

  ##
  # Activates +dep+ and adds it to the load path.

  def activate dep, sources = []
    matches = Gem.source_index.search dep

    report_activate_error dep if matches.empty?

    return false if activated? dep, matches

    # new load
    spec = matches.last
    return false if spec.loaded?

    spec.loaded = true
    @activated[spec.name] = spec
    @stack[spec.name] = sources.dup

    # Load dependent gems first
    spec.runtime_dependencies.each do |dep_gem|
      activate dep_gem, [spec].concat(sources)
    end

    require_paths = spec.require_paths.map do |path|
      File.join spec.full_gem_path, path
    end

    @load_path.concat require_paths

    return true
  end

  ##
  # Was +dep+ activated?

  def activated? dep, matches
    return unless @activated[dep.name]

    # This gem is already loaded.  If the currently loaded gem is not in the
    # list of candidate gems, then we have a version conflict.
    existing_spec = @activated[dep.name]

    unless matches.any? { |spec| spec.version == existing_spec.version } then
      sources_message = sources.map { |spec| spec.full_name }
      stack_message = @loaded_stacks[gem.name].map { |spec| spec.full_name }

      msg = "can't activate #{gem} for #{sources_message.inspect}, "
      msg << "already activated #{existing_spec.full_name} for "
      msg << "#{stack_message.inspect}"

      e = Gem::LoadError.new msg
      e.name = gem.name
      e.version_requirement = gem.requirement

      raise e
    end

    return true
  end

  ##
  # FancyRequire hook that will load +feature+

  def path_for feature
    orig_load_path = $LOAD_PATH.dup

    position = $LOAD_PATH.index self

    # look in the load path below ourselves
    $LOAD_PATH.replace $LOAD_PATH[(position + 1)..-1]

    begin
      return require feature # require found it for us, we're done
    rescue LoadError => load_error
      unless load_error.message =~ /#{Regexp.escape feature}\z/ and
             spec = Gem.searcher.find(feature) then
        raise load_error
      end
      # now it's our turn!
    ensure
      $LOAD_PATH.replace orig_load_path
    end

    dep = Gem::Dependency.new spec.name, "= #{spec.version}"

    activate dep

    @load_path.each do |path|
      path = File.join path, "#{feature}{#{FancyRequire::SUFFIX_GLOB}}"

      found = Dir[path].find do |file|
        File.file? file
      end

      return found if found
    end

    nil
  end

  ##
  # Report a load error during activation.  The message of load error
  # depends on whether it was a version mismatch or if there are not gems of
  # any version by the requested name.

  def report_activate_error dep
    matches = Gem.source_index.find_name dep.name

    if matches.empty? then
      error = Gem::LoadError.new(
        "Could not find RubyGem #{gem.name} (#{gem.requirement})\n")
    else
      error = Gem::LoadError.new(
        "RubyGem version error: " \
        "#{gem.name}(#{matches.first.version} not #{gem.requirement})\n")
    end

    error.name = gem.name
    error.version_requirement = gem.requirement

    raise error
  end

end

look_up = Gem::LookUp.new

$LOAD_PATH.unshift look_up

