# frozen_string_literal: true

require 'gettext/po_parser'
require_relative '../../../gettext/po_entry_ext'

module Jekyll
  module L10n
    module Model
      class Po

        include Asciidoctor::Logging

        def initialize(path, po_base_dir)
          @path = path
          @po_base_dir = po_base_dir
          dirname = Pathname(path).dirname
          unless dirname.exist?
            raise "Parent directory #{dirname} doesn't exist."
          end

          @msgid_exact_map = load_po_object(path)
          @msgid_normalized_map = {}
          @msgid_exact_map.each do |entry|
            if entry.msgid.is_a?(String)
              normalized_message_id = entry.msgid.gsub(".\n", ".  ").gsub("\n", " ")
              @msgid_normalized_map[normalized_message_id] = entry
            end
          end
          header = GetText::POEntry.new(:normal)
          header.msgid = ""
          header.msgstr = <<-EOS
Language: ja_JP
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: jekyll-l10n
          EOS

          unless @msgid_exact_map.has_key?(header.msgid)
            @msgid_exact_map[header.msgid] = header
          end

        end

        attr_reader :path

        def [](key)
          if key.nil? || key.empty?
            return nil
          end
          if @msgid_exact_map.has_key? key
            @msgid_exact_map[nil, key]
          else
            logger.warn("msgid #{key.inspect} is not found in the po file.")
            nil
          end
        end


        def update_entries(units)
          entries = []
          units.each do |unit|
            entry = @msgid_exact_map[unit.text]
            if entry.nil?
              entry = @msgid_normalized_map[unit.text]
              if entry
                # Found via normalized map - update msgid to match current upstream text
                # while preserving the translation (msgstr)
                entry.msgid = unit.text
              end
            end

            if entry.nil?
              entry = GetText::POEntry.new(:normal)
              entry.msgid = unit.text
            end

            entry.references = [unit.source_path]

            # Set type comment
            type_comment = unit.type_comment
            if type_comment
              entry.extracted_comment = merge_extracted_comment(entry.extracted_comment, type_comment)
            end

            entries.append(entry)
          end


          po = GetText::PO.new(@msgid_exact_map.order)
          po[""] = @msgid_exact_map[""] # copy header
          entries.each do |entry|
            po[entry.msgid] = entry
          end
          @msgid_exact_map = po
        end

        private def merge_extracted_comment(existing_comment, type_comment)
          return type_comment if existing_comment.nil? || existing_comment.empty?

          # Remove old type: line if present, keep other lines (e.g., mt: gemini)
          lines = existing_comment.split("\n")
          non_type_lines = lines.reject { |line| line.start_with?("type:") }

          # Prepend new type comment
          [type_comment, *non_type_lines].join("\n")
        end

        def write(file)
          file.write(@msgid_exact_map.to_s)
        end

        def inspect
          @path
        end

        private def load_po_object(path)
          po = GetText::PO.new
          if Pathname.new(path).exist?
              parser = GetText::POParser.new
              parser.report_warning = false
              parser.ignore_fuzzy = false
              parser.parse_file(path, po)
          end
          po
        end

      end
    end
  end
end
