let number: 1,
    string: 'asdf',
    symbol: :a_sym,
    regexp: /asd/

assert { that(number) == 1 }

scope do
  let number: 2

  assert do
    assert_equal number, 2
    refute number.odd?
    assert string =~ regexp
    assert string.upcase != 'asdf'
  end
end

scope do
  let number: 1,
      string: 'Hi There'
  let(:regexp) { /the/ } # lazy evaluation

  assert { that(string.upcase)   == 'HI THERE' }
  assert { that(number)          == 1          }
  assert { that(string.downcase) =~ regexp     }

#  before { puts "i will be run once for each assert block in my scope" }
#  after  { puts "stackable" }

  scope do
#    before { puts "i am a callback" }
#    after  { puts "callbacks are also" }
    before { @qqq=9 }
    let number:  2,
        nothing: regexp.match('ffff'),
        bool:    true

    assert do
      assert_equal @qqq, 9  # callbacks and assertions are evaluated in the same context
      assert_equal number - 1, 1
      assert_equal string.upcase, 'HI THERE' # string is still in scope
      assert nothing.nil?
    end
  end

  scope do
    let lax:       self,
        open_file: fix(read: "data\nof\nimmediate\ninterest ") # built-in fixtures

    assert do
      refute lax.respond_to?(:bool) # bool is now out of scope
      assert_equal open_file.read.lines.map(&:strip).size, 4
    end
  end
end

