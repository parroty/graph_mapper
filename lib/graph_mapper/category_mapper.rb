require 'graph_mapper/dates'

module GraphMapper

class CategoryMapper
  def initialize(records, start_date, end_date, options = nil, &block)
    @mappers = {}
    category_hash = classify_records_by_category(records, &block)
    category_hash.each do | category, records |
       @mappers[category] = Mapper.new(records, start_date, end_date, options, &block)
    end
  end

  def mapper(category)
    @mappers[category]
  end

  # TODO : which one of the mappers should be returned?
  def count
    @mappers.length > 0 ? @mappers.values.first.count : 0
  end

  # TODO : which one of the mappers should be returned?
  def keys
    @mappers.length > 0 ? @mappers.values.first.keys : []
  end

  def values
    result = {}
    @mappers.each do | category, mapper |
      result[category] = mapper.values
    end
    result
  end

private
  def classify_records_by_category(records, &block)
    hash = {}
    records.each do | record |
      item = block.call(record)
      key  = item[:category]

      hash[key] ||= []
      hash[key] << record
    end
    hash
  end
end # class

end # module
