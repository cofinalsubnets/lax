class TestCases
  def a_number
    rand(0..100)
  end
  def an_exception
    QWERTY.uiop[]
  end
end

Lax.test(TestCases.new) {|assert|
  assert.calling(:a_number).satisfies {|n| Fixnum===n}
  assert.calling(:an_exception).raises
}

