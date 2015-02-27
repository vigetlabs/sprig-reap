module Sprig::Reap
  class Value
    attr_reader :sprig_record, :record, :attribute, :value, :raw_value

    delegate :model, :sprig_id, :to => :sprig_record

    def self.for(sprig_record, attribute)
      new(sprig_record, attribute).for_sprig_file
    end

    def initialize(sprig_record, attribute)
      @sprig_record = sprig_record
      @record       = sprig_record.record
      @attribute    = attribute
      @value        = record.send(attribute)
      @raw_value    = record.read_attribute(attribute)
    end

    def for_sprig_file
      @for_sprig_file ||= dependency? ? sprig_dependency_reference : read_attribute
    end

    private

    # Normalizes has-and-belongs-to-many attributes, which come in as `tag_ids`
    # We want to check for association FKs matching `tag_id`
    def normalized_foreign_key
      @normalized_foreign_key ||= attribute.singularize
    end

    def dependency?
      normalized_foreign_key.in? model.associations.map(&:foreign_key)
    end

    def association
      @association ||= model.associations.detect { |a| a.foreign_key == normalized_foreign_key }
    end

    def klass
      @klass ||= if association.polymorphic?
        record.send(association.polymorphic_type).constantize
      else
        association.klass
      end
    end

    def sprig_dependency_reference
      references = Array(value).map do |id|
        sprig_id = Model.find(klass, id).try(:sprig_id)

        sprig_record_reference(klass, sprig_id)
      end

      # For proper Sprig file formatting, need to return an array for HABTM
      association.has_and_belongs_to_many? ? references : references.first
    end

    def sprig_record_reference(klass, sprig_id)
      return if sprig_id.nil?

      "<%= sprig_record(#{klass}, #{sprig_id}).id %>"
    end

    def read_attribute
      file_attr = FileAttribute.new(value)

      file_attr.file.try(:sprig_location) || raw_value
    end
  end
end
