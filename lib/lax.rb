Object::Lax = Class.new(Array)
Lax::SOURCE = File.new(File.expand_path('../lax/source.rb', __FILE__)).read
Object.class_eval Lax::SOURCE

