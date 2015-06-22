MRuby::Toolchain.new(:clang_x64_darwin14) do |conf|
  toolchain :clang

  [conf.cc, conf.objc, conf.asm].each do |cc|
    cc.command = ENV['CC'] || 'x86_64-apple-darwin14-clang'
  end
  conf.cxx.command      = ENV['CXX'] || 'x86_64-apple-darwin14-clang++'
  conf.linker.command   = ENV['LD'] || 'x86_64-apple-darwin14-clang'
  conf.archiver.command = ENV['AR'] || 'x86_64-apple-darwin14-ar'
end

