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
        sprig_id = Model.find(klass, id).sprig_id

        sprig_record(klass, sprig_id)
      else
        record.send(attr)
      end
    end

    def dependency?(attr)
      attr.in? model.associations.map(&:foreign_key)
    end

    def klass_for(attr)
      association_for(attr).klass
    end

    def association_for(attr)
      model.associations.detect { |a| a.foreign_key == attr }
    end

    def sprig_record(klass, sprig_id)
      "<%= sprig_record(#{klass}, #{sprig_id}).id %>"
    end
  end
end
