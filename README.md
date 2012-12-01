Stilts
------
A bright smidgen of a testing framework with the right amount of wobble.

```ruby
  Stilts.group { |assert|
    assert.calling(:/).on(1).with(0).raises ZeroDivisionError
    assert.satisfies(->(n) { n == 1 }) { |returns_one|
      returns_one.calling(:+).on(0).with 1
      returns_one.on(1) {|identity_on_one|
        identity_on_one.calling(:*).with  1
        identity_on_one.calling(:**).with 2
        identity_on_one.calling(:+).with  0
      }
    }
  }
  Stilts.go!
```

Features
========
* Everything about a test is scopeable - methods, arguments, receivers, blocks, expectations, hooks, and any metadata you might care to attach.
* Four levels of hooks for controlling everything from exception handling to automatic REPL-ing of failed tests to terminal output.
* Built-in Rake task helper that will Make It Do It in about 60 seconds.
* Code footprint so small, it's hardly there at all (< 200 SLOC).
* Does not pollute your toplevel namespace or infect the entire Ruby object hierarchy with with its code.
* You don't have to learn another language to use Stilts. Ruby will do fine.

