require 'atomic'

require 'metriks/ewma'

class Metriks::Meter
  def initialize
    @count = Atomic.new(0)
    @start_time = Time.now

    @m1_rate  = Metriks::EWMA.new_m1
    @m5_rate  = Metriks::EWMA.new_m5
    @m15_rate = Metriks::EWMA.new_m15

    @thread = Thread.new do
      tick
    end
  end

  def tick
    @m1_rate.tick
    @m5_rate.tick
    @m15_rate.tick
  end

  def mark(val = 1)
    @count.update { |v| v + val }
    @m1_rate.update(val)
    @m5_rate.update(val)
    @m15_rate.update(val)
  end

  def count
    @count.value
  end

  def one_minute_rate
    @m1_rate.rate
  end

  def five_minute_rate
    @m5_rate.rate
  end

  def fifteen_minute_rate
    @m15_rate.rate
  end

  def mean_rate
    if count == 0
      return 0.0
    else
      elapsed = Time.now - @start_time
      count / elapsed
    end
  end

  def stop
    @thread.kill
  end
end