# frozen_string_literal: true

require_relative 'model/asciidoc'
require_relative 'po_repository'
require_relative 'util'

module Jekyll
  module L10n
    class L10nConfig

      def initialize(jekyll_config)
        @jekyll_config = jekyll_config
      end

      def mode
        @jekyll_config&.[]('l10n')&.[]('mode') || ENV['L10N_MODE']
      end

      def po_base_dir
        @jekyll_config&.[]('l10n')&.[]('po')&.[]('base_dir') || @jekyll_config&.[]('l10n')&.[]('po')&.[]('baseDir') || ENV['L10N_PO_BASE_DIR']
      end

      def language
        @jekyll_config&.[]('l10n')&.[]('language') || ENV['L10N_LANGUAGE']
      end

      def accept_mt
        value = @jekyll_config&.[]('l10n')&.[]('accept_mt') || ENV['ACCEPT_MT']
        return [] if value.nil? || value.empty?

        value.split(',').map(&:strip)
      end

      # Shared PoRepository instance to avoid duplicate PO file loading
      def po_repository
        @po_repository ||= Jekyll::L10n::PoRepository.new(self)
      end

    end
  end
end
