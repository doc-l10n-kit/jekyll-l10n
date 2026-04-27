# frozen_string_literal: true

require_relative 'translatable_unit'

module Jekyll
  module L10n
    module Model
      class DocumentSynopsis < TranslatableUnit

        def initialize(jekyll_document)
          @jekyll_document = jekyll_document
        end

        def source_path
          file = @jekyll_document.data['document'].attributes['docfile']
          site_source = @jekyll_document.data['document'].attributes['site-source']
          Pathname(file).relative_path_from(site_source).to_path
        end

        def lineno
          1 #TODO
        end

        def text
          @jekyll_document.data['synopsis']
        end

        def text=(value)
          @jekyll_document.data['synopsis'] = value
        end

        def type_comment
          "type: YAML Front Matter: synopsis"
        end

      end
    end
  end
end
