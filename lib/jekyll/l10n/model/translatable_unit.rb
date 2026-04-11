# frozen_string_literal: true

module Jekyll
  module L10n
    module Model
      class TranslatableUnit

        def source
          raise "not implemented"
        end

        def lineno
          raise "not implemented"
        end

        def text
          raise "not implemented"
        end

        def text=(value)
          raise "not implemented"
        end

        def inspect
          "#{lineno}: #{text.inspect}"
        end

        def to_s
          inspect
        end

      end
    end
  end
end
