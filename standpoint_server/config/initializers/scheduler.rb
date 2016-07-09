if $PROGRAM_NAME == "/usr/local/bundle/bin/rake"
  require 'rufus-scheduler'

  s = Rufus::Scheduler.singleton

  s.every '1h' do
    HackerNewsCurrentTopCollector.new.perform
  end
end
