require 'json'
require 'active_support/core_ext/string'
require_relative 'scripts/nlp'
require_relative 'base'

NEW_LINE = "
";
HOST_NAME = "https://127.0.0.1:4002";

def grani
  f=File.open("./docs/grani_agni/index.md",'w')
  f=File.open("./docs/grani_agni/words.md",'w')
  f=File.open("./docs/grani_agni/terms.md",'w')
  f.close
  Dir['./data/grani_agni/*'].select { |file| file =~ /agni.*json/ }
end

def agni
  f=File.open("./docs/agni/index.md",'w+')
  f=File.open("./docs/agni/words.md",'w+')
  f=File.open("./docs/agni/terms.md",'w+')
  f.close
  Dir['./data/agni/*'].select { |file| file =~ /agni.*json/ }
  Dir['./data/agni/*'].select { |file| file =~ /agni.*hierar.*json/ }
end

def build_folders
  agni.each { |f|  FileUtils.mkdir_p("./docs/agni/#{JSON(File.open(f).readlines[0])["year"]}") }
  grani.each { |f|  FileUtils.mkdir_p("./docs/grani_agni/#{JSON(File.open(f).readlines[0])["year"]}") }
end

def link_to(text, link)
  "[#{text}](#{HOST_NAME}/#{link})"
end

def rewrite_json
  lines = File.open('/usr/repo/plumbers.github.io/data/grani_agni/06.грани_агни_йоги_1954_г.fb2.json').readlines
  new_lines = File.open('/usr/repo/plumbers.github.io/data/grani_agni/06.грани_агни_йоги_1954_г.fb2.2.json', 'w+')
  lines.each do |line|
    json = JSON(line)
    json["shloka"] = json["text"].scan(/^(\d+)\.?/).flatten.first
    json["text"] = json["text"].gsub(json["text"].scan(/^\d+\.?\s*/).flatten.first, '')
    new_lines << json
    new_lines << "\n"
  end
  new_lines.save
  new_lines.close
end

def text_replacer(line)
  str = line["text"].gsub("\n", "   \n\n")
  # resplacer = "[a normal link to that heading](../.md)"
  # str.gsub(Regexp.union(KEY_WORDS), "   \n\n")
  str
end

