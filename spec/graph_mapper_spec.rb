require 'date'
require 'graph_mapper'

class Stat; end

describe "GraphMapper" do
  context "test with Stat" do
    def hash_for_stats(record)
      { :key => Date.strptime(record.key, "%Y/%m/%d"), :value => record.value.to_i }
    end

    def create_stats(list)
      items = []
      list.each do | key, value |
        item = stub
        item.stub(:key).and_return(key)
        item.stub(:value).and_return(value)
        items << item
      end
      Stat.stub(:all).and_return(items)
    end

    it "should calc with daily data" do
      create_stats([["2012/4/1", 10], ["2012/4/1", 10], ["2012/4/3", 20], ["2012/4/4", 30]])

      m = GraphMapper::Mapper.new(Stat.all, "2012/4/1", "2012/4/5") do | record |
        hash_for_stats(record)
      end

      m.count.should  == 4
      m.keys.should   == ["2012/04/01", "2012/04/02", "2012/04/03", "2012/04/04"]
      m.values.should == [20, 0, 20, 30]
    end

    it "should calc with weekly data" do
      # 4/1(sun), 4/2(mon), 4/9(mon), 4/14(sat)
      create_stats([["2012/4/1", 10], ["2012/4/2", 20], ["2012/4/9", 30], ["2012/4/14", 40]])

      options = { :span_type => GraphMapper::SPAN_WEEKLY }
      m = GraphMapper::Mapper.new(Stat.all, "2012/4/1", "2012/4/15", options) do | record |
        hash_for_stats(record)
      end

      m.count.should  == 2
      m.keys.should   == ["2012/04/01", "2012/04/08"]
      m.values.should == [30, 70]
    end

    it "should calc with monthly data" do
      create_stats([["2012/4/1", 10], ["2012/4/2", 20], ["2012/5/9", 30], ["2012/5/14", 40]])

      options = { :span_type => GraphMapper::SPAN_MONTHLY }
      m = GraphMapper::Mapper.new(Stat.all, "2012/4/1", "2012/6/1", options ) do | record |
        hash_for_stats(record)
      end

      m.count.should  == 2
      m.keys.should   == ["2012/04/01", "2012/05/01"]
      m.values.should == [30, 70]
    end

    it "should sum all up until specified date (weekly)" do
      # 4/1(sun), 4/2(mon), 4/9(mon), 4/14(sat), 4/21(sat)
      create_stats([["2012/4/1", 10], ["2012/4/2", 20], ["2012/4/9", 30], ["2012/4/14", 40], ["2012/4/21", 50]])

      options = { :span_type => GraphMapper::SPAN_WEEKLY, :is_sum_all_records => true }
      m = GraphMapper::Mapper.new(Stat.all, "2012/4/9", "2012/4/22", options) do | record |
        hash_for_stats(record)
      end

      # m.count.should  == 2
      m.keys.should   == ["2012/04/08", "2012/04/15"]
      m.values.should == [100, 150]
    end

    it "should calc with date_format option" do
      create_stats([["2012/4/1", 10], ["2012/4/1", 10], ["2012/4/3", 20], ["2012/4/4", 30]])

      options = { :span_type => GraphMapper::SPAN_DAILY, :date_format => "%d" }
      m = GraphMapper::Mapper.new(Stat.all, "2012/4/1", "2012/4/5", options) do | record |
        hash_for_stats(record)
      end

      m.count.should  == 4
      m.keys.should   == ["01", "02", "03", "04"]
      m.values.should == [20, 0, 20, 30]
    end

    it "should calc with no block" do
      create_stats([["2012/4/1", 10], ["2012/4/1", 10], ["2012/4/3", 20], ["2012/4/4", 30]])

      m = GraphMapper::Mapper.new(Stat.all, "2012/4/1", "2012/4/5")

      m.count.should  == 4
      m.keys.should   == ["2012/04/01", "2012/04/02", "2012/04/03", "2012/04/04"]
      m.values.should == [20, 0, 20, 30]
    end

  end
end
