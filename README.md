lax
===
Lax is an insouciant smidgen of a testing framework that tries to be a nigh-invisible wrapper around your ideas about how your code should work. Its syntax is accordingly terse:
```ruby
  Lax.test {
    # s for subject
    s{999} < 1000

    # _ opens up a new scope
    _ s{1/0} {
      # x for exception
      x StandardError
      x ZeroDivisionError
    }

    _ s{'test'} {
      it =~ /t/
      # its builds a compound subject
      its {size} == 4

      _ its {upcase} {
        # c for condition (although numerous helpers exist, as we have seen)
        c{size == 4}
        it == 'TEST'
      }
    }
  }
```
yes but why
-----------
* No bullshit legalese.
* No hardcoded constraints on terminal output, handling of failed tests, w/e - it's all done with user-configurable hooks.
* Code footprint so small it's hardly there (< 150 SLOC).
* Does not pollute your toplevel namespace or infect the entire Ruby object hierarchy with its code.

make it do it
-------------
```shell
  gem install lax
  cd my/project/root
  # write yr tests in test/dir/whatever/whocares.rb
```
Lax ships with a minimal executable:
```shell
  lax test/dir/my_test.rb
```
but it's easier to use & customize if you run it inside of Rake:
```ruby
  echo "require 'lax'; Lax::Task.new(dir: 'test/dir')" >> rakefile
  rake lax
```

license
-------
X11. See LICENSE for details.

