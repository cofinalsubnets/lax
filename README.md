lax
===
Lax is an insouciant smidgen of a testing framework that tries to be an invisible wrapper around your ideas about how your code should work.
```ruby
Lax.assert do
  let number: 1,
      string: 'Hi There',
      regexp: defer{ /the/ } # lazy evaluation

  number + 1 == 2
  string.downcase =~ regexp

  assert do
    let number: 2
    number - 1 == 1
  end
end

Lax::Run[ Lax ] #=> pass, pass, pass

```
how come lax is neat
--------------------
* Minimal legalese.
* Easy-to-define custom matchers and hooks.
* Hackable with a tiny code footprint (< 300 SLOC).
* Does not work by infecting the entire Ruby object hierarchy with its code.

how to make it do it
--------------------
```shell
  gem install lax
  cd my/project/root
  echo "require 'lax/rake_task'; Lax::RakeTask.new" >> Rakefile
  # write yr tests in the test directory (default test)
  rake lax
```

license
-------
MIT/X11. See LICENSE for details.

