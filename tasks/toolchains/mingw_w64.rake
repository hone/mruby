MRuby::Toolchain.new(:mingw_w64) do |conf|
  toolchain :gcc

  [conf.cc, conf.objc, conf.asm, conf.linker].each do |cc|
    cc.command = ENV['CC'] || 'x86_64-w64-mingw32-gcc'
  end
  conf.cxx.command      = ENV['CXX'] || 'x86_64-w64-mingw32-cpp'
  conf.linker.command   = ENV['LD'] || 'x86_64-w64-mingw32-gcc'
  conf.archiver.command = ENV['AR'] || 'x86_64-w64-mingw32-gcc-ar'
  conf.exts.executable  = ".exe"
end

