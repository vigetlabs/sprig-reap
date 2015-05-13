module Blog
  class Activity < ActiveRecord::Base
    def self.table_name_prefix
      'blog_'
    end

    belongs_to :context, :polymorphic => true
  end
end
