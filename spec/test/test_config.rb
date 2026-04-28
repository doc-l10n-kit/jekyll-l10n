require_relative '../../lib/jekyll/l10n/po_repository'

class TestConfig

  def mode
    @mode
  end

  def mode=(value)
    @mode = value
  end

  def po_base_dir
    Pathname.new("sample/po").expand_path(File.dirname(File.dirname(__FILE__))).to_path
  end

  def language
    "ja_JP"
  end

  def accept_mt
    @accept_mt || []
  end

  def accept_mt=(value)
    @accept_mt = value
  end

  def po_repository
    @po_repository ||= Jekyll::L10n::PoRepository.new(self)
  end

end