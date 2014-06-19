require "sprig/reap/version"
require "sprig/reap/railtie"

module Sprig::Reap
  autoload :Sprig,         'sprig'
  autoload :TsortableHash, 'sprig/reap/tsortable_hash'
  autoload :Configuration, 'sprig/reap/configuration'
  autoload :Model,         'sprig/reap/model'
  autoload :Record,        'sprig/reap/record'
  autoload :SeedFile,      'sprig/reap/seed_file'

  class << self
    def reap(input = {})
      options = Hash(input)

      configure do |config|
        config.target_env    = options[:target_env]    || options['TARGET_ENV']
        config.classes       = options[:models]        || options['MODELS']
        config.ignored_attrs = options[:ignored_attrs] || options['IGNORED_ATTRS']
      end

      Model.all.each { |model| SeedFile.new(model).write }
    end

    private

    cattr_reader :configuration

    delegate :target_env,
             :classes,
             :ignored_attrs,
             to: :configuration

    def configuration
      @@configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end
  end
end
