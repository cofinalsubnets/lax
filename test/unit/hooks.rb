Lax.test {
  _ s{Lax::Hook.new {1}} {
    its {call} == 1
    _ its {self + proc {2}} {
      kind_of? Lax::Hook
      its {call} == 2
    }
  }
  _ s {Lax::Hook.new {|n|2*n}}.c {call(2) == 4} {
    its {self}
    its {self << proc {2}}
    Lax.hook(:two) {2}
    its {self << :two}
  }
}

