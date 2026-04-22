# frozen_string_literal: true

require_relative 'abstract_translatable_unit'

module Jekyll
  module L10n
    module Model
      class Block < AbstractTranslatableUnit

        def text
          @node.source
        end

        def text=(value)
          lines = value.split(/\R/)
          @node.instance_variable_set('@lines', lines)
        end

        def type_comment
          "type: Plain text"
        end

      end
    end
  end
end
