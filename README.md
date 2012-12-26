lax
===
Lax is an insouciant smidgen of a testing framework that tries hard to be an invisible wrapper around your ideas about how your code works.
```ruby
Lax.scope do
  let number: 1,             # let defines targets that are appropriately scoped and
      string: 'Hi There',    # re-instantiated for each assertion block.
      regexp: lazy{ /the/ }  # <- lazy evaluation

  assert do
    that number + 1 == 2,          # these assertions can pass or fail independently
         string.downcase =~ regexp

    that(regexp.hash).satisfies {|obj| obj.is_a? Fixnum} # you can also easily define your own conditions
  end

  string { upcase.strip == 'HI THERE' } # you can also make assertions like this

  before { puts "hiii. i am a callback. i will be run once for each assertion block in my scope." }

  scope do
    before { puts "i will be run after the before callback in my enclosing scope." }
    before { @this_ivar = 'is visible in assertion blocks' }
    after  { puts 'after callbacks also are a thing' }


    def self.number_is_even # rspec-like 'shared examples' can be defined like this.
      number { even? }
    end

    let number:  2,
        nothing: regexp.match('ffff') # compound target
        bool:    true

    number_is_even

    assert 'documented tests' do        # docstrings can optionally be attached to assertion groups.
      that number - 1 == 1,
           string.upcase == 'HI THERE', # string is still in scope
           nothing == nil
    end
  end

  scope do
    let lax: self,
        open_file: fix(read: "data\nof\nimmediate\ninterest ") # fixtures are also a thing
    assert do
      that lax.respond_to?(:bool) == false, # bool is out of scope
           open_file.read.lines.map(&:strip).size == 4
    end
  end
end

Lax.run #=> green dots aww yeah
```
how come lax is neat
--------------------
* Minimal legalese.
* Easy-to-define custom matchers.
* Built-in Rake task generator for quick setup.
* Small & hackable is a design goal (< 150 SLOC with plenty of hooks for your code)
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

