class Lax
  class Configuration
    def initialize(&conf)
      @conf = conf
    end

    def apply(lax=Lax.instance)
      @lax = lax
      @conf.call self
      remove_instance_variable :@lax
    end

    %w(condition macro before after let).each do |m|
      define_method(m) do |*as,&blk|
        @lax.context.send m, *as, &blk
      end
    end

    %w(after= before= start= finish= threads=).each do |m|
      define_method(m) do |*as,&blk|
        @lax.runner.send m, *as, &blk
      end
    end

    %w(load run context runner assertions).each do |m|
      define_method(m) do |*as,&blk|
        @lax.send m, *as, &blk
      end
    end

    BASIC_OUTPUT = new do |c|
      c.after  = Output.method :dots
      c.finish = Output.method :summarize
    end

  end
end

