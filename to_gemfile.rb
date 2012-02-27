#!/usr/bin/env ruby
#Save in file to_gemfile.rb
gem_file = File.open("Gemfile", "w")
gem_file.write("source :rubygems\n")
  STDIN.readlines.each do |line|
    line = line.chomp
    line =~ /(.*)\s\((.*)\)/
    gem_name = $1
    versions = $2.split(",")
    gem_file.write("gem \"#{gem_name}\", \"#{versions.first}\"\n")
  end
gem_file.close
