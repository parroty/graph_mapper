require 'graph_mapper/mapper'
require 'graph_mapper/dates'

module GraphMapper
  SPAN_DAILY   = DailyMapper
  SPAN_WEEKLY  = WeeklyMapper
  SPAN_MONTHLY = MonthlyMapper

  MIN_DATE = Date.new(0)
  DEFAULT_OPTIONS = { :span_type => SPAN_DAILY, :date_format => "%Y/%m/%d", :is_sum_all_records => false, :is_fill_gap_dates => true }

end