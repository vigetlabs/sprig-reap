module Sprig::Reap::Inputs
  class Model
    attr_reader :input

    def self.valid_classes
      @@valid_classes ||= begin
        Rails.application.eager_load!
        ActiveRecord::Base.subclasses
      end
    end

    def self.default
      valid_classes.map(&to_model_inputs)
    end

    def self.parse(input)
      collection = if input.is_a? String
        input.split(',').map { |string| string.strip }
      elsif input.is_a? ActiveRecord::Relation
        [input]
      else
        Array(input)
      end

      collection.map(&to_model_inputs)
    end

    def initialize(input)
      @input = input.is_a?(String) ? eval(input) : input

      validate!
    end

    def klass
      @klass ||= relation? ? input.klass : input
    end

    def records
      relation? ? input : input.all
    end

    private

    def self.to_model_inputs
      proc { |input| new(input) }
    end

    def valid_classes
      self.class.valid_classes
    end

    def validate!
      if valid_classes.exclude? klass
        raise ArgumentError, "Cannot create a seed file for #{klass} because it is not a subclass of ActiveRecord::Base."
      end
    end

    def relation?
      input.is_a? ActiveRecord::Relation
    end
  end
end
