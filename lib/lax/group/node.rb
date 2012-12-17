module Lax
  class Group
    class Node < Array
      def self.define_matcher(sym, &p)
        define_method(sym) do |*a,&b|
          p ? c{|o|p[*a,&b][o]} : c{|o|o.__send__ sym,*a,&b}
        end
      end

      %w{== === != =~ > < >= <= is_a? kind_of?}.each {|m| define_matcher m }

      def initialize(subj=nil, cond=Hook.id)
        @subj, @cond = subj, cond
      end

      def _(n,&b)
        n.instance_exec(&b) 
      end

      def s(&b)
        push(Node.new Hook.new(&b), @cond).last
      end

      def c(&b)
        push(Node.new @subj, preproc(b)).last
      end

      def x(e=StandardError)
        push(Node.new @subj, e).last
      end

      def it
        self
      end

      def its(&b)
        s &Hook._compose(preproc(b),@subj)
      end

      alias let       _
      alias raises    x
      alias subject   s
      alias condition c

      def cases
        any?? map(&:cases).flatten : [Case.new(@subj,@cond)]
      end

      private
      def preproc(b)
        b.parameters.any?? b : ->(e) {e.instance_exec &b}
      end
    end
  end
end
