require 'rufus-scheduler'

s = Rufus::Scheduler.singleton

s.every '1h' do
  HackerNewsCurrentTopCollector.new.perform
end
