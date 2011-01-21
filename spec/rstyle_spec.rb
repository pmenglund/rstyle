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

require "spec_helper"

describe Rstyle do

  before(:each) do
    @s = Rstyle.new
    @s.stub(:e)
  end

  it "should read the correct number of lines" do
    @s.input = %w(a b c)
    @s.parse
    @s.line_count.should == 3
    @s.errors.should == 0
  end

  it "should catch lines with only whitespace in them" do
    @s.input = " "
    @s.parse
    @s.errors.should == 1
  end

  it "should catch lines with tabs" do
    @s.input = "\tx"
    @s.parse
    @s.errors.should == 1
  end

  it "should catch whitespace at the end of a line" do
    @s.input = "x "
    @s.parse
    @s.errors.should == 1
  end

  it "should catch methods not in snake_case" do
    @s.input = ["def FooBar", "def foo_bar"]
    @s.parse
    @s.errors.should == 1
  end

  it "should catch , without spaces after" do
    @s.input = ["func(a,b)", "func(a, b)"]
    @s.parse
    @s.errors.should == 1
  end

  it "should catch spaces after ( & [ and before ) & ]" do
    @s.input = [
        "func( x)", "func(x )", "func(x)",
        "[ a, b]", "[a, b ]", "[a, b]"
    ]
    @s.parse
    @s.errors.should == 4
  end

  it "should catch lines longer than 80 characters" do
    @s.input = ["x" * 81, "y" * 80]
    @s.parse
    @s.errors.should == 1
  end

  it "should warn about the use of for" do
    @s.input = "  for x in @foo"
    @s.parse
    @s.warnings.should == 1
  end
end