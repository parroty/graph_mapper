require 'graph_mapper/dates'
require 'active_support/all'

module GraphMapper

class GroupingMapper
  def initialize(records, &block)
    @records = records
    @items   = accumulate_data_items(@records, block)
  end

  def count
    @items.size
  end

  def keys
    @items.map { |key,val| key }
  end

  def values
    @items.map { |key,val| val }
  end

  def hash
    @items
  end

private
  def accumulate_data_items(records, block)
    hash = Hash.new(0)
    records.each do | record |
      item = block.call(record)
      hash[item[:key]] += item[:value]
    end
    hash
  end
end

end