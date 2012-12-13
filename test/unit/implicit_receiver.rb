Lax.test {
  on(2) { calling(:+) { with(3) { satisfies {odd?} } } }
  on(2).calling(:+).with(3).satisfies &:odd?
}

