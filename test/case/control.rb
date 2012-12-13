Lax.test(obj: 1) {|that|
  that.calling(:/).with(0).raises ZeroDivisionError
  that.calling(:**) {|exponentiation|
    exponentiation.with(1).satisfies {|n|n==1}
    exponentiation.with(2).satisfies ->(n){n==1}
  }
}

Lax.test {
  calling(:/).on(1).with(0).raises ZeroDivisionError
  returns(1) {
    on(0).calling(:+).with 1
    on(1) {
      calling(:* ).with 1
      calling(:**).with 2
      calling(:+ ).with 0
    }
  }
}

Lax.test(msg: :object_id, cond: ->(v){Fixnum===v}) {
  on 1
  on 'asdf'
  on String
  on Lax
  calling(:size).on([1,2,3])
}

Lax.test(obj: 222) {|that|
  that.it.returns 222
}

