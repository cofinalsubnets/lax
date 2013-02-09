number = 1
string = 'asdf'
symbol = :a_sym
regexp = /asd/

test number == 1
test number, :odd?, equals(1), abs: 1


number = -2
test number, :even?, abs: 2


test string =~ regexp
test string, upcase: 'ASDF'

sum_to = ->(n) { returns n, :reduce, :+, nil } # returns is a built-in matcher
test [10, 5, 0], sum_to[15]                    # pass

