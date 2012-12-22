Lax.assert do
  let number: 1,
    string: 'asdf',
    symbol: :a_sym

  assert do
    number == 1
    assert do
      let number: 2
      number == 2

      string.upcase.downcase == 'asdf'
    end
  end

end
