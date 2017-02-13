# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly (~/.bashrc).
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
#if [ -f ~/.bash_aliases ]; then
#    . ~/.bash_aliases
#fi
#Remark: .bashrc of user has already above check condition but root .bashrc not.
#Install it using cp .bash_aliases /home/gv/ and cp .bash_aliases /root/ or cp .bash_aliases $HOME/ (under root terminal)
# You can import the recent aliases on the fly by running root@debi64:# . ./.bash_aliases

alias cd..='cd ..'
alias cls='clear'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias nocrap='grep -i -v -e .page -e .png -e .svg -e .jpg -e messages -e usr/share/man -e changelog -e log -e localle -e locale -e "/doc/"'
alias yadit='yad --text-info --center --width=800 --height=600 --no-markup --wrap'
alias lsdir='ls -l -d */'
alias dirsize='du -h'
alias gitsend='git add . && git commit -m "update" && git push'
alias bashaliascp='cp -i .bash_aliases /home/gv/ && cp -i .bash_aliases /root/'
alias update='apt-get update && apt-get upgrade && apt-get dist-upgrade'
alias printfunctions='set |grep -A2 -e "()"'
alias weather='links -dump "http://www.meteorologos.gr/" |grep -A7 -m1 -e "Αθήνα" |sed "6d"'

function dpkgnum { dpkg -L "$1" |nl;}  #prints info about a package with numbering of the entries.

function printarray () { 
echo "printarray: Prints indexed array $1 as stored in bash environment "
# ab=( "one" "two" "fi ve" );printarray --> please provide a var
# printarray ab
# [0]="one
# [1]="two
# [2]="fi ve" #works even with space in array values
[[ -z $1 ]] && echo "Provide an array variable to display" && return
declare -p $1 |sed "s/declare -a $1=(//g; s/)$//g; s/\" \[/\n\[/g"

}

function mandiff { 
echo "mandiff: Compare installed man pages $1 vs the online man page at maniker.com"
[[ -z $1 ]] && echo "manpage missing " && return
[[ $(man -w "$1" 2>/dev/null) == "" ]] && echo "no valid manpage found for $1" && return
#mandiff = compare with diff an installed man page with online one by mankier.com
diff -y -bw -W 150 <(links -dump "https://www.mankier.com/?q=$1" |less |fold -s -w 70) <(man $1 |less |fold -s -w 70)
}

function lsdeb () { 
echo "lsdeb: Displays contents of the .deb file corresponding to an apt-get install package $1"
[[ -z $1 ]] && echo "apt pkg file missing " && return
local tmpdeb=$(apt-get --print-uris download $1 2>&1 |cut -d" " -f1)
tmpdeb=$(echo "${tmpdeb: 1:-1}")
dpkg -c <(curl -sL -o- $tmpdeb)
}

function aptshowlight() { 
echo "aptshowlight: It is apt show $1 but in light version , giving only Package name and short description"
[[ -z $1 ]] && echo "Package missing " && return
#aptshowlight : runs apt show on given arg $1 , and prints only package name, section and Description. Combine with yadit.
#notice that if you specify to -A (after context) more lines than really available the results are not correct.
apt show $1 2>/dev/null |grep -A2 -e "Package:" -e "Description:" |grep -v -e "Version\|Priority\|Maintainer\|Installed-"
}

function aptshowsmart() { 
echo "aptshowsmart: apt show $1 in a smart way , using less pager"
[[ -z $1 ]] && echo "Package missing " && return
local ass+=$(apt list $1 2>/dev/null |grep -v "Listing" |sed "s#\\n# #g" |cut -d/ -f1)
apt show $ass |less
}

function debman { 
echo "debman: debian man pages online of package $1"
[[ -z $1 ]] && echo "Pass me a package to query debian manpages" && return
#debman uses the 2017 new web page with jump option
links -dump https://manpages.debian.org/jump?q=$1 |awk "/Scroll to navigation/,0" |less
}


function wiki() { 
echo "wiki: Returns wikipedia $@ entries in terminal"
[[ -z $1 ]] && echo "Pass me a page to search WikiPedia " && return
#dig +short txt $1.wp.dg.cx #This uses dig (apt install dnsutils) and does not work.
local q="$@"
links -dump "https://en.wikipedia.org/w/index.php?search=$q" |less
# better to use $@ that parses all args together ; Otherwise the arg red hat is passed as $1=red and $2=hat (or it has to be quoted)
}

