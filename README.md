lax
===
Lax is an insouciant smidgen of a testing framework that strives to be a nigh-on-invisible wrapper around your ideas about how your code should work. Accordingly, while Lax accommodates a fairly descriptive, semantic style:
```ruby
  class MyTests < Lax::Group
    def tests
      let subject {'asdf'} do
        it {is_a? String}
        it satisfies {|s| s.size == 4}
      end
    end
  end
```
it prefers a much terser one:
```ruby
  Lax.test {
    s {999} < 1000

    _ s{1/0} {
      x StandardError
      x ZeroDivisionError
    }

    _ s{'test'} {
      it =~ /t/
      its {size} == 4

      _ its {upcase} {
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

