lax
===
Lax is an insouciant smidgen of a testing library that tries to provide as much familiar functionality as possible without exceeding ~~100~~ a couple hundred SLOC.
```ruby
let number: 1,
    string: 'asdf',
    symbol: :a_sym,
    regexp: /asd/

assert { number == 1 }

scope 'a named scope' do
  let number: 2

  assert { number == 2 }
  refute { number.odd? }
  refute { string.upcase == 'asdf' }
  assert { string =~ regexp }
end

scope do
  let number: 1,
      string: 'Hi There'
  let(:regexp) { /the/ } # alternate syntax for lazy evaluation

  assert { string.upcase == 'HI THERE' }
  assert { number == 1 }
  assert { string.downcase =~ regexp }

  before { puts "i will be run once for each assert block in my scope" }
  after  { puts "stackable" }

  scope do
    before { puts "i am a callback" }
    after  { puts "callbacks are also" }
    before { @qqq=9 }
    let number:  2,
        nothing: regexp.match('ffff'),
        bool:    true

    condition(:divides) {|n,d| n%d==0} # custom conditions
    macro :even_multiple_of_five do |n| # like "shared examples" in RSpec
      assert { n.even? }
      divides(n) {5}
    end

    even_multiple_of_five 30
    assert { @qqq == 9 } # callbacks and assertions are evaluated in the same context
    assert { number - 1 == 1 }
    assert { string.upcase == 'HI THERE' } # string is still in scope
    assert { nothing.nil? }
  end

  scope do
    let lax:       self,
        open_file: fix(read: "data\nof\nimmediate\ninterest ") # built-in fixtures

    refute { lax.respond_to?(:bool) }# bool is now out of scope
    assert { open_file.read.lines.map(&:strip).size == 4 }
  end
end
```
how come lax is neat
--------------------
* Minimal legalese
* Tiny & hackable
* Rake task generator for quick setup
* Support for concurrent testing (innately via threads, but separate processes are easy too)
* Does not work by infecting the entire object system with its code - neighbourly!

how to make it do it
--------------------
```shell
  gem install lax
  cd my/project/root
  echo "require 'lax/rake_task'; Lax::RakeTask.new" >> Rakefile
  # write tests in yr test directory (defaults to 'lax')
  rake lax
```

license
-------
MIT/X11. See LICENSE for details.

