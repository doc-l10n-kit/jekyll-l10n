require_relative 'model/asciidoc'
require_relative 'po_repository'
require_relative 'l10n_config'
require_relative 'util'

# frozen_string_literal: true

module Jekyll
  module L10n
    class DocumentProcessor

      include Asciidoctor::Logging

      def initialize(document, config)
        @jekyll_document = document
        @jekyll_l10n_config = config
        @po_repository = @jekyll_l10n_config.po_repository
      end

      def translate
        if @jekyll_document.data['asciidoc']
          document_path = @jekyll_document.relative_path
          po_file_path = Jekyll::L10n::Util.resolve_po_path(document_path, @jekyll_l10n_config.po_base_dir)
          po = @po_repository.load_file(po_file_path.to_path)
          @jekyll_document.data['title'] = po[@jekyll_document.data['title']] || @jekyll_document.data['title']
          @jekyll_document.data['synopsis'] = po[@jekyll_document.data['synopsis']] || @jekyll_document.data['synopsis']
        end
      end

    end
  end
end
