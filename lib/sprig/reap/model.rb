module Sprig::Reap
  class Model
    include Logging
    include Inputs

    def self.all
      @@all ||= begin
        models = Sprig::Reap.models.map { |model_input| new(model_input) }

        tsorted_classes(models).map do |klass|
          models.find { |model| model.klass == klass }
        end
      end
    end

    def self.find(klass, id)
      all.find { |model| model.klass == klass }.find(id)
    end

    attr_reader :model_input, :klass
    attr_writer :existing_sprig_ids

    def initialize(model_input)
      @model_input = Sprig::Reap::Inputs.Model(model_input)
      @klass       = @model_input.klass
    end

    def attributes
      klass.column_names - Sprig::Reap.ignored_attrs
    end

    def dependencies
      @dependencies ||= associations.flat_map(&:dependencies)
    end

    def associations
      @associations ||= klass.reflect_on_all_associations.select(&has_dependencies?).map do |association|
        Association.new(association)
      end
    end

    def existing_sprig_ids
      @existing_sprig_ids ||= []
    end

    def generate_sprig_id
      existing_sprig_ids.select { |i| i.is_a? Integer }.sort.last + 1
    end

    def find(id)
      records.find { |record| record.id == id }
    end

    def to_s
      klass.to_s
    end

    def to_yaml(options = {})
      return if records.empty?

      namespace         = options[:namespace]
      formatted_records = [records.map(&:to_hash)]

      yaml = if namespace
        { namespace => formatted_records }.to_yaml
      else
        formatted_records.to_yaml
      end

      yaml.gsub!('- -', '  -') # Remove the extra array marker used to indent the sprig records
      yaml.gsub!("---\n", '')  # Remove annoying YAML separator
    end

    def records
      @records ||= model_input.records.map { |record| Record.new(record, self) }
    rescue => e
      log_error "Encountered an error when pulling the database records for #{to_s}:\n#{e.message}"
      []
    end

    private

    def has_dependencies?
      proc do |association|
        [:belongs_to, :has_and_belongs_to_many].include? association.macro
      end
    end

    def self.tsorted_classes(models)
      models.reduce(TsortableHash.new) do |hash, model|
        hash.merge(model.klass => model.dependencies)
      end.resolve_circular_habtm_dependencies!.tsort
    end
  end
end
