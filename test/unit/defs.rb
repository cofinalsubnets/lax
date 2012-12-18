Lax.hook(:pug_bomb) {|n| Array.new n, 'pug'}
Lax.matcher(:divides) {|n| proc {|o| n%o==0}}
Lax.test {
  let subject {Lax::Hook.pug_bomb[5]} do
    it == Array.new(5, 'pug')
  end
  let subject {5} do
    it.divides 25
  end
}

