Lax.test {|assert|
  assert.on(rand(0..100)).it.satisfies {|n| Fixnum===n}
  assert.on(->{QWERTY.uiop[]}).calling(:call).raises
}

