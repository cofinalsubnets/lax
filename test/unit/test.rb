Stilts.test {|assert|
  assert.calling(:upcase).on('asdf').returns('ASDF')
}

Stilts.test('asdf') {|test_that|
  test_that.satisfies {|n| n=='ASDF'}.calling(:upcase)
}


