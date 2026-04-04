require 'asciidoctor'
require 'asciidoctor/extensions'
require_relative './document_processor'

module Jekyll
  module L10n
    class AsciidoctorL10nTreeProcessor < ::Asciidoctor::Extensions::TreeProcessor

      include Asciidoctor::Logging

      def initialize(options)
        @jekyll_l10n_config = options[:jekyll_l10n_config]
        @po_repository = @jekyll_l10n_config.po_repository
        super(options)
      end

      def process(document)
        if @jekyll_l10n_config.mode == 'translate'
          translate(document)
        end
      end

      def translate(document)
        asciidoc = Jekyll::L10n::Model::Asciidoc.new(document)
        sentences = asciidoc.extract_sentences
        sentences.each do |sentence|

          po_file_path = Jekyll::L10n::Util.resolve_po_path(sentence.source, @jekyll_l10n_config.po_base_dir)
          po = @po_repository.load_file(po_file_path.to_path)
          translated = po[sentence.text]
          unless translated.nil?
            sentence.text = translated
          end
        end
      end
    end
  end
end
