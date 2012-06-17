require 'date'
require 'graph_mapper'
require 'active_support/all'

describe "DateMapper" do
  context "single" do
    it "should increment" do
      GraphMapper::DailyMapper.increment(Date.today).should == (Date.today + 1)
    end

    it "should decrement" do
      GraphMapper::DailyMapper.decrement(Date.today).should == (Date.today - 1)
    end
  end

  context "multiple" do
    it "should increment" do
      GraphMapper::DailyMapper.multiple_increment(Date.today, 4).should == (Date.today + 4)
    end

    it "should decrement" do
      GraphMapper::DailyMapper.multiple_decrement(Date.today, 4).should == (Date.today - 4)
    end
  end
end