require 'graph_mapper/dates'

module GraphMapper

class CategoryMapper
  def initialize(records, start_date, end_date, options = nil, &block)
    category_hash = {}
    records.each do |record|
      if category_hash[record.category]
        category_hash[record.category] << record
      else
        category_hash[record.category] = [record]
      end
    end

    @mappers = {}
    category_hash.each do | category, records |
       @mappers[category] = Mapper.new(records, start_date, end_date, options, &block)
     end
  end

  def mapper(category)
    @mappers[category]
  end

  # TODO : which one of the mappers should be returned?
  def count
    @mappers.length > 0 ? @mappers.values.first.count : nil
  end

  # TODO : which one of the mappers should be returned?
  def keys
    @mappers.length > 0 ? @mappers.values.first.keys : nil
  end

  def values
    result = {}
    @mappers.each do | category, mapper |
      result[category] = mapper.values
    end
    result
  end

end # class

end # module
