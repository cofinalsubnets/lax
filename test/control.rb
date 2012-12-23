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

Lax.assert do
  let number: 1,
      string: 'Hi There',
      regexp: defer{ /the/ } # lazy evaluation

  number + 1 == 2
  string.downcase =~ regexp

#  before { puts "i am a callback" }
#  after  { puts "and also" }

  assert 'documented tests' do  # named assertion groups
#    before { puts "callbacks are scoped like targets" }
#    after  { puts "are stackable" }

    let number: 2
    number - 1 == 1
    string.upcase == 'HI THERE' # string is in scope

    let nothing: regexp.match('ffff') # compound targets are allowed
    nothing == nil
  end


  let lax: self
  lax.respond_to?(:bool) == false # bool is out of scope

  let open_file: fix(read: "data\nof\nimmediate\ninterest ") # fixtures
  open_file.read.lines.map(&:strip).size == 4

end

