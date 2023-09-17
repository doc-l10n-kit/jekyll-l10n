# frozen_string_literal: true

require_relative 'model/po'

module Jekyll
  module L10n
    class PoRepository

      include Asciidoctor::Logging

      def initialize(config)
        @po_map = Hash.new
        @po_base_dir = config.po_base_dir
      end

      def load_file(path)
        po = @po_map[path.to_sym]
        if po == nil # new file path
          if Pathname.new(path).exist?
            po = Jekyll::L10n::Model::Po.new(path, @po_base_dir)
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
        po = Jekyll::L10n::Model::Po.new(path, @po_base_dir)
        @po_map[path.to_sym] = po
      end

      def save_file(po)
        path = po.path
        File.open(path, mode = "w") do |file|
          po.write(file)
        end
      end

    end
  end
end
