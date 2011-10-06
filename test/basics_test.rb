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

class BasicsTest < Test::Unit::TestCase

  module TestEnhancement

    extend Enhancer

    def a_plus_b
      self[:a] + self[:b]
    end

    def do_something
      "Done."
    end

  end

  def test_basic_enhancement
    hash = {:a => 1, :b => 2}
    hash.enhance!(TestEnhancement)

    assert_equal 3, hash.a_plus_b

    assert_raise NoMethodError do
      {1 => 2}.a_plus_b
    end
  end

  def test_inline_enhancement
    assert_equal 5, {:a => 2, :b => 3}.enhance!(TestEnhancement).a_plus_b
  end

  def test_use_of_eigenclass
    str = "data".enhance!(TestEnhancement)
    assert_equal "Done.", str.do_something
    assert_raise NoMethodError do
      "data".do_something
    end
  end

  def test_fixnum_enhancement_error
    assert_raise TypeError do
      1.enhance!(TestEnhancement)
    end
  end

end
