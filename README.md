lax
===
Lax is an insouciant smidgen of a testing library that tries to provide as much familiar functionality as possible without exceeding 100 SLOC.
```ruby
Lax.assert do
  let number: 1,
      string: 'Hi There'
  
  let(:regexp) { /the/ } # lazy evaluation

  that { string.upcase == 'HI THERE' }

  that { number + 1 == 2 }
  that { string.downcase =~ regexp }

  before { puts "i will be run once for each assert block in my scope" }
  after  { puts "stackable" }

  assert do
    before { puts "i am a callback" }
    after  { puts "callbacks are also" }
    before { @qqq=9 }

    let number: 2,
        nothing: regexp.match('ffff'),
        bool:    true

    condition(:divides) {|n,d| n%d==0} # custom conditions

    condition_group(:even_multiple_of_five) do |n| # like "shared examples" in RSpec
      that { n.even? }
      divides(n) {5}
    end

    even_multiple_of_five 30
    that { number + @qqq == 11} # callbacks and assertions are evaluated in the same context
    that { number - 1 == 1 }
    that { string.upcase == 'HI THERE' } # string is still in scope
    that { nothing == nil }
  end

  assert do
    let lax:       self,
        open_file: fix(read: "data\nof\nimmediate\ninterest ") # built-in fixtures
    that { lax.respond_to?(:bool) == false }# bool is now out of scope
    that { open_file.read.lines.map(&:strip).size == 4 }
  end
end
```
how come lax is neat
--------------------
* Minimal legalese
* Tiny & hackable
* Built-in Rake task generator for quick setup.
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

