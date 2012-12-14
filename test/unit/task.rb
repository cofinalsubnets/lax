Lax.test(obj: Lax::Task.new(dir: :lax)) { 
  it {
    satisfies { Rake::Task === self }
    satisfies { name == 'lax' }
    satisfies { prerequisites == %w{lax:load lax:run} }
  }
}
