# frozen_string_literal: true

require_relative 'model/asciidoc'
require_relative 'po_repository'
require_relative 'l10n_config'
require_relative 'util'

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
          accept_mt = @jekyll_l10n_config.accept_mt
          @jekyll_document.data['title'] = resolve_translation(po, @jekyll_document.data['title'], accept_mt)
          @jekyll_document.data['synopsis'] = resolve_translation(po, @jekyll_document.data['synopsis'], accept_mt)
        end
      end

      private

      def resolve_translation(po, text, accept_mt)
        entry = po[text]
        return text if entry.nil?
        if !entry.fuzzy? || accept_mt.include?(entry.mt)
          entry.msgstr
        else
          text
        end
      end

    end
  end
end
