require 'rubygems'
require 'hoe'
require 'fileutils'

local_dir = File.dirname(__FILE__)
lib_dir = "#{local_dir}/lib"
$: << lib_dir unless $:.include?(lib_dir)

require 'flyingsaucer/version.rb'

DEPENDENT_JARS = [ 'itext-2_0_8_02.jar' ]

STATIC_JAR_DIR = ENV['STATIC_JAR_DIR'] || "../StaticJars"

Hoe.new('flyingsaucer', FlyingSaucer::VERSION) do |p|
  p.developer('CCAP Web Team', 'CCAP_Web_Team@wicourts.gov')
end

desc "Copies dependent JARs from StaticJars"
task :cp_dependent_jars do
  rm_f 'lib/*.jar'
  DEPENDENT_JARS.each do |jar|
    cp "#{STATIC_JAR_DIR}/#{jar}", 'lib'
  end
end

desc "Updates Flying Saucer JAR with the latest drop from StaticJars"
task :update_fs_jar => :cp_dependent_jars do
  latest = Dir.glob("#{STATIC_JAR_DIR}/xhtmlrenderer*.jar").sort[-1]
  cp latest, 'lib'
end
