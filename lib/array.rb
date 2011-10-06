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

class Array

  def enhance!(*args)
    if Enhancer.array_matcher_strategy == :implicit
      enhance_implicit(*args)
    else
      enhance_explicit(*args)
    end
  end

  def enhance_implicit(*args)
    self.each do |element|
      element.enhance!(*args)
    end
    self
  end

  def enhance_explicit(*args)
    args.each do |matcher_or_module_klass|
      if matcher_or_module_klass.is_a?(Hash) # It's a matcher
        matcher_or_module_klass.each do |key, enhancements|
          if key == "*"
            self.each do |element|
              element.enhance!(*enhancements)
            end
          elsif key.is_a?(Fixnum)
            self[key].enhance!(*enhancements) if self[key]
          elsif key.is_a?(Range)
            self[key].each do |element|
              element.enhance!(*enhancements)
            end
          elsif key.is_a?(Array) && key.length == 2
            self[key[0], key[1]].each do |element|
              element.enhance!(*enhancements)
            end
          else
            raise "Array#enhance!: Matcher '#{key.inspect}' unknown."
          end
        end
      else
        super(matcher_or_module_klass) # see Object
      end
    end

    self
  end

end