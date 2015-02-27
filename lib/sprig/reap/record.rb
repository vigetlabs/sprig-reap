module Sprig::Reap
  class Record
    attr_reader :record, :model
    attr_writer :sprig_id

    delegate :id, :to => :record

    def initialize(record, model)
      @record = record
      @model  = model
    end

    def attributes
      @attributes ||= model.attributes.delete_if { |a| a == "id" } | model.associations.map(&:has_and_belongs_to_many_attr).compact
    end

    def to_hash
      attributes.reduce({"sprig_id" => sprig_id}) do |hash, attr|
        value = Value.for(self, attr)

        if Sprig::Reap.omit_empty_attrs && empty?(value)
          hash
        else
          hash.merge(attr => value)
        end
      end
    end

    def sprig_id
      @sprig_id ||= model.existing_sprig_ids.include?(record.id) ? model.generate_sprig_id : record.id
    end

    private

    def empty?(value)
      value.respond_to?(:empty?) ? value.empty? : value.nil?
    end
  end
end
