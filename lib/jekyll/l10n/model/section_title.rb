# frozen_string_literal: true

require_relative 'abstract_translatable_unit'

module Jekyll
  module L10n
    module Model
      class SectionTitle < AbstractTranslatableUnit

        def text
          @node.instance_variable_get('@title')
        end

        def text=(value)
          @node.title = value
        end

        def type_comment
          level = @node.level
          "type: Title #{'=' * level}"
        end

      end
    end
  end
end
