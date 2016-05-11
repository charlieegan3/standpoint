class ExampleWorker
  def perform(time_to_wait)
    puts "task complete"
  end
  handle_asynchronously :perform
end
