#!/usr/bin/env ruby

# git_reports.rb
# print git statistics of users' commits and added/deleted lines of code
# simply run "ruby git_reports.rb" in a git repository

puts "git log --numstat --no-merges"

# retrieve data
log = %x"git log --numstat --no-merges"
logs = log.split(/(^commit [0-9a-f]{40})\n/)[1..-1]
t = true; logs.select!{t=!t}

# parse
allstat = logs.map do |cmt|
  commit = cmt.split(/\n/).map do |l|
    l.scan(/\AAuthor: ([^\n]*)/)[0] ||
      l.scan(/\A([\d]+|-)\t([\d]+|-)\t/)[0]
  end.flatten(1).compact
  t = false; commit[1] = (commit[1..-1].select!{t=!t}.map(&:to_i).reduce(&:+).to_i rescue 0)
  t = true; commit[2] = (commit[1..-1].select!{t=!t}.map(&:to_i).reduce(&:+).to_i rescue 0)
  commit
end.group_by{|e| e[0]}

# convert, sort
stats = allstat.map{ |name, st|
  [name.to_s,
    st.length.to_s,
    '+' + st.map{|d|d[1]}.reduce(&:+).to_s,
    '-' + st.map{|d|d[2]}.reduce(&:+).to_s
  ]
}.sort{|l, m| m[1].to_i <=> l[1].to_i}

files = (%x"git ls-files").split
loc_blame = files.map{|f| %x(git blame --line-porcelain #{f})}

loc_names = loc_blame.map{|rep|
  rep = rep.unpack('C*').pack('C*')
  rep.scan(/\nauthor ([^\n]*)\nauthor-mail( [^\n]*)/).map(&:join)
}.flatten(1)
names = loc_names.uniq
loc_stat = Hash[names.map{|name| [name, loc_names.count(name)]}]

# format:
head = ['Name', 'Commits', '+LOC', '-LOC', 'OWN']

col_widths = stats.map{|l| l.map(&:length)}.transpose.map(&:max)
nam_width, com_width, add_width, del_width = col_widths
nam_width = [nam_width, head[0].length].max
com_width = [com_width, head[1].length].max + 1
add_width = [add_width, head[2].length].max + 1
del_width = [del_width, head[3].length].max + 1

own_width = loc_stat.map{|k,l| l.to_s.length}.max
own_width = [own_width, head[4].length].max + 1

sum_commits = stats.map{|e| e[1].to_i}.reduce(&:+)
sum_loc_add = stats.map{|e| e[2].to_i}.reduce(&:+)
sum_loc_del = stats.map{|e| e[3].to_i}.reduce(&:+)
sum_loc_own = loc_stat.map{|k,e| e.to_i}.reduce(&:+)

tot_width = (nam_width+com_width+add_width+del_width+own_width+(head.length-1)*3)
tbl_hor_lin = '-' * tot_width
tbl_hor_eql = '=' * tot_width
tbl_head = ([head]).map{ |e|
  [e[0].ljust(nam_width, ' '),
    e[1].rjust(com_width, ' '),
    e[2].rjust(add_width, ' '),
    e[3].rjust(del_width, ' '),
    e[4].rjust(own_width, ' ')] * ' | '
}*"\n"

tbl_cont = (stats).map{ |e|
  [e[0].ljust(nam_width, ' '),
    e[1].rjust(com_width, ' '),
    e[2].rjust(add_width, ' '),
    e[3].rjust(del_width, ' '),
    (loc_stat[e[0].unpack('C*').pack('C*')].to_i.to_s).rjust(own_width, ' ')] * ' | '
}*"\n"

#tbl_head = tbl_hc[0..(tot_width-1)]
#tbl_cont = tbl_hc[(tot_width+1)..-1]
tbl_foot = [''.ljust(nam_width, ' '),
  sum_commits.to_s.rjust(com_width, ' '),
  sum_loc_add.to_s.rjust(add_width, ' '),
  sum_loc_del.to_s.rjust(del_width, ' '),
  sum_loc_own.to_s.rjust(own_width, ' ')] * ' | '

table = [tbl_head, tbl_hor_lin, tbl_cont, tbl_hor_eql, tbl_foot] * "\n"

# output:
puts table
