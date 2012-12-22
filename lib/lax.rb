Object::Lax = Class.new(Array)
Lax::SOURCE = File.new(f=File.expand_path('../lax/source.rb', __FILE__)).read
Object.class_eval Lax::SOURCE, f

