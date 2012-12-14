Lax.test(obj: Lax::Task.new(dir: :lax)) { 
  calling(:class).returns Rake::Task
  calling(:name).returns 'lax'
  calling(:prerequisites).returns %w{lax:load lax:run}
}

