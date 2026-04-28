# frozen_string_literal: true

require_relative 'model/po'

module Jekyll
  module L10n
    class PoRepository

      include Asciidoctor::Logging

      def initialize(config)
        @po_map = Hash.new
        @po_base_dir = config.po_base_dir
        @language = config.language
      end

      def load_file(path)
        po = @po_map[path.to_sym]
        if po.nil? # new file path
          if Pathname.new(path).exist?
            po = Jekyll::L10n::Model::Po.load(path, @po_base_dir)
            @po_map[path.to_sym] = po
            return po
          else
            @po_map[path.to_sym] = :file_not_found
            logger.warn("Failed to find corresponding po file: #{path}.")
            return nil
          end
        elsif po == :file_not_found
          return nil
        else
          return po
        end
      end

      def create_file(path)
        po = Jekyll::L10n::Model::Po.create(path, @po_base_dir, @language)
        @po_map[path.to_sym] = po
      end

      def save_file(po)
        perm = 0
        if Pathname.new(po.path).exist?
          File.open(po.path) do |po_file|
            perm = po_file.stat.mode
          end
        else
          perm = 0664
        end
        File.open(po.path + "~", "w", perm) do |file|
          po.write(file)
          File.rename(file.path, po.path)
        end
      end

    end
  end
end
