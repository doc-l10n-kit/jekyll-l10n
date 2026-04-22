# frozen_string_literal: true

require_relative 'abstract_translatable_unit'

module Jekyll
  module L10n
    module Model
      class ListItem < AbstractTranslatableUnit

        def text
          @node.instance_variable_get('@text')
        end

        def text=(value)
          @node.text = value
        end

        def type_comment
          "type: Plain text"
        end
      end
    end
  end
end
