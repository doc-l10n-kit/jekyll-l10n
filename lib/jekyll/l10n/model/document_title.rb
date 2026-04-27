# frozen_string_literal: true

require_relative 'translatable_unit'

module Jekyll
  module L10n
    module Model
      class DocumentTitle < TranslatableUnit

        def initialize(jekyll_document)
          @jekyll_document = jekyll_document
        end

        def source_path
          @jekyll_document.relative_path
        end

        def lineno
          1 #TODO
        end

        def text
          @jekyll_document.data['title']
        end

        def text=(value)
          @jekyll_document.data['title'] = value
        end

        def type_comment
          "type: YAML Front Matter: title"
        end

      end
    end
  end
end
