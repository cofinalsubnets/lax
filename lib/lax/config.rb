module Lax
  CONFIG = {
    task: {
      dir: :test,
      finish: Hook.summary + Hook.failures,
      group: {
        after: Hook.pass_fail
      }
    }
  }
  module Config
    def recursive_merge(h1, h2)
      h1.merge(h2) do |k,o,n|
        Hash===o ? recursive_merge(o,n) :n
      end
    end
    def config(h=nil)
      h ? CONFIG.merge!(recursive_merge(CONFIG, h)) : CONFIG
    end
  end
end

