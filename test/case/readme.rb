Lax.test {
  s{999} < 1000

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
