lax
===
Lax is an insouciant smidgen of a testing library that adds some optional RSpec-style glitz and glam to MiniTest. Lax aims to be as painless as possible to use, on the principle that an imperfectly-rigorous approach to testing is preferable to no testing at all.
```ruby
let number: 1,      # bindings visible in tests
    string: 'asdf',
    symbol: :a_sym,
    regexp: /asd/

assert { number == 1 } # short syntax

group "some nested tests" do
  let number: 2     # bindings can be overridden in nested scopes

  test "that the world makes sense :/" do
    assert_equal number, 2   # normal MiniTest syntax is still available
    refute number.odd?
    assert string =~ regexp
    assert string.upcase != 'asdf'
  end
end

group do
  let number: 1,
      string: 'Hi There'
  let(:regexp) { /the/ } # lazy evaluation

  assert { string.upcase   == 'HI THERE' }
  assert { number          == 1          }
  assert { string.downcase =~ regexp     }


  before { puts "i am a callback" }
  after  { puts "stackable" }

  group do
    before { puts "i will be run once for each assert block in my scope" }
    after  { puts "callbacks are also" }
    before { @qqq=9 }

    let number:  2,
        nothing: regexp.match('ffff'),
        bool:    true

    test do # names are optional
      assert_equal @qqq, 9  # callbacks and assertions are evaluated in the same context
      assert_equal number - 1, 1
      assert_equal string.upcase, 'HI THERE' # string is still in scope
      assert nothing.nil?
    end
  end

  group do
    let lax:       self,
        open_file: fix(read: "data\nof\nimmediate\ninterest ") # built-in fixtures

    test do
      refute lax.respond_to?(:bool) # bool is now out of scope
      assert_equal open_file.read.lines.map(&:strip).size, 4
    end
  end
end

```
how come lax is neat
--------------------
* Tiny & hackable
* Minimal setup & legalese
* Output format is trivial to customize
* Does not work by infecting the entire object system with its code - neighbourly!

do it w/ rake
-------------
```ruby
require 'lax'
task(:lax) { Lax.run Dir['./my/test/directory/*.rb'] }
# boom done start hacking
```

license
-------
MIT/X11. See LICENSE for details.

