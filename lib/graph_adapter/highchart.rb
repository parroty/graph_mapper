require 'lazy_high_charts'

module GraphAdapter

class Highchart
  def initialize(options)
    @title    = options[:title]
    @subtitle = options[:subtitle]
    @interval = options[:tick_interval] || 2

    create_default_chart
  end

  def data(hash)
    @chart.xAxis(:categories => hash[:key], :tickInterval => @interval)
    @chart.series(:name => hash[:name], :yAxis => 0, :data => hash[:value], :animation => false)
  end

  def get_charts
    @chart
  end

private
  def create_default_chart
    @chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(:text => @title)
      f.subtitle(:text => @subtitle)
      f.yAxis(:title => {:text => "Count"}, :min => 0)
      f.legend(:enabled => false)
      f.chart({:defaultSeriesType => "area"})
    end
  end
end

end  # module
