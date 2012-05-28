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

    # return SAT, as last day of the week (starting from SUN)
    def self.get_baseline_date(date)
      date + (6 - date.wday)
    end
  end

  class MonthlyMapper
    def self.increment(date)
      date >> 1
    end

    # return last day of the month
    def self.get_baseline_date(date)
      (date >> 1) - date.day
    end
  end
end