#!/usr/bin/env ruby


require 'pathname'
require 'fileutils'

core_docs = '/home/oliver/openproject/dev/docs'
localizable_path = File.expand_path('../source/localizable', __dir__)
openproject_source_dir = File.join(localizable_path, 'openproject')

if File.directory?(openproject_source_dir)
  puts "Removing previous folder #{openproject_source_dir}"
  FileUtils.rm_rf(openproject_source_dir)
end

puts "Copying core to #{openproject_source_dir}"
FileUtils.copy_entry core_docs, openproject_source_dir

puts "Renaming index files to match directory index"
Dir.glob("#{openproject_source_dir}/**/README.md").each do |path|
  FileUtils.mv path, path.gsub('README.md', 'index.html.md')
end