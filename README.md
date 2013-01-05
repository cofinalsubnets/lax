lax
===
Lax is an insouciant smidgen of a testing framework that tries hard to be an invisible wrapper around your ideas about how your code works.
```ruby
Lax.assert do
  let number: 1,
      string: 'Hi There',
      regexp: lazy{ /the/ } # lazy evaluation

  that { string.upcase == 'HI THERE' }

  that { number + 1 == 2 }
  that { string.downcase =~ regexp }

  before { puts "i am a callback" }
  after  { puts "are stackable!" }

  assert do
    before { puts "i will be run once for each assert block in my scope" }
    after  { puts "callbacks also" }
    before { @qqq=9 }

    def number_is_even
      number.even?
    end

    let number: 2,
        nothing: regexp.match('ffff'),
        bool:    true

    that { number_is_even }
    that { number + @qqq == 11}
    that { number - 1 == 1 }
    that { string.upcase == 'HI THERE' } # string is in scope
    that { nothing == nil }
  end

  assert do
    let lax: self,
        open_file: fix(read: "data\nof\nimmediate\ninterest ") # fixtures
    that { lax.respond_to?(:bool) == false }# bool is out of scope
    that { open_file.read.lines.map(&:strip).size == 4 }
  end
end
```
how come lax is neat
--------------------
* Minimal legalese.
* Tiny & hackable (< 100 SLOC !!)
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

