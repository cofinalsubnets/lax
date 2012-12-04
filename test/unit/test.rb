Lax.test {|assert|
  assert.calling(:upcase).on('asdf').returns('ASDF')
}

Lax.test('asdf') {|test_that|
  test_that.satisfies {|n| n=='ASDF'}.calling(:upcase)
}


