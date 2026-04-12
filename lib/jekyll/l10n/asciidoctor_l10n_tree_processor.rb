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
        accept_mt = @jekyll_l10n_config.accept_mt
        units = asciidoc.extract_units
        units.each do |unit|

          po_file_path = Jekyll::L10n::Util.resolve_po_path(unit.source_path, @jekyll_l10n_config.po_base_dir)
          po = @po_repository.load_file(po_file_path.to_path)
          entry = po[unit.text]
          unless entry.nil?
            if !entry.fuzzy? || accept_mt.include?(entry.mt)
              unit.text = entry.msgstr
            end
          end
        end
      end
    end
  end
end
