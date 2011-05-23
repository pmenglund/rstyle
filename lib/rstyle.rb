# Copyright 2010 Code Nursery AB
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "trollop"

class Rstyle
  attr_reader :line_count, :errors, :warnings

  def initialize(options)
    @options = parse_options(options)
    @errors = 0
    @warnings = 0
  end

  def parse_options(options)
    Trollop::options(options) do
      opt :all, "enable all options"
      opt :empty_line, "empty lines"
      opt :tabs, "line contains tab(s)"
      opt :ends_with_whitespace, "line ends with whitespace"
      opt :no_space_after_comma, "no space after ','"
      opt :space_after, "space after ( and [ or before ) and ]"
      opt :two_spaces, "use two spaces before statement modifiers"
      opt :snake_case, "methods should be in snake_case"
      opt :no_for, "don't use for unless you know what you are doing"
      opt :line_length, "line length", :default => 80
    end
  end

  def source(files)
    files.each do |file|
      if File.directory?(file)
        source Dir.glob("#{file}/**/*.rb")
      elsif file =~ /\.rb/
        read_file(file)
      end
    end
  end

  def read_file(file)
    @file = file
    File.open(file) do |f|
      lines = []
      begin
        while lines << f.readline.chomp; end
      rescue EOFError
        # do nothing, it is expected
      end
      parse(lines)
    end
  end

  def parse(lines)
    @line_count = 0
    lines.each_with_index do |line, i|
      @oline = @line = line
      @line_count += 1

      # strip out text from strings
      @line = @line.gsub(/"([^"]+)"/, "\"\"")

      # strip out text from regexps
      @line = @line.gsub(/\/([^\/]+)\//, "//")

      max_len = @options[:line_length]
      if @oline.length > max_len
        error "line longer than #{max_len} characters (#{@oline.length})"
      end

      check :empty_line, "empty line contains whitespace", /^\s+$/

      check :tabs, "line contains tab(s)", /\t/

      check :ends_with_whitespace, "line ends with whitespace", /\S+\s+$/

      check :no_space_after_comma, "no space after ,", /,\S+/

      check :space_after, "space after ( and [ or before ) and ]",
            /[\(\[]\s+|\s+[\)\]]/

      check :two_spaces, "use two spaces before statement modifiers",
            /\S+( | {3,})(if|unless|until|rescue|while)/

      check(:snake_case, /\s*def (\S+)/) do |method|
        error "methods should be in snake_case"  if method =~ /[A-Z]/
      end

      check(:no_for, /^\s*for/) do
        warning "don't use for unless you know what you are doing"
      end
    end
  end

  private

  def check(name, *args)
    if @options[name] || @options[:all]
      if @line =~ args[args.length - 1]
        if block_given?
          yield($1)
        else
          error(args[0])
        end
      end
    end
  end

  def error(message)
    @errors += 1
    e(message)
  end

  def warning(message)
    @warnings += 1
    e "warning: #{message}"
  end

  def e(message)
    $stderr.printf("%s: ", @file)  if @file
    $stderr.puts "#{@line_count}: #{message}"
  end
end
