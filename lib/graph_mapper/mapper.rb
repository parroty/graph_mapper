require 'graph_mapper/dates'
require 'active_support/all'

module GraphMapper

class Mapper
  def initialize(records, start_date, end_date, options = nil, &block)
    @records    = records
    @options    = merge_with_default_options(options)
    @start_date = normalize_date(start_date)
    @end_date   = normalize_date(end_date)

    items = accumulate_data_items(@records, @start_date, @end_date, block)

    if @options[:is_fill_gap_dates]
      items = fill_data_gap(items, @start_date, @end_date)
    end

    if @options[:is_sum_all_records]
      base_offset = calc_base_offset_upto_start_date(@records, @start_date, block)
      items = add_offsets(items, base_offset)
    end

    @items = items.sort
  end

  def count
    @items.size
  end

  def keys
    @items.map { |key,val| key.strftime(@options[:date_format]) }
  end

  def values
    @items.map { |key,val| val }
  end

  def average
    total = values.inject(0) { |sum,value| sum + value }
    total.to_f / values.size
  end

  def variation
    ave = average()
    values.map { |val| val.to_f / ave }
  end

private
  def fill_data_gap(items, start_date, end_date)
    current = get_baseline_date(start_date)
    while current < end_date
      items[current] = 0 unless items.has_key?(current)
      current = @options[:span_type].increment(current)
    end
    items
  end

  def calc_base_offset_upto_start_date(records, start_date, block)
    base = 0
    accumulate_data_items(records, MIN_DATE, start_date, block).each do | key, value |
      base += value
    end
    base
  end

  def add_offsets(hash, offset)
    hash.sort.each do | key, value |
      hash[key] += offset
      offset += value
    end
    hash
  end

  def merge_with_default_options(input_options)
    return DEFAULT_OPTIONS unless input_options

    output_options = {}
    DEFAULT_OPTIONS.each do | key, value |
      output_options[key] = input_options.has_key?(key) ? input_options[key] : value
    end
    output_options
  end

  def normalize_date(date)
    if date.nil?
      MIN_DATE
    elsif date.is_a?(String)
      Date.parse(date)
    elsif date.is_a?(ActiveSupport::TimeWithZone)
      date.localtime.to_date
    else
      date
    end
  end

  def get_data_with_default_format(record)
    { :key => Date.strptime(record.key, DEFAULT_OPTIONS[:date_format]), :value => record.value.to_i }
  end

  def accumulate_data_items(records, start_date, end_date, block)
    items = Hash.new(0)

    records.each do | record |
      if block
        item = block.call(record)
      else
        item = get_data_with_default_format(record)
      end

      date  = normalize_date(item[:key])
      value = item[:value]

      base_date = get_baseline_date(date)
      items[base_date] += value if is_effective_date?(date, start_date, end_date)
    end

    items
  end

  def is_effective_date?(date, start_date, end_date)
    start_date <= date and date < end_date
  end

  def get_baseline_date(date)
    @options[:span_type].get_baseline_date(date)
  end

end # class

end # module