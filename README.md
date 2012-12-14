lax
===
An insouciant smidgen of a testing framework that is not the boss of you.
```ruby
  Lax.test {
    calling(:/).on(1).with(0).raises ZeroDivisionError

    returns(1) {
      calling(:+).on(0).with 1

      on(1) {
        calling(:+).with 0
        calling(:*).with 1

        0.upto(10) { |n|
          calling(:**).with n
        }
      }
    }
  }
  Lax.test!
```
yes but why
-----------
* Everything about a test is independently scopeable - methods, arguments, receivers, blocks, expectations, hooks, and any metadata you might care to attach. Testing that one method call satisfies three conditions is as natural as testing that one condition is satisfied by three different method calls. Write tests in whatever way makes sense.
* No hardcoded constraints on terminal output, handling of failed tests, w/e - it's all done with user-configurable hooks.
* Code footprint so small, it's hardly there at all (< 200 SLOC).
* Does not pollute your toplevel namespace or infect the entire Ruby object hierarchy with its code.

make it do it
-------------
```shell
  cd my/project/root
  mkdir -p lax/test
  echo "Lax.test {|that| that.calling(:+).on(1).with(99).returns 100}" > lax/test/test.rb
  echo "require 'lax'; Lax::RakeTask.new(:dir=>'lax')" >> rakefile
  rake lax
```

license
-------
X11. See LICENSE for details.

