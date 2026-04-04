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
        data = @jekyll_document.data
        if data && data['asciidoc']
          document_path = @jekyll_document.relative_path
          po_file_path = Jekyll::L10n::Util.resolve_po_path(document_path, @jekyll_l10n_config.po_base_dir)
          po = @po_repository.load_file(po_file_path.to_path)
          data['title'] = po[data['title']] || data['title']
          data['synopsis'] = po[data['synopsis']] || data['synopsis']
        end
      end

    end
  end
end
