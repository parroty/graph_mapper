module GraphMapper
  class DateMapper
    def self.multiple_increment(date, count)
      count.times { date = increment(date) }
      date
    end

    def self.multiple_decrement(date, count)
      count.times { date = decrement(date) }
      date
    end
  end

  class DailyMapper < DateMapper
    def self.increment(date)
      date + 1
    end

    def self.decrement(date)
      date - 1
    end

    def self.get_baseline_date(date)
      date
    end
  end

  class WeeklyMapper < DateMapper
    def self.increment(date)
      date + 7
    end

    def self.decrement(date)
      date - 7
    end

    # return sunday
    def self.get_baseline_date(date)
      date - date.wday
    end
  end

  class MonthlyMapper < DateMapper
    def self.increment(date)
      date >> 1
    end

    def self.decrement(date)
      date >> -1
    end

    # return first day of the month
    def self.get_baseline_date(date)
       date - date.mday + 1
    end
  end
end