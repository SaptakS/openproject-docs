#!/usr/bin/env ruby


require 'pathname'
require 'fileutils'
require 'pry'

middleman_root = File.expand_path('../', __dir__)

core_docs = ENV['OPENPROJECT_CORE']
raise 'Missing OPENPROJECT_CORE env' unless core_docs

doc_folder = ENV['OPENPROJECT_DOC_ROOT'] || 'help'
doc_root = File.join(core_docs, doc_folder)

localizable_path = File.expand_path('../source/localizable', __dir__)

Dir.children(doc_root).each do |name|
  path = File.join(doc_root, name)
  next unless File.directory?(path)

  puts "Removing previous folder #{name} and copying from #{path} again."
  FileUtils.rm_rf(File.join(localizable_path, name))

  FileUtils.cp_r path, localizable_path
end

puts 'Renaming index files to match directory index'
Dir.glob("#{localizable_path}/**/*.md").each do |path|
  target = path.gsub(/\.md$/, '.html.md')

  if target.end_with? 'README.html.md'
    target.gsub! 'README.html.md', 'index.html.md'
  end

  FileUtils.mv path, target
end

puts 'Building API docs'
Dir.chdir(File.join(middleman_root, 'api-builder')) do
  path = File.join(ENV['OPENPROJECT_CORE'], 'docs', 'api', 'apiv3', 'index.apib')
  target_path = File.join(middleman_root, 'source', 'api.html.erb')
  aglio_path = File.join(middleman_root, 'node_modules', '.bin', 'aglio')

  FileUtils.rm target_path, force: true

  # Execute
  `NOCACHE=1 #{aglio_path} -t openproject-docs-layout.jade -i #{path} -o #{target_path}`

  # Prepend layout
  api = File.read(target_path)

  File.open(target_path, 'w') do |f|
    f.write <<~HEADER
      ---
      layout: api
      ---

    HEADER

    f.write api
  end
end
