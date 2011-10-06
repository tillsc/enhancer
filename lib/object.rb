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

class Object

  def enhance!(*args)
    args.each do |matcher_or_module_klass|
      if matcher_or_module_klass.is_a?(Hash)
        #ignore the matcher
        puts("Object#enhance: There was a matcher '#{matcher_or_module_klass.inspect}' given for an object of class #{self.class.inspect} which didn't know what to do with it.")
      else # Must be a module class or a module class name
        @@module_klass = Enhancer.modulize(matcher_or_module_klass)
        class << self
          include @@module_klass
        end
        self.enhance!(*@@module_klass.matches) if @@module_klass.matches
      end
    end

    self
  end

end