function dcat() { 
echo "dcat: directory cat - cat files within directory $1, including subdirs"
[[ -z $1 ]] && echo "Pass me a directory to cat files" && return
local d="$1"
if [[ ! -d $d ]]; then 
	echo "This is not a directory" && return
else
	[[ "${d: -1}" != "/" ]] && d="${d}/" #if last char is not a dash, add a dash
	echo "directory to scan= $d"
	#for f in /sys/class/power_supply/BAT0/*;do echo "$f";cat "$f";done #this works but it does not go inside sub dirs
	find "$d" -type f -exec bash -c 'echo "File: $0";cat "$0"' {} \;
fi
}

function findexec {
echo "findexec: find executable files under directories of /. Double quotes on file name is MANDATORY"
[[ -z $1 ]] && echo "Pass me a file name to look for executable files under / dir" && return
local fname=("$1")
echo "arg=$fname"
#for $1=*grep* search for all combinations: *grep* , grep*,*grep,grep
#[[ "${fname:0:1}" == "*" ]] && fname+=("${fname:1}") #if starts with * remove it and add it as a saparate search term
#[[ "${fname: -1}" == "*" ]] && fname+=("${fname:0:-1}") #if ends with * remove it and add it to array
#[[ "${fname:0:1}" == "*" ]] && [[ "${fname: -1}" == "*" ]] && fname+=("${fname:1:-1}") #if first and last char is * remove them
#for f in "${fname[@]}";do find / -type f -executable -name "$f";done 
find / -type f -executable -name "$fname"
}

function mancheat { 
echo "mancheat: explore the cheat sheets using man page viewer"
[[ -z $1 ]] && echo "Pass me a cheat file name to display from ./cheatsheets/ directory" && return
	man --nj --nh <(h=".TH man 1 2017 1.0 $1-cheats";sed "s/^${1^^}:/.SH ${1^^}:/g; s/^$/\.LP/g; s/^##/\.SS /g;G" cheatsheets/${1,,}*gv.txt |sed 's/^$/\.br/g; s/\\/\\e/g;' |sed "1i $h");
#This works directly in cli:
#man --nj <(h=".TH man 1 "2017" "1.0" cheats page";sed "1i $h" cheatsheets/utils*gv.txt |sed 's/^UTILS:/.SH UTILS:/g; s/^$/\.LP/g; s/^##/\.SS /g; s/\\/\\\\/g;G' |sed 's/^$/\.br/g')
}

# Tips about functions usage as an alias and sourcing them to other scripts
# See all declared functions with 'set' - it will not be available in 'alias' command any more.
# Bash manual claims that is better to use direct functions instead of alias.
# You can declare just functions without alias and you can call those functions by terminal without problem.
# You can also export -f the function/s to be available in all childs/scripts.
# In this case you need to be sure that function names exported will not be redifined again (same name) in your scripts
# To list all the functions loaded by bash use 'declare' or 'set'

# Alternativelly you might source the whole .bash_aliases file into your script and have all function / aliases available in your script.
# In order alias to be available in a shell script it might be required to include 'shopt -s expand_aliases ' option inside your script.
# According to man bash this option is ON by default for interactive shells (also verified by shopt |grep alias)
# But since a script is considered a kind of non-interactive shell , the expand_aliases option has to be set in script to affect the script environment / subshell

# Instead of sourcing the whole file you can source part of the file with command substitution technique:
# Working example: source <(sed -n '/function justatest/,/\}/p' .bash_aliases) && justatest will use justatest in your separate external script.
# Another working example: eval "$(sed -n '/function justatest/,/\}/p' .bash_aliases)" && justatest
# Sed will work correctly if function is written in multi line format. For one liners doesnot work ok. Better to use grep.

# You can also source a particular alias in your scripts using:
# shopt -s expand_aliases &&  source <(sed -n "/function __debman/p" .bash_aliases) && debman agrep
# tested and works fine.
# Alternative that strips the alias part and keeps only the function part:
# sed -n "/alias debman/p" .bash_aliases |awk -F="'|}" '{print $2"}"}'
