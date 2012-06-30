require 'date'
require 'graph_mapper'
require 'active_support/all'

class Stat; end

describe "GroupingMapper" do
  def create_stats(list)
    items = []
    list.each do | key, value, category |
      item = stub
      item.stub(:key).and_return(key)
      item.stub(:value).and_return(value)
      item.stub(:category).and_return(category)
      items << item
    end
    Stat.stub(:all).and_return(items)
  end

  it "should create mapper" do
    create_stats([["Food", 10], ["Food", 10], ["Entertain", 30], ["Drink", 40]])

    m = GraphMapper::GroupingMapper.new(Stat.all) do | record |
      { :key => record.key, :value => record.value.to_i }
    end

    m.count.should  == 3
    m.keys.should   == ["Food", "Entertain", "Drink"]
    m.values.should == [20, 30, 40]
  end
end