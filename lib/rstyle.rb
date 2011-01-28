# Copyright 2011 Code Nursery AB. All rights reserved.
# Use is subject to license terms.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
