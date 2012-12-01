Stilts.group(1) {|that|
  that.calling(:/).with(0).raises ZeroDivisionError
  that.calling(:**) {|expn|
    expn.with(1).satisfies {|n|n==1}
    expn.with(2).satisfies ->(n){n==1}
  }
}
  Stilts.group { |assert|
    assert.calling(:/).on(1).with(0).raises ZeroDivisionError
    assert.satisfies(->(n) { n == 1 }) { |assert_equal_to_one|
      assert_equal_to_one.on(0).calling(:+).with 1
      assert_equal_to_one.on(1) {|identity_on_one|
        identity_on_one.calling(:*).with  1
        identity_on_one.calling(:**).with 2
        identity_on_one.calling(:+).with  0
      }
    }
  }

