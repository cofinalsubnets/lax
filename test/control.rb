Lax.scope do
  let number: 1,
      string: 'asdf',
      symbol: :a_sym,
      regexp: lazy{/asd/}

  scope do
    assert { that number == 1 }
    scope do
      let number: 2
      assert do
        that number == 2,
             number.even?,
             string.upcase.downcase == 'asdf',
             string =~ regexp
      end
    end
  end
end

Lax.scope do
  let number: 1,
      string: 'Hi There',
      regexp: lazy{ /the/ } # lazy evaluation

  string {upcase == 'HI THERE'}

  assert do
    that number + 1 == 2,
      string.downcase =~ regexp
  end

#  before { puts "i will be run once for each assert block in my scope" }
#  after  { puts "are stackable" }

  scope do

    def self.number_is_even
      number { even? }
    end

    let number: 2,
        nothing: regexp.match('ffff'),
        bool:    true
    before { @qqq=9}

    number_is_even

    assert 'documented tests' do
      that number + @qqq == 11,
        number - 1 == 1,
        string.upcase == 'HI THERE', # string is in scope
        nothing == nil
   end
  end

  scope do
    let lax: self,
        open_file: fix(read: "data\nof\nimmediate\ninterest ") # fixtures
   assert do
     that lax.respond_to?(:bool) == false # bool is out of scope
     that open_file.read.lines.map(&:strip).size == 4
    end
  end
end

Lax.scope do
  let lax: Lax
  assert do
    group = lax.scope do
      let altitude: 10000
      assert { that altitude > 1000 }
    end.lings.first.new
    that group.size==1
  end
end