def text_link_replacer(tag, text)
  regg = ALL_TAGS[tag].map{|v| "(#{v})" }.join('|')
  matches = text.scan(/#{regg}/i).map(&:compact).flatten.uniq || []
  matches.each do |w|
    text.gsub!(/\b#{w}\b/, "[#{w}](/tags/#{tag})")
  end
  text
end

def write_shloka(f, line)
  f<< NEW_LINE
  f<<"___#{line["shloka"]}___"
  f<< NEW_LINE
  f<< NEW_LINE
end

def write_title(book_link, f, line)
  f<< NEW_LINE
  f<<"[#{line["title"]} #{line["year"]}](#{book_link})"
  f<< NEW_LINE
end

def shloka_with_zero_lead(shloka_num_str)
  shloka = shloka_num_str.to_i
  shloka_str = if shloka < 10
                 "00#{shloka}"
               elsif shloka < 100
                 "0#{shloka}"
               else
                 shloka
               end
end

def write(str, book = 'agni')
# "title":"Грани Агни Йоги","year":"1951","shloka":"0","note":"Янв. 1","text"
#   require_relative 'base'
#   text = "и больше всего"
#   tags = ALL_TAGS.map { |k, v| k if text.match(Regexp.union(v)) }.compact

  line = JSON(str)
  book_link = "#{HOST_NAME}/#{book}/#{line["year"]}"
  shloka_str = shloka_with_zero_lead(line["shloka"])
  f=File.open("./docs/#{book}/#{line["year"]}2/#{shloka_str}.md",'w+')
  text = text_replacer(line)
  tags = ALL_TAGS.map { |k, v| k if text.match(/\b(#{v.join('|')})\b/i) }.compact
  if tags.present?
    # binding.pry
      f << "+++
taxonomies.tags = [
"
tags.each { |t| f << "\"#{t}\",\n" }
f << "]
+++
"
    tags.each do |tag|
      text_link_replacer(tag, text)
    end
  end
  write_title(book_link, f, line)
  write_shloka(f, line)
  f << text
  f.close
end

def write_index(lines, book = 'agni')
  line = JSON(lines[0])
  book_link = "#{book}/#{line["year"]}2"
  # return unless File.exists?("./docs/#{book}/#{line["year"]}/index.md")

  f=File.open("./docs/#{book}/#{line["year"]}2/index.md",'w+')
  f<< "---
search:
  exclude: true
---
  "
  f<< NEW_LINE
  f<<"# #{line["title"]} #{line["year"]}"
  f<< NEW_LINE
  lines.each do |line_str|
    line = JSON(line_str)
    text = line["text"].truncate(91, separator: ' ')
    shloka_str = shloka_with_zero_lead(line["shloka"])
    link = "#{book_link}/#{shloka_str}"
    f<<"* #{link_to(text, link)}"
    f<< NEW_LINE
  end
  f.close
  p "./docs/#{book}/#{line["year"]}/index.md"
end

def update_indexes(line_str, book = 'agni')
  line = JSON(line_str)
  File.open("./docs/#{book}/index.md", 'a') do |file|
    file.puts "[#{line["title"]} #{line["year"]}](#{HOST_NAME}/#{book}/#{line["year"]}/)"
    file<< NEW_LINE
    file<< NEW_LINE
  end
end

SEP = '###'

def update_terms(line_str, book = 'agni')
  line = JSON(line_str)
  @util = DavidBlaine::Utils.new
  term_files = "./docs/#{book}/terms.md"
  file = File.open(term_files, 'a')

  if File.size(term_files).zero?
      file<< "---
search:
  exclude: true
---
"
  end
  shloka_str = shloka_with_zero_lead(line["shloka"])
  file.puts [@util.remove_stop_words(line["text"]).downcase, line["year"], shloka_str].join(SEP)
  file.close
  # f = File.open("./docs/#{book}/terms.md", 'r+')
  # words = f.readlines.join(' ').split
  #
  # # words list -stop_words
  # f = File.open("./docs/#{book}/words.md", 'w+')
  # words.uniq.each do |w|
  #   f << w
  #   f << "\n"
  # end
  # f.close
end

def update_freqs(book = 'agni')
  book = 'agni'
  @util = DavidBlaine::Utils.new

  f = File.open("./docs/#{book}/terms.md", 'r+')
  lines = f.readlines[0..1000]
  words = lines.map{ |line| line.split(SEP).first }.join(' ').split

  groupes = words.group_by { |x| x }.values.sort_by {|w| -w.count }.map { |w| { @util.util.stem(w[0]) => [w[0], w.count] } }
  groupes = groupes.inject({}){ |acc, h| acc[h.keys[0]] ? (acc[h.keys[0]] << h.values) : acc.merge!(h.keys[0] => h.values); acc }.map { |k,v| {k=>v.flatten}}.
      map { |h| { h.keys[0] => h.values[0].unshift(h.values[0].select{ |v| v.is_a?(Numeric) }.sum) }}.sort_by { |v| -v.values[0][0]}.
      map { |h| { h.keys[0] => h.values[0].reject { |v| v.is_a?(Numeric) } } }

  groupes_hash = groupes.reduce(Hash.new, :merge)
  all_keys = REPL.map(&:last)
  groupes = groupes.map do |h|
    key = h.keys[0]
    value = h.values[0]
    keys = all_keys.select { |k| k.include?(key) }.compact.flatten
    if keys.present?
      if all_keys.index(keys).nil?
        puts [all_keys,keys]
        # binding.pry
      end
      new_key = REPL.values_at(all_keys.index(keys)).flatten.first
      { new_key => groupes_hash.slice(*keys).values.flatten }
    else
      { key => value }
    end
  end.compact
  # words list -stop_words
  f = File.open("./docs/#{book}/freqs.md", 'w+')
  f<< "---
search:
  exclude: true
---
  "
  groupes.uniq.each do |w|
    f << w
    f << "\n"
  end
  f.close
end

def copyre
# <!--
#   Copyright (c) 2016-2023 Martin Donath <martin.donath@squidfunk.com>
#   Permission is hereby granted, free of charge, to any person obtaining a copy
#   of this software and associated documentation files (the "Software"), to
#   deal in the Software without restriction, including without limitation the
#   rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
#   sell copies of the Software, and to permit persons to whom the Software is
#   furnished to do so, subject to the following conditions:
#   The above copyright notice and this permission notice shall be included in
#   all copies or substantial portions of the Software.
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
#   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
#   IN THE SOFTWARE.
# -->
  reg = /Copyright (.*)IN THE SOFTWARE./m
  Dir['/usr/repo/plumbers.github.io/**/*.html'].each do |fname|
  # Dir['/usr/repo/plumbers.github.io/vendor/site_agni/agni/1924/1/index.html'][0..0].each do |fname|
    f = File.open(fname, 'r')
    str=f.read
    fnstr = str.gsub!(reg, '')
    f.close

    fn = File.open(fname, 'w+')
    fn << fnstr
    fn.close
  end
end


def make_format
  Dir['/usr/repo/plumbers.github.io/docs/**/*.md'].each do |fname|
    f = File.open(fname, 'r')
    lines=f.readlines
    f.close

    next if lines[0] =~ /---/

    fw = File.open(fname, 'w+')
    fw<< "---
tags:
---
"
    fw << lines.join("\n")
    fw.close
  end
end

def make_format2
  # Dir['/usr/repo/plumbers.github.io/docs/**/index.md'].each do |fname|
  Dir['/usr/repo/plumbers.github.io/docs/agni/19312/*.md'].each do |fname|
  # Dir['/usr/repo/plumbers.github.io/docs/agni/1924/061.md'].each do |fname|
    f = File.open(fname, 'r')
    lines=f.readlines
    f.close

    fw = File.open(fname, 'w+')

    fname_title = File.basename(fname, ".md")
    tags_found = false
    lines.each_with_index do |line, i|
      # fw << line.gsub("https://127.0.0.1:4002", "")
      # fw << line.gsub("../../../tags", "/tag")
      # if line =~ /___/
      #   if fname =~ /00\d.md/
      #     fw << line.gsub(/___(\d)___/, '# 00\1')
      #   elsif fname =~ /0\d\d.md/
      #     fw << line.gsub(/___(\d\d)___/, '# 0\1')
      #   else
      #     fw << line.gsub(/___(\d\d\d)___/, '# \1')
      #   end
      # else
      #   fw << line
      # end
      # if i.zero?
      #   fw << '+++'
      #   fw << "\n"
      # else
      #   fw << line
      # end
      # if line =~ /tags:/
      #   fw << line.gsub("tags:", "taxonomies.tags = [")
      # else
      #   fw << line
      # end
      # if line =~ /\-\s(\b[а-я]*\b)/
      #   fw << line.gsub(/\s\-\s(\b[а-я]*\b)/, '"\1",')
      # else
      #   fw << line
      # end
      # if line =~ /---/
      #   fw << line.gsub(/---/, "]\n+++")
      # else
      #   fw << line
      # end
      # if line =~ /,\n\]\n/
      #   fw << line.gsub(/,\n\]\n/, "\n]\n")
      # else
      #   fw << line
      # end
      if line =~ /taxonomies.tags/
        fw << line.gsub(/taxonomies.tags/, "title=\"#{fname_title}\"\ntaxonomies.tags")
      else
        fw << line
      end
      # tags = ALL_TAGS.map { |k, v| k if line.match(/\b(#{v.join('|')})\b/i) }.compact
      # if tags.present?
      #   tags_found = true
      #   tags.each do |tag|
      #     text_link_replacer(tag, line)
      #   end
      #   fw << line
      # else
      #   fw << line
      # end
      # if line =~ /\/tags\/\[\b.+\b\]/
      #   fw << line.gsub(/\/tags\/\[\b.+\b\]/, "").gsub(/\({2}/, "(").gsub(/\){2}/, ")")
      # else
      #   fw << line
      # end
      # if line =~ /\[(.+)[г]?\]\(\/agni\/\d{4}\)/
      #   m = line.gsub(/[г]?/, "").scan(/\[(.+)\]/)[0][0]
      #   fw << "[#{m}](/agni/#{m})"
      # else
      #   fw << line
      # end
    end
    fw.close
    next #unless tags_found

    # binding.pry
    f = File.open(fname, 'r')
    lines=f.readlines
    f.close

    fw = File.open(fname, 'w+')
    lines.each_with_index do |line, i|
      # binding.pry
      if line =~ /taxonomies.tags \= \[/
        fw << line.gsub(/taxonomies.tags \= \[/, "taxonomies.tags = [\n \"любовь\",")
      else
        fw << line
      end
    end
    fw.close
  end
end

require "zlib"

def compress_file(file_name)
  zipped = "#{file_name}.gz"

  Zlib::GzipWriter.open(zipped, Zlib::BEST_COMPRESSION) do |gz|
    gz.mtime = File.mtime(file_name)
    gz.orig_name = file_name
    gz.write IO.binread(file_name)
  end
end

def compress_all
  Dir['./site/**/*'].select { |file| !File.directory?(file) && (file =~ /.*(html|json|js|css)\Z/) }[0..-1].each do |file_name| #select { |file| file =~ /.*html/ }
  # Dir['./site/**/*'].select { |file| !File.directory?(file) && (file =~ /.*(html|json|js)\Z/) }[0..-1].each do |file_name| #select { |file| file =~ /.*html/ }
    p [file_name: file_name]
    compress_file(file_name)
    # File.delete(file_name)
  end
end

def clean_short_filenames
  # Dir['./docs/**/*.md'].select { |file| !File.directory?(file) && (file =~ /.*(md)\Z/) }.each do |file_name|
  Dir['./docs/**/.md'].reject { |file| File.directory?(file) }.each do |file_name|
    # next if File.basename(file_name).length == 3

    p [file_name: file_name]
    File.delete(file_name)
  end
end

# copyre
# compress_all
# clean_short_filenames
# return
# agni[0..-1].each { |f| lines = File.open(f).readlines[0..-1]; write_index(lines); update_indexes(lines[0]) }
# grani[0..-1].each { |f| lines = File.open(f).readlines[0..-1]; write_index(lines, 'grani_agni'); update_indexes(lines[0], 'grani_agni') }
# make_format
# make_format2
# return
# update_freqs

# rewrite_json
# grani_files = grani[0..-1]#.select { |f| f =~ /1954/ }
# grani_files.each { |f| lines = File.open(f).readlines[0..-1]; lines.each { |line| update_terms(line, 'grani_agni'); write_index(lines, 'grani_agni'); }; update_freqs('grani_agni') }
# grani_files.each { |f| lines = File.open(f).readlines[0..-1]; lines.each { |line| write(line, 'grani_agni') } }
# return
#
agni_files = agni[0..-1]
# # agni_files.each { |f| lines = File.open(f).readlines[0..-1]; lines.each { |line| update_terms(line, 'agni'); write_index(lines, 'agni'); }; update_freqs('agni') }
agni_files.each { |f| lines = File.open(f).readlines[0..-1]; lines.each { |line| write_index(lines, 'agni'); }; }
# agni_files.each { |f| lines = File.open(f).readlines[0..-1]; lines.each { |line| write(line, 'agni') } }
