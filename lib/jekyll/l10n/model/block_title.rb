# frozen_string_literal: true

require_relative 'abstract_translatable_unit'

module Jekyll
  module L10n
    module Model
      class BlockTitle < AbstractTranslatableUnit

        def text
          @node.instance_variable_get('@title')
        end

        def text=(value)
          @node.title = value
        end
      end
    end
  end
end
