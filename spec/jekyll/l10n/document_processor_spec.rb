require 'asciidoctor'
require 'asciidoctor/document'
require_relative '../../../lib/jekyll/l10n/document_processor'
require_relative '../../test/test_config'

describe Jekyll::L10n::DocumentProcessor do

  before(:each) do
    @spec_dir = Pathname(File.dirname(File.dirname(File.dirname(__FILE__))))
    @config = TestConfig.new
  end

  it 'translates document title and synopsis from PO file' do
    # Stub a Jekyll document with asciidoc data
    jekyll_document = double("jekyll_document")
    data = {
      'asciidoc' => true,
      'title' => 'Sample Guide',
      'synopsis' => 'Sample guide synopsis'
    }
    allow(jekyll_document).to receive(:data).and_return(data)
    allow(jekyll_document).to receive(:relative_path).and_return('sample.adoc')

    processor = Jekyll::L10n::DocumentProcessor.new(jekyll_document, @config)
    processor.translate

    expect(data['title']).to eq 'サンプルガイド'
  end

  it 'keeps original value when no translation exists' do
    jekyll_document = double("jekyll_document")
    data = {
      'asciidoc' => true,
      'title' => 'Untranslated Title',
      'synopsis' => 'Untranslated synopsis'
    }
    allow(jekyll_document).to receive(:data).and_return(data)
    allow(jekyll_document).to receive(:relative_path).and_return('sample.adoc')

    processor = Jekyll::L10n::DocumentProcessor.new(jekyll_document, @config)
    processor.translate

    expect(data['title']).to eq 'Untranslated Title'
    expect(data['synopsis']).to eq 'Untranslated synopsis'
  end

  it 'skips non-asciidoc documents' do
    jekyll_document = double("jekyll_document")
    data = {
      'asciidoc' => nil,
      'title' => 'Original Title'
    }
    allow(jekyll_document).to receive(:data).and_return(data)

    processor = Jekyll::L10n::DocumentProcessor.new(jekyll_document, @config)
    processor.translate

    expect(data['title']).to eq 'Original Title'
  end

end
