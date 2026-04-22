# frozen_string_literal: true

require_relative 'translatable_unit'

module Jekyll
  module L10n
    module Model
      class PageIntro < TranslatableUnit

        def initialize(jekyll_page)
          @jekyll_page = jekyll_page
        end

        def source_path
          file = @jekyll_page.path
          Pathname(file).to_path
        end

        def lineno
          1 #TODO
        end

        def text
          @jekyll_page.data['intro']
        end

        def text=(value)
          @jekyll_page.data['intro'] = value
        end

        def type_comment
          "type: YAML Front Matter: intro"
        end

      end
    end
  end
end
