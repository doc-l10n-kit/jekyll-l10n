# frozen_string_literal: true

require_relative 'abstract_sentence'

module Jekyll
  module L10n
    module Model
      class PageTitle < Sentence

        def initialize(jekyll_page)
          @jekyll_page = jekyll_page
        end

        def source
          file = @jekyll_page.path
          Pathname(file).to_path
        end

        def lineno
          1 #TODO
        end

        def text
          @jekyll_page.data['title']
        end

        def text=(value)
          @jekyll_page.data['title'] = value
        end

      end
    end
  end
end
