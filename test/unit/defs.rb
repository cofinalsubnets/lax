Lax.hook(:pug_bomb) {|n| Array.new n, 'pug'}
Lax.matcher(:factor) {|n| proc {|o| n%o==0}}
Lax.test {
  s{Lax::Hook.pug_bomb[5]} == Array.new(5, 'pug')
  s{5}.factor 25
}

