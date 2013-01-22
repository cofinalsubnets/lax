let number: 1,
    string: 'asdf',
    symbol: :a_sym,
    regexp: /asd/

assert { number == 1 }

scope do
  let number: 2

  assert { number == 2 }
  refute { number.odd? }
  refute { string.upcase == 'asdf' }
  assert { string =~ regexp }
end

scope do
  let number: 1,
      string: 'Hi There'
  let(:regexp) { /the/ } # lazy evaluation

  assert { string.upcase == 'HI THERE' }
  assert { number == 1 }
  assert { string.downcase =~ regexp }

#  before { puts "i will be run once for each assert block in my scope" }
#  after  { puts "stackable" }

  scope do
#    before { puts "i am a callback" }
#    after  { puts "callbacks are also" }
    before { @qqq=9 }
    let number:  2,
        nothing: regexp.match('ffff'),
        bool:    true

    condition(:divides) {|n,d| n%d==0} # custom conditions
    condition_group(:even_multiple_of_five) do |n| # like "shared examples" in RSpec
      assert { n.even? }
      divides(n) {5}
    end

    even_multiple_of_five 30
    assert { @qqq == 9 } # callbacks and assertions are evaluated in the same context
    assert { number - 1 == 1 }
    assert { string.upcase == 'HI THERE' } # string is still in scope
    assert { nothing.nil? }
  end

  scope do
    let lax:       self,
        open_file: fix(read: "data\nof\nimmediate\ninterest ") # built-in fixtures

    refute { lax.respond_to?(:bool) }# bool is now out of scope
    assert { open_file.read.lines.map(&:strip).size == 4 }
  end
end

