require 'lax/version'
module Lax
  autoload :Group, 'lax/group'
  autoload :Task,  'lax/task'
  autoload :Case,  'lax/case'
  autoload :Hook,  'lax/hook'

  class << self; attr_accessor :groups end
  self.groups = []

  def self.test(&b)
    Class.new(Group).send(:define_method, :tests, &b)
  end

  def self.test!(cases, opts={})
    call opts[:start], cases
    cases.each do |c|
      call opts[:before], c
      call opts[:after],  c.tap(&:test)
    end.tap {|cs|call opts[:finish], cs}
  end

  def self.test_all(opts={})
    test! groups.map(&:new).map {|g| g.tests;g.leaves}.flatten, {
      start:  Hook::StartTime,
      after:  Hook::PassFail,
      finish: Hook::StopTime + Hook::Summary + Hook::Failures
    }.merge(opts)
  end

  private
  def self.call(p, *as)
    p[*as] if p
  end
end

