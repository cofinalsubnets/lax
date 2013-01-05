Lax.assert do
  let number: 1,
      string: 'asdf',
      symbol: :a_sym,
      regexp: /asd/

  assert do
    that { number == 1 }
    assert do
      let number: 2
      that { number == 2 }
      that { number.even? }
      that { string.upcase.downcase == 'asdf' }
      that { string =~ regexp }
    end
  end
end

Lax.assert do
  let number: 1,
      string: 'Hi There'
  
  let(:regexp) { /the/ } # lazy evaluation

  that { string.upcase == 'HI THERE' }

  that { number + 1 == 2 }
  that { string.downcase =~ regexp }

#  before { puts "i will be run once for each assert block in my scope" }
#  after  { puts "stackable" }

  assert do
#    before { puts "i am a callback" }
#    after  { puts "callbacks are also" }
    before { @qqq=9 }

    let number: 2,
        nothing: regexp.match('ffff'),
        bool:    true

    condition(:divides) {|n,d| n%d==0} # custom conditions

    condition_group(:even_multiple_of_five) do |n| # like "shared examples" in RSpec
      that { n.even? }
      divides(n) {5}
    end

    even_multiple_of_five 30
    that { number + @qqq == 11} # callbacks and assertions are evaluated in the same context
    that { number - 1 == 1 }
    that { string.upcase == 'HI THERE' } # string is still in scope
    that { nothing == nil }
  end

  assert do
    let lax:       self,
        open_file: fix(read: "data\nof\nimmediate\ninterest ") # built-in fixtures
    that { lax.respond_to?(:bool) == false }# bool is now out of scope
    that { open_file.read.lines.map(&:strip).size == 4 }
  end
end

