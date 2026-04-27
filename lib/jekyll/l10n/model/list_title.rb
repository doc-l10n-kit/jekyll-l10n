# frozen_string_literal: true

require_relative 'abstract_translatable_unit'

module Jekyll
  module L10n
    module Model
      class ListTitle < AbstractTranslatableUnit

        def text
          @node.instance_variable_get('@title')
        end

        def text=(value)
          @node.title = value
        end

        def type_comment
          "type: Block title"
        end

      end
    end
  end
end
