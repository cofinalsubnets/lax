 Lax.test {
  # a test is a subject and a condition
  subject {1}.condition {odd?}

  # s and c are aliases
  s{2}.c{even?}

  # there are a couple of condition helpers
  subject {1**7} == 1
  subject {'no'} =~ /no+/

  # the subject is the implicit condition
  subject {'asdf'.is_a? String}

  # subjects and conditions can be passed into blocks using `_'
  _ c{even?} { on {2} }

  # and this is where things get fancy
  _ subject {'AsDf'.downcase} {
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
  _ equals {1} {
    s {1+0}
  }

  c{is_a? Fixnum}.on *(1..5)

  _ subject {1/0} {
    x ZeroDivisionError
  }
}

