require 'gruff'

module GraphAdapter
  
class Gruff
  GRAPH_SIZE = 250
  FONT_SIZE  = 1.8

  def initialize(klass, width = GRAPH_SIZE, font_size = FONT_SIZE, &block)
    @g = klass.new width
    @font_size = font_size

    setup
    block.call(self) if block
    self
  end

  def gruff
    @g
  end

  def set_labels(items, options = {:interval => 1})
    hash = {}
    items.each_with_index do | item, index |
      hash[index] = item if (index - 1) % options[:interval] == 0
    end

    self.gruff.labels = hash
  end

protected
  def setup
    @g.theme_pastel
    @g.legend_font_size *= @font_size
    @g.marker_font_size *= @font_size
    @g.title_font_size  *= @font_size

    font_name = 'Times-Roman'
    if Magick.fonts.include?(font_name)
      @g.font font_name
    end

    if @g.is_a?(::Gruff::Pie)
      @g.zero_degree = -90
    elsif @g.is_a?(::Gruff::Line)
      @g.line_width = 7
      @g.dot_radius = 5
    end
  end
end

end # module

