module Sprig::Reap
  module Inputs
    autoload :Environment,  'sprig/reap/inputs/environment'
    autoload :Model,        'sprig/reap/inputs/model'
    autoload :IgnoredAttrs, 'sprig/reap/inputs/ignored_attrs'

    module_function

    def Model(input)
      input.is_a?(Model) ? input : Model.new(input)
    end
  end
end
