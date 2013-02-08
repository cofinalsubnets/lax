let number: 1,
    string: 'asdf',
    symbol: :a_sym,
    regexp: /asd/

assert { number == 1 }

group do
  let number: 2

  test do
    assert_equal number, 2
    refute number.odd?
    assert string =~ regexp
    assert string.upcase != 'asdf'
  end
end

group do
  let number: 1,
      string: 'Hi There'
  let(:regexp) { /the/ } # lazy evaluation

  assert { string.upcase   == 'HI THERE' }
  assert { number          == 1          }
  assert { string.downcase =~ regexp     }


#  before { puts "i am a callback" }
#  after  { puts "stackable" }

  group do
#    before { puts "i will be run once for each assert block in my scope" }
#    after  { puts "callbacks are also" }
    before { @qqq=9 }
    let number:  2,
        nothing: regexp.match('ffff'),
        bool:    true

    test 'this is a named test!' do
      assert_equal @qqq, 9  # callbacks and assertions are evaluated in the same context
      assert_equal number - 1, 1
      assert_equal string.upcase, 'HI THERE' # string is still in scope
      assert nothing.nil?
    end
  end

  group do
    let lax:       self,
        open_file: fix(read: "data\nof\nimmediate\ninterest ") # built-in fixtures

    test do
      refute lax.respond_to?(:bool) # bool is now out of scope
      assert_equal open_file.read.lines.map(&:strip).size, 4
    end
  end
end

