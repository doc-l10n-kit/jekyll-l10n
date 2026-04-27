require 'asciidoctor'
require 'asciidoctor/document'
require_relative '../../../../lib/jekyll/l10n/model/asciidoc'

describe Jekyll::L10n::Model::Asciidoc do

  before(:each) do
    @spec_dir = Pathname(File.dirname(File.dirname(File.dirname(File.dirname(__FILE__)))))
    adoc_base_dir = @spec_dir.join('sample/adoc')
    file_path = @spec_dir.join('sample/adoc/sample.adoc')
    attributes = {"skip-front-matter" => true, "site-source" => adoc_base_dir.to_path }
    document = Asciidoctor.load_file file_path, safe: :safe, sourcemap: true, attributes: attributes
    @asciidoc = Jekyll::L10n::Model::Asciidoc.new(document)
    @units = @asciidoc.extract_units
  end

  it 'extracts the expected number of units' do
    expect(@units.size).to eq 36
  end

  it 'extracts paragraph blocks' do
    blocks = @units.select { |u| u.is_a?(Jekyll::L10n::Model::Block) }
    texts = blocks.map(&:text)
    expect(texts).to include("This is a sample text.")
    expect(texts).to include("This is a second paragraph.")
    expect(texts).to include("This is a note section.")
    expect(texts).to include("This is a tip")
    expect(texts).to include("This is an important note.")
    expect(texts).to include("This is a sentence next to a table")
  end

  it 'extracts section titles' do
    titles = @units.select { |u| u.is_a?(Jekyll::L10n::Model::SectionTitle) }
    texts = titles.map(&:text)
    expect(texts).to eq ["Header level2", "Header level3", "Header Level4", "Term definition", "Table"]
  end

  it 'extracts list items' do
    items = @units.select { |u| u.is_a?(Jekyll::L10n::Model::ListItem) }
    texts = items.map(&:text)
    expect(texts).to include("List level1")
    expect(texts).to include("List Level2-1")
    expect(texts).to include("List Level3")
    expect(texts).to include("A footnote for source code")
  end

  it 'extracts table cells' do
    cells = @units.select { |u| u.is_a?(Jekyll::L10n::Model::Cell) }
    texts = cells.map(&:text)
    expect(texts).to include("Header1", "Header2", "Header3")
    expect(texts).to include("Cell1", "Note1")
  end

  it 'extracts block titles and list titles' do
    block_titles = @units.select { |u| u.is_a?(Jekyll::L10n::Model::BlockTitle) }
    expect(block_titles.map(&:text)).to eq ["Source code with a title"]

    list_titles = @units.select { |u| u.is_a?(Jekyll::L10n::Model::ListTitle) }
    expect(list_titles.map(&:text)).to eq ["List Title"]
  end

  it 'handles multi-line paragraphs as a single unit' do
    multiline = @units.find { |u| u.text&.include?("line breaks") }
    expect(multiline).not_to be_nil
    expect(multiline.text).to eq "This is a section with line breaks.\nSecond line.\nThird line."
  end

  it 'skips source code block body' do
    texts = @units.map(&:text)
    expect(texts).not_to include(a_string_matching(/HelloWorldResource/))
  end

end
