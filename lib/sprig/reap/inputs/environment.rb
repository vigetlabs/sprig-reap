module Sprig::Reap::Inputs
  class Environment
    attr_reader :input

    def self.default
      new().env
    end

    def self.parse(input)
      new(input).env
    end

    def initialize(input = nil)
      @input = input || Rails.env
    end

    def env
      input.to_s.strip.downcase.tap do |target_env|
        folder = Rails.root.join('db', 'seeds', target_env)
        FileUtils.mkdir_p(folder) unless File.directory? folder
      end
    end
  end
end
