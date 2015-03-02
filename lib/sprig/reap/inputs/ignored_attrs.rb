module Sprig::Reap::Inputs
  class IgnoredAttrs
    attr_reader :input

    def self.default
      new().list
    end

    def self.parse(input)
      new(input).list
    end

    def initialize(input = nil)
      @input = input || []
    end

    def list
      collection = input.is_a?(String) ? input.split(',') : Array(input)

      collection.map(&:to_s).map(&:strip)
    end
  end
end
