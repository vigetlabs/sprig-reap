module Sprig::Reap
  class Configuration

    def target_env
      @target_env ||= Sprig::Reap::Inputs::Environment.default
    end

    def target_env=(input)
       @target_env = Sprig::Reap::Inputs::Environment.parse(input)
    end

    def models
      @classes ||= Sprig::Reap::Inputs::Model.default
    end

    def models=(input)
      @classes ||= Sprig::Reap::Inputs::Model.parse(input)
    end

    def ignored_attrs
      @ignored_attrs ||= Sprig::Reap::Inputs::IgnoredAttrs.default
    end

    def ignored_attrs=(input)
      @ignored_attrs = Sprig::Reap::Inputs::IgnoredAttrs.parse(input)
    end

    def logger
      @logger ||= Logger.new($stdout)
    end

    def omit_empty_attrs
      @omit_empty_attrs ||= false
    end

    def omit_empty_attrs=(input)
      @omit_empty_attrs = true if String(input).strip.downcase == 'true'
    end
  end
end
