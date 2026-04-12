# frozen_string_literal: true

require 'gettext/po_entry'

module GetText
  class POEntry
    # Returns the machine translation engine name from extracted comments.
    # Looks for a comment line matching "mt: <engine>" (e.g., "mt: gemini", "mt: deepl").
    # Returns the engine name as a String, or nil if not found.
    def mt
      return nil if extracted_comment.nil? || extracted_comment.empty?

      match = extracted_comment.match(/^mt:\s*(\S+)/m)
      match ? match[1] : nil
    end
  end
end
