# Copyright 2025 Chris Blunt
# Licensed under the Apache License, Version 2.0

module OGL::Backoff
  def self.next_delay(attempt : Int32) : Time::Span
    base = {1.second, 2.seconds, 4.seconds, 8.seconds, 16.seconds}
    d = base[Math.min(attempt, base.size - 1)]
    d + (rand(300)).milliseconds  # jitter
  end
end