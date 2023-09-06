require 'fileutils'

Dir['/usr/repo/plumbers.github.io/docs/**/*'].select do |f|
  f =~ /\d.md/
end.each do |f|
  FileUtils.rm_r(f, force: true)
end