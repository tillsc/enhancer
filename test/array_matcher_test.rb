#   Copyright 2011 Till Schulte-Coerne
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

require 'test/test_helper'

class ArrayMatcherTest < Test::Unit::TestCase

  module SomeGeneralEnhancement
    extend Enhancer
    
    def do_something_else
      "Very intelligent stuff"
    end
  end

  def test_full_matcher
    people = ["Till", "Tim"]
    people.enhance!("*" => "ArrayMatcherTest::SomeGeneralEnhancement")
    people.each do |person|
      assert_equal "Very intelligent stuff", person.do_something_else
    end
    assert_raise NoMethodError do
      "Till".do_something_else
    end
  end

  def test_fixnum_matcher
    array = (0..9).to_a.map(&:to_s)
    array.enhance!(2 => "ArrayMatcherTest::SomeGeneralEnhancement")
    assert_equal "Very intelligent stuff", array[2].do_something_else
    (array[0..1] +  array[3..9]).each do |element|
      assert_raise NoMethodError, "Element #{element} should not have the method 'do_something_else'." do
        element.do_something_else
      end
    end
  end

  def test_range_matcher
    array = (0..9).to_a.map(&:to_s)
    array.enhance!(3..7 => "ArrayMatcherTest::SomeGeneralEnhancement")
    array[3..7].each do |element|
      assert_equal "Very intelligent stuff", element.do_something_else
    end
    (array[0..2] +  array[8..9]).each do |element|
      assert_raise NoMethodError, "Element #{element} should not have the method 'do_something_else'." do
        element.do_something_else
      end
    end
  end

  def test_array_matcher
    array = (0..9).to_a.map(&:to_s)
    array.enhance!([-3, 2] => "ArrayMatcherTest::SomeGeneralEnhancement")
    array[-3, 2].each do |element|
      assert_equal "Very intelligent stuff", element.do_something_else
    end
    (array[0..6] +  array[9, 1]).each do |element|
      assert_raise NoMethodError, "Element #{element} should not have the method 'do_something_else'." do
        element.do_something_else
      end
    end
  end
  
end
