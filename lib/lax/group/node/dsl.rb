module Lax
  class Group
    class Node
      module DSL
        def self.define_matcher(sym, &p)
          define_method(sym) do |*a,&b|
            p ? c{|o|p[*a,&b][o]} : c{|o|o.__send__ sym,*a,&b}
          end
        end

        %w{== === != =~ > < >= <= is_a? kind_of? include?}.each {|m| define_matcher m}

        def it
          self
        end

        # Open a new lexical scope. The supplied argument will apply to all tests
        # specified in the new scope unless overridden.
        def let(n,&b)
          n.instance_eval &b
        end

        # Specify the value of the supplied block as the test subject.
        def subject(&b)
          append_node subject: Hook.new(&b)
        end

        # Specify the value of the supplied block, called with the subject, as
        # the current condition. If the block has no parameters, then the subject
        # will be the implicit receiver when the condition is evaluated.
        def condition(&b)
          append_node condition: autoproc(b||spec[:condition])
        end

        # Specify an expectation that an exception of type e is raised by the
        # subject.
        def raises(e=StandardError)
          append_node condition: e
        end

        # Specify hooks. Takes a hash of hooks and merges them (via Hook::+) with
        # the current hooks.
        def hook(hs)
          append_node hooks: spec[:hooks].merge(hs) {|k,o,n| o+n}
        end

        def compose(node, &b)
          node.spec.merge!(spec) do |key,new,cur|
            if new.equal? cur
              cur
            else
              case key
              when :subject
                autoproc(new) << cur
              when :condition
                Hook===cur and Proc===new ? cur & new : new
              when :hooks
                cur.merge new
              else
                new
              end
            end
          end
          let node, &b
        end

        # Specifies a compound subject. The new subject is the return value of the
        # supplied block called with the current subject; as with #condition, if 
        # the supplied block has no parameters, it is evaluated in the context of
        # the subject.
        def its(&b)
          compose(subject(&b)) {it}
        end

        alias _ let
        alias x raises
        alias s subject
        alias c condition
        alias h hook
        alias comp compose

        private
        def autoproc(b)
          b.parameters.any?? b : Hook.new {|e|e.instance_exec &b}
        end
      end
    end
  end
end

