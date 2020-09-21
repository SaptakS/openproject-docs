#!/usr/bin/env ruby


require 'pathname'
require 'fileutils'
require 'parallel'
require 'psych' # required for .to_yaml

def rename_md_file(path)
  renamed = path.gsub(/\.md$/, '.html.md')

  if renamed.end_with? 'README.html.md'
    renamed.gsub! 'README.html.md', 'index.html.md'
  end

  FileUtils.mv path, renamed
end

def frontmatter_string(headers)
  header_string = headers.map do |key, value|
    if value.is_a?(Hash)
      "#{key}:\n" + value.map { |k, v| "    #{k}: #{v}" }.join("\n")
    else
      "#{key}: #{value}"
    end
  end.join("\n")

  <<~FRONTMATTER
      ---
      #{header_string}
      ---
  FRONTMATTER
end

# Copies the file from target to source and prepends the frontmatter style headers to it.
def frontmattered_file_copy(headers, target_path, source_path)
  input = File.read source_path

  File.open(target_path, 'w') do |f|
    f.puts frontmatter_string(headers)
    f.puts input
  end
end

desc 'Build and publish to Github Pages'
task :build do
  middleman_root = File.expand_path('../../', __dir__)

  core_docs = ENV['OPENPROJECT_CORE']
  raise 'Missing OPENPROJECT_CORE env' unless core_docs

  doc_folder = ENV['OPENPROJECT_DOC_ROOT'] || 'docs'
  doc_root = File.join(core_docs, doc_folder)

  no_git = `which git`.empty?
  commit = nil
  branch = nil

  unless no_git
    commit = ENV['CORE_REV'] || Dir.chdir(core_docs) { `git rev-parse HEAD`.strip rescue "" }
    branch = ENV['CORE_BRANCH'] || Dir.chdir(core_docs) { `git rev-parse --abbrev-ref HEAD`.strip rescue "" }
    branch = nil if branch.empty?
    commit = nil if commit.empty?
  end

  puts "Building from core@#{commit || core_docs}"

  localizable_path = File.expand_path('source/localizable', middleman_root)

  %w[
    cloud-edition-guide
    development
    enterprise-edition-guide
    getting-started
    installation-and-operations
    release-notes
    system-admin-guide
    user-guide
  ].each do |name|
    path = File.join(doc_root, name)
    next unless File.directory?(path)

    puts "Removing previous folder #{name} and copying from #{path} again."
    FileUtils.rm_rf(File.join(localizable_path, name))

    FileUtils.cp_r path, localizable_path
  end

  puts 'Renaming index files to match directory index'
  Dir.glob("#{localizable_path}/**/*.md").each do |path|
    rename_md_file(path)
  end

  puts 'Building API docs'
  Dir.chdir(File.join(middleman_root, 'api-builder')) do
    core_path = Pathname.new ENV['OPENPROJECT_CORE']
    api_source_dir = File.join(core_path.to_s, 'docs', 'api')
    apiv3_source_dir = File.join(core_path.to_s, 'docs', 'api', 'apiv3')
    bcf_source_dir = File.join(core_path.to_s, 'docs', 'api', 'bcf')
    target_dir = File.join(middleman_root, 'source', 'api')
    v3_target_dir = File.join(middleman_root, 'source', 'api', 'general-rest-api-v3')
    bcf_target_dir = File.join(middleman_root, 'source', 'api', 'bcf-rest-api')
    aglio_path = File.join(middleman_root, 'node_modules', '.bin', 'aglio')

    FileUtils.rm_rf target_dir
    FileUtils.mkdir_p target_dir
    FileUtils.mkdir_p v3_target_dir
    FileUtils.mkdir_p bcf_target_dir

    FileUtils.copy File.join(api_source_dir, 'README.md'), File.join(target_dir, "index.html.md")

    Parallel.each(Dir.glob("#{apiv3_source_dir}/**/*.apib"), progress: 'Processing APIv3 entries') do |api_file|
      filepath = Pathname.new(api_file)
      relative_file = filepath.relative_path_from(core_path)
      filename = filepath.basename('.apib').to_s

      # Ignore the index file
      next if filename == 'index'

      # Make introduction the new index
      filename = 'index' if filename == 'introduction'

      # Create a filename under API
      target_path = File.join(v3_target_dir, "#{filename}.html.erb")

      # Execute aglio on that file
      `NOCACHE=1 #{aglio_path} -t openproject-docs-single-page.jade -i #{api_file} -o #{target_path}`

      headers = { source_path: relative_file }

      # Define the specific title of the introduction page
      # and place it before the bcf api
      case filename
      when 'index'
        headers['title'] = 'General purpose REST API v3'
        headers['sidebar_navigation'] = { priority: 1000 }
      when 'basic-objects'
        headers['sidebar_navigation'] = { priority: 900 }
      when 'group-objects'
        headers['sidebar_navigation'] = { priority: 800 }
      when 'forms'
        headers['sidebar_navigation'] = { priority: 700 }
      end

      frontmattered_file_copy(headers, target_path, target_path)
    end

    Parallel.each(Dir.glob("#{bcf_source_dir}/**/*.md"), progress: 'Processing BCF entries') do |api_file|
      filepath = Pathname.new(api_file)
      target_path = File.join(bcf_target_dir, "index.html.md")
      relative_file = filepath.relative_path_from(core_path)

      headers = { source_path: relative_file, sidebar_navigation: { priority: 500 } }

      frontmattered_file_copy(headers, target_path, api_file)
    end
  end

  puts 'Done.'

  if no_git
    puts "Not changing build data (no git)"
  else
    puts "Updating build data"

    buildinfo = {
      commit: commit,
      branch: branch,
      url: "https://github.com/opf/openproject/commit/#{commit}",
      timestamp: Time.now
    }

    File.open(File.join(middleman_root, 'data', 'buildinfo.yml'), 'w') do |file|
      file.write(buildinfo.to_yaml)
    end
  end
end
