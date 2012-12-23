Lax.assert do
  let number: 1,
      string: 'asdf',
      symbol: :a_sym,
      regexp: defer{/asd/}

  assert do
    number == 1
    assert do
      let number: 2
      number == 2

      string.upcase.downcase == 'asdf'
      string =~ regexp
    end
  end
end

Lax.assert do
  let number: 1,
      string: 'Hi There',
      regexp: defer{ /the/ }
  number + 1 == 2
  string.downcase =~ regexp
  assert do
    let number: 2
    number - 1 == 1
  end
end

