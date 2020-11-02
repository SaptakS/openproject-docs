#!/usr/bin/env ruby


require 'pathname'
require 'fileutils'
require 'parallel'
require 'psych' # required for .to_yaml

class APIBuilder
  def self.build
    new.build
  end

  def build
    Dir.chdir(File.join(middleman_root, 'api-builder')) do
      cleanup_prior_run
      create_target_dir
      copy_introduction
      build_v3
      build_bcf
    end
  end

  def cleanup_prior_run
    FileUtils.rm_rf target_dir
  end

  def create_target_dir
    FileUtils.mkdir_p target_dir
  end

  # Copy basic API v3 vs BCF introduction
  def copy_introduction
    FileUtils.copy(File.join(api_source_dir, 'README.md'), File.join(target_dir, "index.html.md"))
  end

  def build_v3
    copy_endpoints_index
    copy_example
    copy_clients

    Parallel.each(Dir.glob("#{apiv3_source_dir}/**/*.apib"), progress: 'Processing APIv3 entries') do |api_file|
      aglio_v3_file(api_file)
    end
  end

  def build_bcf
    bcf_source_dir = File.join(core_path.to_s, 'docs', 'api', 'bcf')
    bcf_target_dir = File.join(middleman_root, 'source', 'api', 'bcf-rest-api')
    FileUtils.mkdir_p bcf_target_dir

    Parallel.each(Dir.glob("#{bcf_source_dir}/**/*.md"), progress: 'Processing BCF entries') do |api_file|
      filepath = Pathname.new(api_file)
      target_path = File.join(bcf_target_dir, "index.html.md")
      relative_file = filepath.relative_path_from(core_path)

      headers = frontmatter_header(:bcf_api, relative_file)
      frontmattered_file_copy(headers, api_file, target_path)
    end
  end

  def copy_endpoints_index
    # Copy endpoints index file
    FileUtils.mkdir_p endpoints_target_dir
    endpoints_index_path = File.join(endpoints_target_dir, "index.html.md")
    endpoints_source_path = File.join(apiv3_source_dir, 'endpoints', 'README.md')
    FileUtils.copy(endpoints_source_path, endpoints_index_path)
    frontmattered_file_copy(frontmatter_header(:endpoints, endpoints_source_path,  { title: 'Endpoints' }), endpoints_index_path)
  end

  def copy_example
    FileUtils.mkdir_p example_target_dir

    Dir.glob("#{example_source_dir}/*.png").each do |api_file|
      FileUtils.copy(api_file, example_target_dir)
    end

    example_index_source_path = File.join(example_source_dir, 'README.md')
    example_index_target_path = File.join(example_target_dir, 'index.html.md')
    frontmattered_file_copy(frontmatter_header(:example, example_index_source_path, { title: 'Example' }),
                            example_index_source_path,
                            example_index_target_path)
  end

  def copy_clients
    FileUtils.mkdir_p clients_target_dir

    Dir.glob("#{clients_source_dir}/*.png").each do |api_file|
      FileUtils.copy(api_file, clients_target_dir)
    end

    clients_index_source_path = File.join(clients_source_dir, 'README.md')
    clients_index_target_path = File.join(clients_target_dir, 'index.html.md')
    frontmattered_file_copy(frontmatter_header(:'clients-libraries', clients_index_source_path, { title: 'Client libraries' }),
                            clients_index_source_path,
                            clients_index_target_path)

  end

  def aglio_v3_file(api_file)
    filepath = Pathname.new(api_file)
    relative_file = filepath.relative_path_from(core_path)
    filename = filepath.basename('.apib').to_s
    dirname = filepath.each_filename.to_a[-2]

    # Ignore the index file
    return if filename == 'index'

    target_path = if dirname == 'endpoints'
                    File.join(target_dir, 'endpoints', "#{filename}.html.erb")
                  else
                    FileUtils.mkdir_p File.join(target_dir, filename)
                    File.join(target_dir, filename, "index.html.erb")
                  end

    # Execute aglio on that file
    `NOCACHE=1 #{aglio_path} -t openproject-docs-single-page.jade -i #{api_file} -o #{target_path}`

    headers = frontmatter_header(filename, relative_file, filename == 'introduction' ? { title: 'Introduction' }: {})

    frontmattered_file_copy(headers, target_path)
  end

  # Define the specific title of the introduction page
  # and determine the order the pages are to be listed in.
  # Place everything before the bcf api page.
  def frontmatter_header(filename, relative_file, additions = {})
    { source_path: relative_file, sidebar_navigation: { priority: api_priority(filename) } }.merge(additions)
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
  def frontmattered_file_copy(headers, source_path, target_path = source_path)
    input = File.read source_path

    File.open(target_path, 'w') do |f|
      f.puts frontmatter_string(headers)
      f.puts input
    end
  end

  # The order the explicitly ordered api entries are to be sorted in.
  # The higher the number, the higher up the element is ordered. A higher element comes before a lower element.
  def api_priority(key)
    order = %i(introduction
               example
               basic-objects
               group-objects
               forms
               filters
               endpoints
               default
               clients-libraries
               bcf_api)

    order.length - (order.index(key.to_sym) || order.index(:default))
  end

  def core_path
    Pathname.new ENV['OPENPROJECT_CORE']
  end

  def api_source_dir
    File.join(core_path.to_s, 'docs', 'api')
  end

  def endpoints_target_dir
    File.join(middleman_root, 'source', 'api', 'endpoints')
  end

  def example_target_dir
    File.join(target_dir.to_s, 'example')
  end

  def example_source_dir
    File.join(apiv3_source_dir, 'example')
  end

  def clients_target_dir
    File.join(target_dir.to_s, 'client-libraries')
  end

  def clients_source_dir
    File.join(apiv3_source_dir, 'client-libraries')
  end

  def apiv3_source_dir
    File.join(core_path.to_s, 'docs', 'api', 'apiv3')
  end

  def target_dir
    File.join(middleman_root, 'source', 'api')
  end

  def aglio_path
    File.join(middleman_root, 'node_modules', '.bin', 'aglio')
  end
end

def rename_md_file(path)
  renamed = path.gsub(/\.md$/, '.html.md')

  if renamed.end_with? 'README.html.md'
    renamed.gsub! 'README.html.md', 'index.html.md'
  end

  FileUtils.mv path, renamed
end

def middleman_root
  File.expand_path('../../', __dir__)
end

desc 'Build and publish to Github Pages'
task :build do
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
  APIBuilder.build
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
