require 'date'
require 'graph_mapper'
require 'active_support/all'

class Stat; end

describe "Mapper" do
  context "test with Stat" do
    def hash_for_stats(record)
      { :key => Date.strptime(record.key, "%Y/%m/%d"), :value => record.value.to_i }
    end

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

    it "should calc with daily data" do
      create_stats([["2012/4/1", 10], ["2012/4/1", 10], ["2012/4/3", 20], ["2012/4/4", 40]])

      m = GraphMapper::Mapper.new(Stat.all, "2012/4/1", "2012/4/5") do | record |
        hash_for_stats(record)
      end

      m.count.should     == 4
      m.keys.should      == ["2012/04/01", "2012/04/02", "2012/04/03", "2012/04/04"]
      m.values.should    == [20, 0, 20, 40]
      m.average.should   == 20
      m.variation.should == [1.0, 0.0, 1.0, 2.0]
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
      m = GraphMapper::Mapper.new(Stat.all, "2012/4/1", "2012/6/10", options ) do | record |
        hash_for_stats(record)
      end

      m.count.should  == 3
      m.keys.should   == ["2012/04/01", "2012/05/01", "2012/06/01"]
      m.values.should == [30, 70, 0]
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

    it "should calc with null records - mapper" do
      Stat.stub(:all).and_return([])

      m = GraphMapper::Mapper.new(Stat.all, "2012/4/1", "2012/4/5") do | record |
        hash_for_stats(record)
      end

      m.count.should  == 4
      m.keys.should   == ["2012/04/01", "2012/04/02", "2012/04/03", "2012/04/04"]
      m.values.should == [0, 0, 0, 0]
    end

    context "Options - Moving Average" do
      def create_stats_for_moving_average(is_reverse)
        items = [["2012/3/30", 10], ["2012/3/31", 20],
                ["2012/4/1", 30], ["2012/4/2", 40], ["2012/4/3", 50], ["2012/4/4", 60]]
        items.reverse! if is_reverse
        create_stats(items)
      end

      def calc_moving_average
        options = { :moving_average_length => 3 }
        m = GraphMapper::Mapper.new(Stat.all, "2012/4/1", "2012/4/5", options) do | record |
          hash_for_stats(record)
        end

        m.count.should    == 4
        m.keys.should     == ["2012/04/01", "2012/04/02", "2012/04/03", "2012/04/04"]
        m.values.should   == [30, 40, 50, 60]
        m.average.should  == 45
        m.moving_average.should == [20, 30, 40, 50]
      end

      it "should calc with moving average (success - normal order records)" do
        create_stats_for_moving_average(false)
        calc_moving_average
      end

      it "should calc with moving average (success - reverse order records)" do
        create_stats_for_moving_average(true)
        calc_moving_average
      end

      it "should calc with moving average (error)" do
        create_stats_for_moving_average(false)
        m = GraphMapper::Mapper.new(Stat.all, "2012/4/1", "2012/4/5") do | record |
          hash_for_stats(record)
        end

        lambda { m.moving_average }.should raise_error
      end
    end

    context "CategoryMapper" do
      it "should calc with multiple categories" do
        create_stats([["2012/4/1", 10, "A"], ["2012/4/1", 10, "B"], ["2012/4/3", 20, "C"], ["2012/4/4", 30, "A"]])

        m = GraphMapper::CategoryMapper.new(Stat.all, "2012/4/1", "2012/4/5") do | record |
          { :key => Date.strptime(record.key, "%Y/%m/%d"), :value => record.value.to_i, :category => record.category }
        end

        m.count.should  == 4
        m.keys.should   == ["2012/04/01", "2012/04/02", "2012/04/03", "2012/04/04"]
        m.values.should == {"A" => [10, 0, 0, 30], "B" => [10, 0, 0, 0], "C" => [0, 0, 20, 0]}
      end

      it "should calc with empty records" do
        Stat.stub(:all).and_return([])

        m = GraphMapper::CategoryMapper.new(Stat.all, "2012/4/1", "2012/4/5") do | record |
          { :key => Date.strptime(record.key, "%Y/%m/%d"), :value => record.value.to_i, :category => record.category }
        end

        m.count.should  == 0
        m.keys.should   == []
        m.values.should == {}
      end
    end

    context "TimeWithZone" do
      it "should calc with TimeWithZone records" do
        Time.zone = 'Tokyo'
        apr1 = Time.zone.local(2012, 4, 1, 0, 0, 0)
        apr3 = Time.zone.local(2012, 4, 3, 0, 0, 0)
        apr4 = Time.zone.local(2012, 4, 4, 0, 0, 0)

        create_stats([[apr1, 10], [apr1, 10], [apr3, 20], [apr4, 30]])

        m = GraphMapper::Mapper.new(Stat.all, "2012/4/1", "2012/4/5") do | record |
          { :key => record.key, :value => record.value.to_i }
        end

        m.count.should  == 4
        m.keys.should   == ["2012/04/01", "2012/04/02", "2012/04/03", "2012/04/04"]
        m.values.should == [20, 0, 20, 30]
      end

      it "should calc with TimeWithZone range" do
        Time.zone = 'Tokyo'
        apr1 = Time.zone.local(2012, 4, 1, 0, 0, 0)
        apr5 = Time.zone.local(2012, 4, 5, 0, 0, 0)

        create_stats([["2012/4/1", 10], ["2012/4/1", 10], ["2012/4/3", 20], ["2012/4/4", 30]])

        m = GraphMapper::Mapper.new(Stat.all, apr1, apr5) do | record |
          { :key => record.key, :value => record.value.to_i }
        end

        m.count.should  == 4
        m.keys.should   == ["2012/04/01", "2012/04/02", "2012/04/03", "2012/04/04"]
        m.values.should == [20, 0, 20, 30]
      end
    end
  end
end
