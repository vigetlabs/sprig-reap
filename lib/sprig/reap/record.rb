module Sprig::Reap
  class Record
    attr_reader :record, :model
    attr_writer :sprig_id

    delegate :id, to: :record

    def initialize(record, model)
      @record = record
      @model  = model
    end

    def attributes
      @attributes ||= model.attributes.delete_if { |a| a == "id" }
    end

    def to_hash
      attributes.reduce({"sprig_id" => sprig_id}) do |hash, attr|
        hash.merge(attr => get_value_for(attr))
      end.tap do |hash|
        hash.delete_if { |attr, value| value.nil? } if Sprig::Reap.omit_empty_attrs
      end
    end

    def sprig_id
      @sprig_id ||= model.existing_sprig_ids.include?(record.id) ? model.generate_sprig_id : record.id
    end

    private

    def get_value_for(attr)
      if dependency?(attr)
        klass    = klass_for(attr)
        id       = record.send(attr)
        sprig_id = Model.find(klass, id).try(:sprig_id)

        sprig_record(klass, sprig_id)
      else
        read_attribute attr
      end
    end

    def dependency?(attr)
      attr.in? model.associations.map(&:foreign_key)
    end

    def klass_for(foreign_key)
      association = association_for(foreign_key)

      if association.polymorphic?
        record.send(association.polymorphic_type).constantize
      else
        association.klass
      end
    end

    def association_for(foreign_key)
      model.associations.detect { |a| a.foreign_key == foreign_key }
    end

    def sprig_record(klass, sprig_id)
      return if sprig_id.nil?

      "<%= sprig_record(#{klass}, #{sprig_id}).id %>"
    end

    def read_attribute(attr)
      file_attr = FileAttribute.new(record.send(attr))

      file_attr.file.try(:sprig_location) || record.read_attribute(attr)
    end
  end
end
