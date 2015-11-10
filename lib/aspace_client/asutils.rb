require 'json'
require 'tmpdir'
require 'tempfile'

module ASUtils

  def self.keys_as_strings(hash)
    result = {}

    hash.each do |key, value|
      result[key.to_s] = value.is_a?(Date) ? value.to_s : value 
    end

    result
  end


  def self.as_array(thing)
    return [] if thing.nil?
    thing.kind_of?(Array) ? thing : [thing]
  end


  def self.jsonmodels_to_hashes(elt)

    if elt.is_a?(JSONModelType)
      elt = elt.to_hash(:raw)
    end

    if elt.is_a?(Hash)
      Hash[elt.map {|k, v| [k, self.jsonmodels_to_hashes(v)]}]
    elsif elt.is_a?(Array)
      elt.map {|v| self.jsonmodels_to_hashes(v)}
    else
      elt
    end
  end


  def self.json_parse(s)
    JSON.parse(s, :max_nesting => false, :create_additions => false)
  end



  def self.to_json(obj, opts = {})
    if obj.respond_to?(:jsonize)
      obj.jsonize(opts.merge(:max_nesting => false))
    else
      obj.to_json(opts.merge(:max_nesting => false))
    end
  end


  def self.find_base_directory(root = nil)
    [ File.join(*[File.dirname(__FILE__), "..", root].compact)].find {|dir|
      Dir.exists?(dir)
    }
  end


  def self.find_local_directories(base = nil, *plugins)
    base_directory = self.find_base_directory
    Array(plugins).map { |plugin| File.join(*[base_directory, "plugins", plugin, base].compact) }
  end


  def self.find_locales_directories(base = nil)
    [File.join(*[self.find_base_directory("common"), "locales", base].compact)]
  end


  def self.extract_nested_strings(coll)
    if coll.is_a?(Hash)
      coll.values.map {|v| self.extract_nested_strings(v)}.flatten.compact
    elsif coll.is_a?(Array)
      coll.map {|v| self.extract_nested_strings(v)}.flatten.compact
    else
      coll
    end
  end

  def self.dump_diagnostics(exception = nil)
    diagnostics = self.get_diagnostics( exception ) 
    tmp = File.join(Dir.tmpdir, "aspaue_diagnostic_#{Time.now.to_i}.txt")
    File.open(tmp, "w") do |fh|
      fh.write(JSON.pretty_generate(diagnostics))
    end

    msg = <<EOF
A trace file has been written to the following location: #{tmp}

This file contains information that will assist developers in diagnosing
problems with your ArchivesSpace installation.  Please review the file's
contents for sensitive information (such as passwords) that you might not
want to share.
EOF

    $stderr.puts("=" * 72)
    $stderr.puts(msg)
    $stderr.puts("=" * 72)

    raise exception if exception
  end


  # Recursively overlays hash2 onto hash 1
  def self.deep_merge(hash1, hash2)
    target = hash1.dup
    hash2.keys.each do |key|
      if hash2[key].is_a? Hash and hash1[key].is_a? Hash
        target[key] = self.deep_merge(target[key], hash2[key])
        next
      end
      target[key] = hash2[key]
    end
    target
  end


  def self.load_plugin_gems(context)
    ASUtils.find_local_directories.each do |plugin|
      gemfile = File.join(plugin, 'Gemfile')
      if File.exists?(gemfile)
        context.instance_eval(File.read(gemfile))
      end
    end
  end


  # Borrowed from: file activesupport/lib/active_support/core_ext/array/wrap.rb, line 36
  def self.wrap(object)
    if object.nil?
      []
    elsif object.respond_to?(:to_ary)
      object.to_ary || [object]
    else
      [object]
    end
  end

end
