= fancy_require

* http://seattlerb.rubyforge.org/fancy_require

== DESCRIPTION:

Perform fancy requiring by adding a custom object to the load path.  This
allows you to escape the harsh strictures directory-based lookup provided by
$LOAD_PATH.

== SYNOPSIS:

  Object.include FancyRequire

  class LookUp
    def initialize directory
      @directory = directory
    end

    def path_for feature
      Dir["#{Dir.pwd}/#{directory}/lookup/#{feature}{#{FancyRequire::SUFFIXES}}"].first
    end
  end

  $LOAD_PATH.unshift LookUp.new 'test'

  require 'toad' # looks for ./test/lookup/toad.rb

== REQUIREMENTS:

None

== INSTALL:

  gem install fancy_require

== LICENSE:

(The MIT License)

Copyright (c) 2010 Eric Hodel

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
