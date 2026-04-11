# frozen_string_literal: true

require_relative 'translatable_unit'

module Jekyll
  module L10n
    module Model
      class AbstractTranslatableUnit < TranslatableUnit

        def initialize(node)
          @node = node
        end

        def source
          # look up actual file the node belongs
          source_location = @node.source_location
          parent = @node.parent
          while source_location == nil && parent != nil
            source_location = parent.source_location
            parent = parent.parent
          end


          file = nil
          # if the file the node belongs is not found, uses docfile instead
          if source_location.nil? || source_location.file.nil?
            file = @node.document.options[:attributes]['docfile']
          else
            file = File.absolute_path(source_location.file, source_location.dir)
          end

          site_source = @node.document.options[:attributes]['site-source']

          Pathname(file).relative_path_from(site_source).to_path
        end

        def lineno
          @node.lineno
        end

        def text
          @node.source
        end

        def text=(value)
          @node.source = value
        end

        attr_reader :node

      end
    end
  end
end
