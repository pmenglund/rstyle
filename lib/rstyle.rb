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

class Rstyle
  attr_reader :line_count, :errors, :warnings

  def initialize
    @errors = 0
    @warnings = 0
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

      if @oline.length > 80
        error "line longer than 80 characters"
      end

      check "empty line contains whitespace", /^\s+$/

      check "line contains tab(s)", /\t/

      check "line ends with whitespace", /\S+\s+$/

      check "no space after ,", /,\S+/

      check "space after ( and [ or before ) and ]", /[\(\[]\s+|\s+[\)\]]/

      check "use two spaces before statement modifiers",
          /\S+( | {3,})(if|unless|until|rescue|while)/

      check(/\s*def (\S+)/) do |method|
        error "methods should be in snake_case"  if method =~ /[A-Z]/
      end

      check(/^\s*for/) do
        warning "don't use for unless you know what you are doing"
      end
    end
  end

  private

  def check(*args)
    if @line =~ args[args.length - 1]
      if block_given?
        yield($1)
      else
        error(args[0])
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
