# Make base class a Singleton Mongoid class

module Recipe
  extend ActiveSupport::Concern

  included do
    include Mongoid::Document

    before_create :confirm_singularity

    private_class_method :new

    private

      def confirm_singularity
        raise "#{self.class} is a Singleton class." if self.class.count > 0
      end

      def read_source
        # Get :normal for NormalRecipe, :jingdong for JingdongRecipe
        recipe = self.class.to_s.underscore.split('_')[0...-1].join('_')
        YAML.load File.read( config_for(recipe)  )
      end

      def config_for(source)
        File.join(Rails.root, 'config', 'recipes', "#{source}.yml")
      end
  end

  module ClassMethods

    def instance
      @_instance ||= (self.first || self.create)
    end
  end

end
