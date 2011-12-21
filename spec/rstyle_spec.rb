# Copyright 2011 Martin Englund
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

require 'spec_helper'
require 'rstyle'

describe RStyle do

  before(:each) do
    @s = RStyle.new(["--all"])
    @s.stub(:e)
  end

  it "should read the correct number of lines" do
    @s.parse %w(a b c)
    @s.line_count.should == 3
    @s.errors.should == 0
  end

  it "should catch lines with only whitespace in them" do
    @s.parse [" "]
    @s.errors.should == 1
  end

  it "should catch lines with tabs" do
    @s.parse ["\tx"]
    @s.errors.should == 1
  end

  it "should catch whitespace at the end of a line" do
    @s.parse ["x "]
    @s.errors.should == 1
  end

  it "should catch methods not in snake_case" do
    @s.parse(["def FooBar", "def foo_bar"])
    @s.errors.should == 1
  end

  it "should catch , without spaces after" do
    @s.parse ["func(a,b)", "func(a, b)"]
    @s.errors.should == 1
  end

  it "should catch spaces after ( & [ and before ) & ]" do
    @s.parse [
        "func( x)", "func(x )", "func(x)",
        "[ a, b]", "[a, b ]", "[a, b]"]
    @s.errors.should == 4
  end

  it "should catch lines longer than 80 characters" do
    @s.parse ["x" * 81, "y" * 80]
    @s.errors.should == 1
  end

  it "should ignore , with space in comments" do
    @s.parse [" # x , y"]
    @s.errors.should == 0
  end

  it "should ignore errors when overriden" do
    @s.parse ["# RSTYLE: snake_case", "def FooBar"]
    @s.errors.should == 0
  end

  it "should ignore errors when overriden" do
    @s.parse ["# RSTYLE: tabs", "a\tb"]
    @s.errors.should == 0
  end

  it "should warn about the use of for" do
    @s.parse ["  for x in @foo"]
    @s.warnings.should == 1
  end
end