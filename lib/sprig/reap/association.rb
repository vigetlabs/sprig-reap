module Sprig::Reap
  class Association
    attr_reader :association

    delegate :plural_name, :to => :association

    def initialize(association)
      @association = association
    end

    def klass
      polymorphic? ? nil : association.klass
    end

    def name
      association.options[:class_name] || association.name
    end

    def polymorphic?
      !!association.options[:polymorphic]
    end

    def polymorphic_dependencies
      return [] unless polymorphic?
      @polymorphic_dependencies ||= ActiveRecord::Base.subclasses.select { |model| polymorphic_match? model }
    end

    def polymorphic_match?(model)
      model.reflect_on_all_associations(:has_many).any? do |has_many_association|
        has_many_association.options[:as] == association.name
      end
    end

    def dependencies
      polymorphic? ? polymorphic_dependencies : Array(klass)
    end

    def polymorphic_type
      polymorphic? ? association.foreign_type : nil
    end

    def has_and_belongs_to_many?
      association.macro == :has_and_belongs_to_many
    end

    def has_and_belongs_to_many_attr
      association.association_foreign_key.pluralize if has_and_belongs_to_many?
    end

    def foreign_key
      has_and_belongs_to_many? ? association.association_foreign_key : association.foreign_key
    end
  end
end
