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

$: << File.join(File.dirname(__FILE__), "..")
require 'test/test_helper'

class HashMatcherTest < Test::Unit::TestCase

  module Address
    extend Enhancer

    match :indirect, "HashMatcherTest::SomeGeneralEnhancement"

    def do_something
      "Done."
    end

  end

  module Person
    extend Enhancer

    match :address, "HashMatcherTest::Address" do
      match :country do
        match :iso_code, "HashMatcherTest::SomeGeneralEnhancement"
      end
    end

  end

  module SomeGeneralEnhancement
    extend Enhancer
    
    def do_something_else
      "Very intelligent stuff"
    end
  end

  def test_simple_matcher
    person = { :name => "Till",
      :address => {
        :street => "Halskestr. 17"
      }
    }
    person.enhance!(Person)
    assert_equal "Done.", person[:address].do_something
  end

  def test_recursive_matching
    person = { :name => "Till",
      :address => {
        :country => {:iso_code => 'de', :name => 'Deutschland'},
        :street => "Halskestr. 17"
      }
    }
    person.enhance!(Person)
    assert_equal "Very intelligent stuff", person[:address][:country][:iso_code].do_something_else
  end

  def test_inline_extension
    hash = {:a => 'x'}.enhance!(:a => "HashMatcherTest::SomeGeneralEnhancement")
    assert_equal "Very intelligent stuff", hash[:a].do_something_else
    assert_raise NoMethodError do
      hash.do_something_else
    end
  end

  def test_indirect_enhancement # A matching of a module which has matchings
    person = { :name => "Till",
      :address => {:indirect => "Some data"}
    }
    person.enhance!(Person)
    assert_equal "Very intelligent stuff", person[:address][:indirect].do_something_else
  end
end
