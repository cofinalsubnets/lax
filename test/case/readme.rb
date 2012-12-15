class MyTests < Lax::Group
  def tests
    let subject {'asdf'} do
      it {is_a? String}
      it satisfies {|s| s.size == 4}
    end
  end
end

Lax.test {
  s {999} < 1000

  _ s{1/0} {
    x StandardError
    x ZeroDivisionError
  }

  _ s{'test'} {
    it =~ /t/
    its {size} == 4

    _ its {upcase} {
      c{size == 4}
      it == 'TEST'
    }
  }
}
