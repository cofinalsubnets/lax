lax
===
Lax is an insouciant smidgen of a testing framework that tries hard to be an invisible wrapper around your ideas about how your code works.
```ruby
Lax.scope do
  let number: 1,             # let defines assertion targets
      string: 'Hi There',
      regexp: defer{ /the/ } # for lazy evaluation

  assert do
    number + 1 == 2
    string.downcase =~ regexp
  end

  before { puts "i am a callback" }
  after  { puts "are stackable" }

  scope 'documented tests' do  # named assertion groups
    before { puts "callbacks are scoped like targets" }
    after  { puts "and also" }

    let number:  2,
        nothing: regexp.match('ffff') # compound target
        bool:    true

    assert do
      number - 1 == 1
      string.upcase == 'HI THERE' # string is in scope
      nothing == nil
    end
  end

  scope do
    let lax: self,
        open_file: fix(read: "data\nof\nimmediate\ninterest ") # fixtures
    assert do
      lax.respond_to?(:bool) == false # bool is out of scope
      open_file.read.lines.map(&:strip).size == 4
    end
  end
end

Lax.validate #=> green dots aww yeah
```
how come lax is neat
--------------------
* Minimal legalese.
* Easy-to-define custom matchers and hooks.
* Built-in Rake task generator for quick setup.
* Small but strong! (< 250 SLOC)
* Does not work by infecting the entire object system with its code - neighbourly!

how to make it do it
--------------------
```shell
  gem install lax
  cd my/project/root
  echo "require 'lax/rake_task'; Lax::RakeTask.new" >> Rakefile
  # write tests in yr test directory (defaults to 'test')
  rake lax
```

license
-------
MIT/X11. See LICENSE for details.

