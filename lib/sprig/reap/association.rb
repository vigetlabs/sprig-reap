module Sprig::Reap
  class Association
    attr_reader :association

    def initialize(association)
      @association = association
    end

    def klass
      name.to_s.classify.constantize
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

    def foreign_key
      association.options[:foreign_key] || name.to_s + '_id'
    end

    def polymorphic_type
      name.to_s + '_type'
    end

  end
end
