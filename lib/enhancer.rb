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

require 'active_support/core_ext'

require 'object'
require 'hash'
require 'array'

module Enhancer

  class MatchContext

    def initialize(block = nil)
      @matches_hash = {}
      self.instance_eval(&block) if block.is_a?(Proc)
    end

    def match(key, module_name = nil, &block)
      @matches_hash[key] ||= []
      @matches_hash[key] << module_name if module_name
      if block
        block_hash = MatchContext.new(block).matches_hash
        @matches_hash[key] << block_hash unless block_hash.empty?
      end
    end

    def matches_hash
      @matches_hash
    end

  end

  def matches
    @root_matching_context && [@root_matching_context.matches_hash]
  end

  def match(key, module_name = nil, &block)
    @root_matching_context ||= MatchContext.new()
    @root_matching_context.match(key, module_name, &block)
  end

  def self.modulize(module_or_name)
    if module_or_name.is_a?(Module)
      return module_or_name
    elsif module_or_name.is_a?(String) || module_or_name.is_a?(Symbol)
      return module_or_name.to_s.camelize.constantize
    else
      raise "Enhancer::modulize: module parameter (#{module_or_name.inspect}) must be a Module, String or Symbol"
    end
  end

end