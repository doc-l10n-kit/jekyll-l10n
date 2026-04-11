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
    expect(po["Sample Guide"]).to eq "サンプルガイド"
    expect(po["This is a sample text."]).to eq "これはサンプルテキストです。"
    expect(po["This is a second paragraph."]).to eq "これは2段落目です。"
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

  it 'returns nil for a fuzzy entry' do
    po_file_path = @spec_dir.join('sample/po/fuzzy.adoc.po')
    po = @po_repository.load_file(po_file_path.to_path)

    expect(po).not_to be_nil
    expect(po["Sample Guide"]).to be_nil
  end

end
