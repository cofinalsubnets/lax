Lax.test {
  _ s{Lax::Hook.new {1}} {
    its {call} == 1
    _ its {self + proc {2}} {
      kind_of? Lax::Hook
      its {call} == 2
    }
  }
  let subject {Lax::Hook.new {|n|2*n}} do
    let condition {call(2) == 4} do
      its {self << proc {2}}
      Lax.hook(:two) {2}
      its {self << :two}
    end
  end
}

