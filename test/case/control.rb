 Lax.test {
  # a test is a subject and a condition
  s{1}.c{odd?}

  # s and c are aliases
  s{2}.c{even?}

  # there are a couple of condition helpers
  s{1**7} == 1
  s{'no'} =~ /no+/

  # the subject is the implicit condition
  s{'asdf'.is_a? String}

  # subjects and conditions can be passed into blocks using `_'
  _ c{even?} { on {2} }

  # and this is where things get fancy
  _ s{'AsDf'.downcase} {
    it == 'asdf'
    it != 'qsdf'

    it {is_a? String}

    its {size}   == 4
    its {upcase} == 'ASDF'

    _ its {upcase} {
      its {size} == 4
      it == 'ASDF'
    }
  }
  _ eq{1} {
    s {1+0}
  }

  c{is_a? Fixnum}.on *(1..5)

  _ s{1/0} {
    x ZeroDivisionError
  }
}

