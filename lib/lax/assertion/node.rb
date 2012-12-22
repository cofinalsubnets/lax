module Lax
  class Assertion
    class Node
      include Tree
      attr_reader :parent, :children

      def initialize(parent=nil)
        @parent   = parent
        @children = self.class.children.map {|c| c.new(self)}
      end

      def assertions
        self.class.assertions.map {|a| send a}
      end

      def self.inherited(child)
        const_set("#{self==Node ? 'Root' : 'Node'}_#{self.children.size}", child) unless self == Node
        @children << child
        child.parent     = self
        child.children   = []
        child.assertions = []
        child.hooks      = self.hooks.dup
        defs.each do |ivar|
          child.instance_variable_set ivar, eval("#{ivar}")
        end
      end

      def self.let(h)
        h.each do |key, value|
          instance_variable_set "@#{key}", value
        end
        self
      end

      def self.fix(hash)
        Fixture.new hash
      end

      def self.cattr_assertable(name, src=nil)
        define_singleton_method(name) do
          Lax::Assertion::Subject.new self, proc{eval("@#{name}")}, name, src
        end
      end

      def self.assert(*vals, &b)
        Class.new(self).tap {|c| c.class_eval &b }
      end

      def self.method_missing(name, *args, &blk)
        if instance_variables.include?("@#{name}".to_sym)
          cattr_assertable name
          send name, *args, &blk
        else
          super
        end
      end

      def self.defs
        instance_variables - special_ivars
      end

      def self.special_ivars
        [ :@children, :@hooks, :@assertions, :@parent ]
      end

      private
      class << self
        attr_accessor :children, :hooks, :assertions, :parent
      end

      self.assertions = []
      self.children   = []
      self.hooks      = Lax.config.assertion.hooks.dup
    end
  end
end

