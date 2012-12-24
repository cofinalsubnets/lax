class Lax
  class Target < BasicObject
    def self.define_matcher(sym, &p)
      define_method(sym) do |*a,&b|
        p ? 
          satisfies(sym) {|o| p[*rslv(a),&b][o] } :
          satisfies(sym,*a) {|o| o.__send__ sym,*rslv(a),&b }
      end
    end

    def self.define_predicate(sym)
      define_method(sym.to_s.match(/^(.*)(\?|_?p)$/)[1]) do |*a,&b|
        satisfies($1) {|o| o.__send__ sym,*rslv(a),&b}
      end
    end

    %w{== === != =~ !~ < > <= >=}.each {|m| define_matcher m}
    %w{odd? even? is_a? kind_of? include?}.each {|m| define_predicate m}

    def initialize(node, subj, name, src)
      @node, @subj, @name, @src, @chain = node, subj, name, src, []
    end

    def satisfies(matcher=:satisfies, *args, &cond)
      @node << ::Lax::Assertion.new(@name, @subj, cond, @src, @chain, matcher, rslv(args), @node.class.doc)
    end

    def method_missing(sym, *args, &blk)
      @chain << [sym, rslv(args), blk]
      self
    end

    def __val__
      @subj.call
    end

    private
    def rslv(vs)
      vs.map {|v| ::Lax::Target === v ? v.__val__ : v}
    end
  end
end

