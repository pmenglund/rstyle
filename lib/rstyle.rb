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

  def initialize(array=nil)
    @line_count = 0
    @errors = 0
    @warnings = 0
    @array = array
  end

  def input=(s)
    @array = s.kind_of?(Array) ? s : s.split("\n")
  end

  def parse
    @array.each do |line|
      @oline = @line = line
      @line_count += 1

      # strip out text from strings
      @line = @line.gsub(/ *"([^"]+)"/, "")

      # strip out text from regexps
      @line = @line.gsub(/ *\/([^\/]+)\//, "")

      if @oline.length > 80
        error "line longer than 80 characters"
      end

      check "empty line contains whitespace", /^\s+$/

      check "line contains tab(s)", /\t/

      check "line ends with whitespace", /\S+\s+$/

      check "no space after ,", /,\S+/

      check "space after ( and [ or before ) and ]", /[\(\[]\s+|\s+[\)\]]/

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
    e(message + "\n\t" + @oline)
  end

  def warning(message)
    @warnings += 1
    e "warning: #{message}"
  end

  def e(message)
    $stderr.puts "#{@line_count}: #{message}"
  end
end