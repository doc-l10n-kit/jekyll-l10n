require 'asciidoctor'
require 'asciidoctor/document'
require_relative '../../../../lib/jekyll/l10n/model/po'
require_relative '../../../../lib/jekyll/l10n/model/asciidoc'
require_relative '../../../../lib/jekyll/l10n/po_repository'
require_relative '../../../test/test_config'

describe Jekyll::L10n::Model::Po do

  before(:each) do
    @config = TestConfig.new
    @po_repository = Jekyll::L10n::PoRepository.new(@config)
    @spec_dir = Pathname(File.dirname(File.dirname(File.dirname(File.dirname(__FILE__)))))
  end

  it 'can look up translated entries' do
    po_file_path = @spec_dir.join('sample/po/sample.adoc.po')
    po = @po_repository.load_file(po_file_path.to_path)

    expect(po).not_to be_nil
    entry = po["Sample Guide"]
    expect(entry).not_to be_nil
    expect(entry.msgstr).to eq "サンプルガイド"
    expect(entry.fuzzy?).to be false
    expect(po["This is a sample text."].msgstr).to eq "これはサンプルテキストです。"
    expect(po["This is a second paragraph."].msgstr).to eq "これは2段落目です。"
  end

  it 'can update entries from extracted units' do
    po_file_path = @spec_dir.join('sample/po/sample.adoc.po')
    adoc_file_path = @spec_dir.join('sample/adoc/sample.adoc')
    adoc_base_dir = @spec_dir.join('sample/adoc')

    attributes = {"skip-front-matter" => true, "site-source" => adoc_base_dir.to_path }
    document = Asciidoctor.load_file adoc_file_path.to_path, safe: :safe, sourcemap: true, attributes: attributes
    asciidoc = Jekyll::L10n::Model::Asciidoc.new(document)
    units = asciidoc.extract_units
    po = @po_repository.load_file(po_file_path.to_path)

    expect { po.update_entries(units) }.not_to raise_error
  end

  it 'returns nil for nil or empty key' do
    po_file_path = @spec_dir.join('sample/po/sample.adoc.po')
    po = @po_repository.load_file(po_file_path.to_path)

    expect(po[nil]).to be_nil
    expect(po[""]).to be_nil
  end

  it 'returns a fuzzy entry with fuzzy? flag' do
    po_file_path = @spec_dir.join('sample/po/fuzzy.adoc.po')
    po = @po_repository.load_file(po_file_path.to_path)

    expect(po).not_to be_nil
    entry = po["Sample Guide"]
    expect(entry).not_to be_nil
    expect(entry.fuzzy?).to be true
    expect(entry.msgstr).to eq "サンプルガイド"
  end

  it 'returns mt engine from extracted comment' do
    po_file_path = @spec_dir.join('sample/po/fuzzy-mt-gemini.adoc.po')
    po = @po_repository.load_file(po_file_path.to_path)

    expect(po).not_to be_nil
    entry = po["Sample Guide"]
    expect(entry).not_to be_nil
    expect(entry.fuzzy?).to be true
    expect(entry.mt).to eq "gemini"
    expect(entry.msgstr).to eq "サンプルガイド"
  end

  it 'returns nil for mt when no mt comment' do
    po_file_path = @spec_dir.join('sample/po/sample.adoc.po')
    po = @po_repository.load_file(po_file_path.to_path)

    entry = po["Sample Guide"]
    expect(entry.mt).to be_nil
  end

  it 'adds type comments to entries' do
    require 'tempfile'

    # Create a temporary PO file to test with
    temp_file = Tempfile.new(['test', '.po'])
    temp_file.write(<<~PO)
      msgid ""
      msgstr ""
      "Language: ja_JP\\n"
      "MIME-Version: 1.0\\n"
      "Content-Type: text/plain; charset=UTF-8\\n"
      "Content-Transfer-Encoding: 8bit\\n"
      "X-Generator: jekyll-l10n\\n"

      #: sample.adoc
      msgid "Sample Title"
      msgstr "サンプルタイトル"

      #: sample.adoc
      msgid "Sample text content"
      msgstr "サンプルテキスト"
    PO
    temp_file.close

    po = @po_repository.load_file(temp_file.path)

    # Create mock units with type comments
    section_unit = double("SectionTitle",
      text: "Sample Title",
      source_path: "sample.adoc",
      type_comment: "type: Title ="
    )

    block_unit = double("Block",
      text: "Sample text content",
      source_path: "sample.adoc",
      type_comment: "type: Plain text"
    )

    po.update_entries([section_unit, block_unit])

    # Check section title has correct type
    entry = po["Sample Title"]
    expect(entry).not_to be_nil
    expect(entry.extracted_comment).to eq("type: Title =")
    expect(entry.msgstr).to eq("サンプルタイトル")

    # Check plain text has correct type
    entry = po["Sample text content"]
    expect(entry).not_to be_nil
    expect(entry.extracted_comment).to eq("type: Plain text")
    expect(entry.msgstr).to eq("サンプルテキスト")

    temp_file.unlink
  end

  it 'preserves existing mt comment while updating type' do
    require 'tempfile'
    require 'gettext/po'

    # Create a temporary PO file with mt: comment
    temp_file = Tempfile.new(['test', '.po'])
    temp_file.write(<<~PO)
      msgid ""
      msgstr ""
      "Language: ja_JP\\n"
      "MIME-Version: 1.0\\n"
      "Content-Type: text/plain; charset=UTF-8\\n"
      "Content-Transfer-Encoding: 8bit\\n"
      "X-Generator: jekyll-l10n\\n"

      #. type: delimited block -
      #. mt: gemini
      #: sample.adoc
      msgid "Test content"
      msgstr "テストコンテンツ"
    PO
    temp_file.close

    po = @po_repository.load_file(temp_file.path)

    # Create a mock unit that returns "Test content" with type comment
    unit = double("Block",
      text: "Test content",
      source_path: "sample.adoc",
      type_comment: "type: Plain text"
    )

    po.update_entries([unit])

    entry = po["Test content"]
    expect(entry).not_to be_nil
    expect(entry.extracted_comment).to include("type: Plain text")
    expect(entry.extracted_comment).to include("mt: gemini")
    expect(entry.extracted_comment).not_to include("type: delimited block -")
    expect(entry.msgstr).to eq("テストコンテンツ")

    temp_file.unlink
  end

  it 'updates msgid when upstream text changes (e.g., newline removed) while preserving translation' do
    require 'tempfile'

    # Create a temporary PO file with a msgid containing a newline
    temp_file = Tempfile.new(['test', '.po'])
    temp_file.write(<<~PO)
      msgid ""
      msgstr ""
      "Language: ja_JP\\n"
      "MIME-Version: 1.0\\n"
      "Content-Type: text/plain; charset=UTF-8\\n"
      "Content-Transfer-Encoding: 8bit\\n"
      "X-Generator: jekyll-l10n\\n"

      #. type: Plain text
      #: sample.adoc
      msgid ""
      "The following extracts a value identified by the `keyName` field from "
      "the `my-config-map` ConfigMap into a `foo`\\n"
      "environment variable:"
      msgstr "以下は、 `my-config-map` ConfigMap から `keyName` フィールドで識別される値を `foo` 環境変数に抽出したものです。"
    PO
    temp_file.close

    po = @po_repository.load_file(temp_file.path)

    # Verify old msgid exists (with newline)
    old_msgid = "The following extracts a value identified by the `keyName` field from the `my-config-map` ConfigMap into a `foo`\nenvironment variable:"
    entry = po[old_msgid]
    expect(entry).not_to be_nil
    expect(entry.msgstr).to eq("以下は、 `my-config-map` ConfigMap から `keyName` フィールドで識別される値を `foo` 環境変数に抽出したものです。")

    # Simulate upstream change: newline removed
    new_msgid = "The following extracts a value identified by the `keyName` field from the `my-config-map` ConfigMap into a `foo` environment variable:"

    # Create a mock unit with the new text (no newline)
    unit = double("Block",
      text: new_msgid,
      source_path: "sample.adoc",
      type_comment: "type: Plain text"
    )

    po.update_entries([unit])

    # Verify new msgid exists (without newline)
    entry = po[new_msgid]
    expect(entry).not_to be_nil
    expect(entry.msgid).to eq(new_msgid)
    expect(entry.msgstr).to eq("以下は、 `my-config-map` ConfigMap から `keyName` フィールドで識別される値を `foo` 環境変数に抽出したものです。")

    # Verify old msgid no longer exists
    entry_old = po[old_msgid]
    expect(entry_old).to be_nil

    temp_file.unlink
  end

  it 'handles normalization correctly: period-newline becomes period-double-space' do
    require 'tempfile'

    # Create a temporary PO file with a msgid containing ".\n"
    temp_file = Tempfile.new(['test', '.po'])
    temp_file.write(<<~PO)
      msgid ""
      msgstr ""
      "Language: ja_JP\\n"
      "MIME-Version: 1.0\\n"
      "Content-Type: text/plain; charset=UTF-8\\n"
      "Content-Transfer-Encoding: 8bit\\n"
      "X-Generator: jekyll-l10n\\n"

      #: sample.adoc
      msgid ""
      "First sentence.\\n"
      "Second sentence."
      msgstr "最初の文。2番目の文。"
    PO
    temp_file.close

    po = @po_repository.load_file(temp_file.path)

    # Verify old msgid exists
    old_msgid = "First sentence.\nSecond sentence."
    entry = po[old_msgid]
    expect(entry).not_to be_nil

    # Simulate upstream change: ".\n" becomes ".  " (period + double space)
    new_msgid = "First sentence.  Second sentence."

    unit = double("Block",
      text: new_msgid,
      source_path: "sample.adoc",
      type_comment: "type: Plain text"
    )

    po.update_entries([unit])

    # Verify new msgid exists (with double space)
    entry = po[new_msgid]
    expect(entry).not_to be_nil
    expect(entry.msgid).to eq(new_msgid)
    expect(entry.msgstr).to eq("最初の文。2番目の文。")

    temp_file.unlink
  end

end
