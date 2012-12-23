Lax.scope do
  let number: 1,
      string: 'asdf',
      symbol: :a_sym,
      regexp: defer{/asd/}

  scope do
    assert { number == 1 }
    scope do
      let number: 2
      assert do
        number == 2
        string.upcase.downcase == 'asdf'
        string =~ regexp
      end
    end
  end
end

Lax.scope do
  let number: 1,
      string: 'Hi There',
      regexp: defer{ /the/ }

  assert do
    number + 1 == 2
    string.downcase =~ regexp
  end

  scope do
    let number: 2
    assert { number - 1 == 1 }
  end
end

Lax.scope do
  let number: 1,
      string: 'Hi There',
      regexp: defer{ /the/ } # lazy evaluation

  assert do
    number + 1 == 2
    string.downcase =~ regexp
  end

#  before { puts "i am a callback" }
#  after  { puts "are stackable" }

  scope 'documented tests' do  # named assertion groups
#    before { puts "callbacks are scoped like targets" }
#    after  { puts "and also" }

    let number: 2,
        nothing: regexp.match('ffff')

    assert do
      number - 1 == 1
      string.upcase == 'HI THERE' # string is in scope
      nothing == nil
    end
  end

  let lax: self,
      open_file: fix(read: "data\nof\nimmediate\ninterest ") # fixtures
  assert do
    lax.respond_to?(:bool) == false # bool is out of scope
    open_file.read.lines.map(&:strip).size == 4
  end
end

