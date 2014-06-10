require "sprig/reap/version"

module Sprig::Reap
  autoload :TsortableHash, 'sprig/reap/tsortable_hash'
  autoload :Railtie,       'sprig/reap/railtie'
  autoload :Configuration, 'sprig/reap/configuration'
  autoload :Model,         'sprig/reap/model'
  autoload :Record,        'sprig/reap/record'
  autoload :SeedFile,      'sprig/reap/seed_file'

  class << self
    def reap(options = {})
      configure do |config|
        config.env     = options[:env]    || options['ENV']
        config.classes = options[:models] || options['MODELS']
      end

      Model.all.each { |model| SeedFile.new(model).write }
    end

    private

    cattr_reader :configuration

    delegate :env, :classes, to: :configuration

    def configuration
      @@configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end
  end
end
