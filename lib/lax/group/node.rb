module Lax
  class Group
    class Node < Array
      %w{== === != =~ > < >= <=}.each do |m|
        define_method(m) {|o|c{|r|r.__send__ m,o}}
      end

      def initialize(subj=proc{}, cond=proc{|e|e})
        @subj, @cond = subj, cond
      end

      def _(n,&b); n.instance_exec(&b)                        end
      def s(&b); push(Node.new Proc.new(&b), @cond     ).last end
      def c(&b); push(Node.new @subj, preproc(b)       ).last end
      def x(e=StandardError); push(Node.new @subj, e   ).last end

      def it(t=nil, &b); b ? c(&b) : self                     end
      def its(&b); s { @subj.call.instance_exec &b }          end
      def on(*subs, &b); b ? s(&b) : subs.each {|sub| s{sub}} end
      def eq(o=nil,&b); self == (b ? b.call : o)              end

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

