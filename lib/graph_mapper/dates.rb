module GraphMapper
  class DailyMapper
    def self.increment(date)
      date + 1
    end

    def self.get_baseline_date(date)
      date
    end
  end

  class WeeklyMapper
    def self.increment(date)
      date + 7
    end

    def self.get_baseline_date(date)
      date - date.wday
    end
  end

  class MonthlyMapper
    def self.increment(date)
      date >> 1
    end

    def self.get_baseline_date(date)
      date - date.mday + 1
    end
  end
end