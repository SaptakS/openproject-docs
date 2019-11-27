#!/usr/bin/env ruby


require 'pathname'
require 'fileutils'
require 'pry'
require 'parallel'

desc 'Build and publish to Github Pages'
task :build do
  middleman_root = File.expand_path('../../', __dir__)

  core_docs = ENV['OPENPROJECT_CORE']
  raise 'Missing OPENPROJECT_CORE env' unless core_docs

  doc_folder = ENV['OPENPROJECT_DOC_ROOT'] || 'help'
  doc_root = File.join(core_docs, doc_folder)

  commit = Dir.chdir(core_docs) do
    `git rev-parse HEAD`.strip
  end

  puts "Building from core@#{commit}"

  localizable_path = File.expand_path('source/localizable', middleman_root)

  Pathname.new(doc_root).children.each do |path|
    name = File.basename(path)
    next unless path.directory?

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
    core_path = Pathname.new ENV['OPENPROJECT_CORE']
    source_dir = File.join(core_path.to_s, 'docs', 'api', 'apiv3')
    target_dir = File.join(middleman_root, 'source', 'api')
    aglio_path = File.join(middleman_root, 'node_modules', '.bin', 'aglio')

    FileUtils.rm_rf target_dir
    FileUtils.mkdir_p target_dir

    entries = Dir.glob("#{source_dir}/**/*.apib")

    Parallel.each(entries, progress: 'Processing API entries') do |api_file|
      filepath = Pathname.new(api_file)
      relative_file = filepath.relative_path_from(core_path)
      filename = filepath.basename('.apib').to_s

      # Ignore the index file
      next if filename == 'index'

      # Make introduction the new index
      filename = 'index' if filename == 'introduction'

      # Create a filename under API
      target_path = File.join(target_dir, "#{filename}.html.erb")

      # Execute aglio on that file
      `NOCACHE=1 #{aglio_path} -t openproject-docs-single-page.jade -i #{api_file} -o #{target_path}`

      # Add the frontmatter
      input = File.read target_path

      File.open(target_path, 'w') do |f|
        f.puts <<~FRONTMATTER
          ---
          source_path: #{relative_file}
          ---
        FRONTMATTER
        f.puts input
      end
    end
  end

  puts 'Done. Updating build data'

  buildinfo = {
    commit: commit,
    url: "https://github.com/opf/openproject/commit/#{commit}",
    timestamp: Time.now
  }

  File.open(File.join(middleman_root, 'data', 'buildinfo.yml'), 'w') do |file|
    file.write(buildinfo.to_yaml)
  end
end
