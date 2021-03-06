# encoding: utf-8
# Build description.
# basic build file for mruby
MRUBY_ROOT = File.dirname(File.expand_path(__FILE__))
MRUBY_BUILD_HOST_IS_CYGWIN = RUBY_PLATFORM.include?('cygwin')
MRUBY_BUILD_HOST_IS_OPENBSD = RUBY_PLATFORM.include?('openbsd')

# load build systems
load "#{MRUBY_ROOT}/tasks/ruby_ext.rake"
load "#{MRUBY_ROOT}/tasks/mruby_build.rake"
load "#{MRUBY_ROOT}/tasks/mrbgem_spec.rake"

# load configuration file
MRUBY_CONFIG = (ENV['MRUBY_CONFIG'] && ENV['MRUBY_CONFIG'] != '') ? ENV['MRUBY_CONFIG'] : "#{MRUBY_ROOT}/build_config.rb"
load MRUBY_CONFIG

# load basic rules
MRuby.each_target do |build|
  build.define_rules
end

# load custom rules
load "#{MRUBY_ROOT}/src/mruby_core.rake"
load "#{MRUBY_ROOT}/mrblib/mrblib.rake"

load "#{MRUBY_ROOT}/tasks/mrbgems.rake"
load "#{MRUBY_ROOT}/tasks/libmruby.rake"

load "#{MRUBY_ROOT}/tasks/mrbgems_test.rake"
load "#{MRUBY_ROOT}/test/mrbtest.rake"

load "#{MRUBY_ROOT}/tasks/benchmark.rake"

##############################
# generic build targets, rules
task :default => :all

BIN_PATH = "#{MRUBY_ROOT}/bin"
FileUtils.mkdir_p BIN_PATH, { :verbose => $verbose }

def depfiles(target)
  deps = MRuby.targets['host'].bins.map do |bin|
    install_path = MRuby.targets['host'].exefile("#{BIN_PATH}/#{bin}")
    source_path = MRuby.targets['host'].exefile("#{MRuby.targets['host'].build_dir}/bin/#{bin}")

    file install_path => source_path do |t|
      FileUtils.rm_f t.name, { :verbose => $verbose }
      FileUtils.cp t.prerequisites.first, t.name, { :verbose => $verbose }
    end

    install_path
  end

  target.instance_eval do
    gems.map do |gem|
      current_dir = gem.dir.relative_path_from(Dir.pwd)
      relative_from_root = gem.dir.relative_path_from(MRUBY_ROOT)
      current_build_dir = File.expand_path "#{build_dir}/#{relative_from_root}"

      if current_build_dir !~ /^#{build_dir}/
        current_build_dir = "#{build_dir}/mrbgems/#{gem.name}"
      end

      gem.bins.each do |bin|
        exec = exefile("#{build_dir}/bin/#{bin}")
        objs = Dir.glob("#{current_dir}/tools/#{bin}/*.{c,cpp,cxx,cc}").map { |f| objfile(f.pathmap("#{current_build_dir}/tools/#{bin}/%n")) }

        file exec => objs + [libfile("#{build_dir}/lib/libmruby")] do |t|
          gem_flags = gems.map { |g| g.linker.flags }
          gem_flags_before_libraries = gems.map { |g| g.linker.flags_before_libraries }
          gem_flags_after_libraries = gems.map { |g| g.linker.flags_after_libraries }
          gem_libraries = gems.map { |g| g.linker.libraries }
          gem_library_paths = gems.map { |g| g.linker.library_paths }
          linker.run t.name, t.prerequisites, gem_libraries, gem_library_paths, gem_flags, gem_flags_before_libraries, gem_flags_after_libraries
        end

        if target == MRuby.targets['host']
          install_path = MRuby.targets['host'].exefile("#{MRUBY_ROOT}/bin/#{bin}")

          file install_path => exec do |t|
            FileUtils.rm_f t.name, { :verbose => $verbose }
            FileUtils.cp t.prerequisites.first, t.name, { :verbose => $verbose }
          end
          deps += [ install_path ]
        elsif target == MRuby.targets['host-debug']
          unless MRuby.targets['host'].gems.map {|g| g.bins}.include?([bin])
            install_path = MRuby.targets['host-debug'].exefile("#{MRUBY_ROOT}/bin/#{bin}")

            file install_path => exec do |t|
              FileUtils.rm_f t.name, { :verbose => $verbose }
              FileUtils.cp t.prerequisites.first, t.name, { :verbose => $verbose }
            end
            deps += [ install_path ]
          end
        else
          deps += [ exec ]
        end
      end
    end
  end

  deps += [target.libfile("#{target.build_dir}/lib/libmruby")]

  if target.name != 'host'
    deps += target.bins.map { |bin| target.exefile("#{target.build_dir}/bin/#{bin}") }.flatten
  end

  deps
end

desc "build all targets, install (locally) in-repo"
task :all => MRuby.targets.values.inject([]) {|deps, target| deps + depfiles(target) }.uniq do
  puts
  puts "Build summary:"
  puts
  MRuby.each_target do
    print_build_summary
  end
end

MRuby.targets.each do |n, t|
  task n => depfiles(t) do
    puts "Build summary:"
    puts
    t.print_build_summary
  end
end

desc "run all mruby tests"
task :test => ["all"] + MRuby.targets.values.map { |t| t.build_mrbtest_lib_only? ? t.libfile("#{t.build_dir}/test/mrbtest") : t.exefile("#{t.build_dir}/test/mrbtest") } do
  MRuby.each_target do
    run_test unless build_mrbtest_lib_only?
  end
end

desc "clean all built and in-repo installed artifacts"
task :clean do
  MRuby.each_target do |t|
    FileUtils.rm_rf t.build_dir, { :verbose => $verbose }
  end
  FileUtils.rm_f depfiles, { :verbose => $verbose }
  puts "Cleaned up target build folder"
end

desc "clean everything!"
task :deep_clean => ["clean"] do
  MRuby.each_target do |t|
    FileUtils.rm_rf t.gem_clone_dir, { :verbose => $verbose }
  end
  puts "Cleaned up mrbgems build folder"
end

desc 'generate document'
task :doc do
  load "#{MRUBY_ROOT}/doc/language/generator.rb"
end
