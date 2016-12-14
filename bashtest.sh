#!/bin/bash

#    for dir in /home/gv/dir1/*/ ; do
#      echo $dir
#    done
#    for dir in /home/gv/dir1/* ; do
#      echo $dir
#    done
#    for dir in $(ls /home/gv/dir1/*/) ; do
#      echo $dir
#     done

function numcheck {
echo "Give a number:" && read var
#var=1

if [ "$var" -eq "$var" ] 2>/dev/null; then #if you ommit the 2>/dev/null then if you enter a worng value, bash will complain in your screen.
  echo number
else
  echo not a number
fi
}

#numcheck

#bc <<< "scale=2;$var1/$var2" or answer=$(bc <<< "scale=2;$var1/$var2")


function readlog1 {
finddivider () {
groups=$(bc <<< "scale=1;$NoOfLines/$1")
decimals=$(cut -f 2 -d "." <<<$groups)
}

readarray -O 1 FileContents < <(cat test.log)
NoOfLines=${#FileContents[@]}
divider=3 # initial setting
finddivider $divider

while [[ $decimals != "0" ]]; do
divider=$(($divider + 1))
finddivider $divider
done

if [[ $divider == $NoOfLines ]]; then
echo "No integer divider found. Default divider of 3 will be used".
divider=3
echo "Divider=" $divider
fi

for ((i=1;i<=$divider;i++)); do
echo $i ${FileContents[$i]} 
done

#readarray tt 
}

function fileread {
datasource=$(cat test.log)
while IFS='' read -r line; do
filename=$(cut -f 1 -d " " <<<$line)
contents=$(cut -f 2 -d " " <<<$line)
echo "$contents" > "$filename"
done <<< "$datasource" 
}

function importvals {
source ./a.txt
echo "value x=" $x
echo "value y=" $y
echo "value z=" $z
}

function filecount {
while read i; do
echo -e "$i:  \c" 
ls -Fall "$i" | wc -l
done < "b.txt"
}

function valreplcae {
optadd=13016
source=$(cat c.txt)
while IFS='' read -r line; do
sed -ie "0,/{OPTIONS}/ s/{OPTIONS}/{OPTIONS_$optadd}/" c.txt
optadd=$(($optadd + 2))
done <<< "$source" 
cat c.txt
}

function autoscript {
FILE=`readlink -f "${BASH_SOURCE[0]}"` #Gets current script filename
DIR=`dirname "${FILE}"` #Gets current script directory.
echo "File=$FILE - Dir = $DIR"

repl() {
    STRING=$(cat $DIR/d.txt) #read existed file d.txt
    STRING=$(echo "$STRING" | sed "s/%%NUMBER%%/$1/") #without double quotes the new line character is removed from $STRING
    echo "$STRING"
}
repl 50 > e.sh #send the output of repl function to a new file called e.sh
cat e.sh
exit
}

function fileinarray {
IFS=$'\n'
readarray -t -O1 data< <(grep -h -e "\^D" -e "\^A" -e "^F" a.txt)
posA=1
for i in "${data[@]}"; do
if [[ "$i" = "^A"* ]]; then
	textA="${data[$posA]}"
	posD=$posA
	posF=$posA
	textD=""
	textF=""
	while [ "$posD" -ge 1 ] && [[ "$textD" != "^D"* ]]; do
	posD=$(($posD - 1))
	textD="${data[$posD]}"
	done

	while [ "$posF" -le "${#data[@]}" ] && [[ "$textF" != "F"* ]]; do
	posF=$(($posF + 1))
	textF="${data[$posF]}"
	done
	textADF="$textA | $textD | $textF"
	echo "ADF=$textADF"
fi
posA=$(($posA + 1))
done
unset IFS
exit
}

function renamewithdirname {
#http://stackoverflow.com/questions/40645931/can-i-get-only-parent-directory-for-naming-to-filename-in-unix
#search for files, check existance and then appends to filename the last directory (i.e file a.zip is renamed to a_PythonTests.zip

WORKDIR="/home/gv/Desktop/PythonTests" #assigned for my case
find "$WORKDIR" -type f -name '*.zip' | while read file
do
  basename=$(basename "$file")
  dirname=$(dirname "$file")
  suffix=$(basename "$dirname")
  if [[ "$basename" != *"_${suffix}.zip" ]]; then
    mv -v "$file" "${dirname}/${basename%.zip}_${suffix}.zip"
  fi
done
# GV way - similar to above but working only for one file:
#dir="/home/gv/Desktop/PythonTests/"
#filename="a"
#filesuffix=".txt"
#filedir=$(dirname "$dir$filename$filesuffix" | grep -o '[^/]*$')
#echo "Directory of $filename$filesuffix : $filedir" 
#oldname="$dir$filename$filesuffix"
#ls -l $oldname
#echo "Old name : $oldname"
#echo -e "press any key \c";read anykey
#newname="$dir$filename""_""$filedir""$filesuffix"
#echo "New Name: $newname"
#mv "$oldname" "$newname" #this works ok
#find $dir -type f -name "$filename$filesuffix" -exec mv "$oldname" "$newname" \;
#ls -l /home/gv/Desktop/PythonTests/*.txt
}

function lettercheck { 
#reads lines from a file containing only one word per line, and checks if this word has duplicate chars in any position.
#To do this we store the line in an array of chars ($word) using the fold -w1 or grep -o . technique.
#to verify if the char exists in word we use the wc -w trick (count after grep - gives a number of 2 or n if char is found 2 or n times in word).
#
datasource=$(cat b.txt)
newdata=""
while IFS='' read -r line; do
found=0
readarray word < <(echo "$line" |fold -w1)
	for eachletter in ${word[@]}; do
		found=$(echo "$line" | grep -o $eachletter |wc -w)
		if [[ $found -ge 2 ]] && [[ ${newdata[@]} != *"$line"* ]]; then 
			newdata+=( "$line" )
		fi
	done
unset word eachletter found
done <<< "$datasource"
echo -e "New Data \n" 
printf '%s\n' ${newdata[@]}
}

function simplenameread {
read -p "Enter Name: " name #mind the -p option (=prompt). i used to do it with echo -e "Enter Name\c";read name
if [ "$name" == "" ]; then
    sleep 1
    echo "Oh Great! You haven't entered name."
    exit
else
echo "You enter name $name"
fi
}

function comparetwofiles {
readarray data < <(comm --nocheck-order --output-delimiter "-"  b.txt c.txt)
for ((i=0;i<${#data[@]};i++)); do
va=$(grep -e "-" <<<"${data[$i]}")
if [[ $va == "" ]]; then
	echo ${data[$i]} " null"
elif [[ $va == "--"* ]]; then 
		data2=$(echo ${data[$i]} | grep -Po '[0-9]*')
		echo $data2 " " $data2
else
	data2=$(echo ${data[$i]} | grep -Po '[0-9]*')
	echo "null " $data2
fi
done

}

function listfilesindir {
#for files in /home/gv/Desktop/PythonTests/*.sh; do #this does not handle subfolders and files with spaces in their name
IFS=$'\n'
for files in $(find /home/gv/Desktop/PythonTests/ -name "*.txt" ); do
old_filename="$files"
old_filename_stripped=$(basename -a "$files")
echo "filename full : $old_filename - file name stripped: $old_filename_stripped"
done
unset IFS
# old_filename will look like this /user/***/documents/testmapa/afile.pdf
# If you need to have only the filename without directory}{/ then you can use
#old_filename=$(basename -a $files)
# this will result to old_filename=afile.pdf without directory info

#read -p "Press any key to rename file : $old_filename "

#your rest codes here
#done
}

function logicalduplicate {
#this one gets a text (or a line from file) and finds a logical duplicate line 
word1+=( $(echo "this is my life" |fold -w1) )
sortedword1=($(echo ${word1[@]} | tr " " "\n" | sort))
echo "${sortedword1[@]}"
echo "${sortedword2[@]}"

if [[ $sortedword1 == $sortedword2 ]]; then
echo "Word 1 and Word 2 are the same, delete one of them"
fi
}

function jointwofiles {
#based on the second field of file a.
#can also be done with join --nocheck-order -1 2 -t"|" a.txt b.txt
#mind the possible extra spaces in field 2 of file a

while IFS="|" read -r line title1 rest; do
title2=$(echo $title1)
genre=$(grep -e "$title2" b.txt |cut -f2 -d"|")
echo $line "|" $genre "|" $rest
done <a.txt
}

function extensions {
read -a extensions -p "give me extensions seperated by spaces:  " # read extensions and put them in array $extensions
for ext in ${extensions[@]}; do  #for each extension stored in the array
echo -e "- Working with extension $ext"
destination="/home/gv/Desktop/folder$ext"
#misc="/Users/christopherdorman/desktop/misc"
mkdir -p "$destination"
mv  -v unsorted/*.$ext "$destination";
done
#mv  -v unsorted/*.* "$misc"; 
# since previously you moved the required extensions to particular folders
# move what ever is left on the unsorted folder to the miscelanius folder

}

function Rename_Extensionless_Files {
#this looks for files without extension and adds .txt extension
IFS=$'\n'
direc="/home/gv/Desktop/PythonTests/"
for fi in $(find $direc -maxdepth 1 -type f -regextype egrep -regex "(^$direc)+[^.]*"); do
echo "File found: $fi"
mv -v "$fi" "$fi.txt"
done
unset IFS
#you can remove the maxdepth option to grab all files in subdirs.
#Same job can be done in one line much better like this:
#(http://unix.stackexchange.com/questions/313819/add-file-extension-to-files-that-have-no-extension)
#find . -type f  ! -name "*.*" -exec mv -v {} {}.txt \;
#OR
# find . -type f ! -name "*.*" -exec bash -c 'mv "$0" "$0".mp4' {} \;
#mind the ! operator (can be written also as -not) . 
#Actually find with ! operator finds files that their name does NOT match *.* format = extensionless files.

}

function splitword {
echo "Welcome"
read -p "Give me a word" resp
readarray letter < <(echo "$resp" |fold -w1)
for ((i=0;i<${#letter[@]};i++)); do
echo "letter[$i] : ${letter[$i]}"
done
}

function another_rename {
for file in *.txt
# rename files with name "a a (01).txt to "a a (001).txt" - file name containing spaces.
do 
number=$(grep -Eo '[0-9]*' <<<$file)
newname=$(sed "s/([0-9]*).txt/(0$number).txt/"<<<$file)
echo "old file = $file - new name=$newname"
mv "$file" "$newname"
done
ls -l *.txt
}

function trikc_rename {
# This function handles filenames with spaces and renames them using mv (i.e file "a a (01<>).txx)
# The tricky assignment of mv commands replaces unwanted characters with a low dash _
find . -name "*.txx" |while read -r filei ;do
bn=$(basename "$file")
dn=$(dirname "$file")
echo "Full Filename: $file - basename: $bn - Dirname: $dn"
#cp -v "$i" "/home/gv/Desktop/dtmp/$bn"
mv -v "$dn/$bn" "$dn/${bn//[\/<>:\\|*\'\"?]/_}"
done
}


# find /tmp -name '*.pdf' -or -name '*.doc' | xargs rm #mind the -or operator
# find . -type f  ! -name "*.*" -exec mv -v {} {}.txt \;
# find . -type f -name "*.txx" -exec bash -c 'mv -v "$0" "$0".mp4' {} \;
# find /dir1 -type f -printf "%f\n" #prints only file name, without directory in front.
# If printf is combined with -exec {} or bash -c $0, those variables still get the whole file name. printf is only used for print formating.
# for f in "$(find . -type f -name "*.txx" -printf '%f\n')";do echo "$f";done -> Works perfect even with spaces in filenames due to double quotes in find.

# find . -type f -name "*.txx" -exec bash -c 'mv -v "$0" "${0//[\/<>:\\|*\"?]/_}"' {} \; #this somehow worked but is mixing up directories.



again=1
dr="*"
while [[ "$again" -eq "1" ]]; do
	again=0
	echo "Current Dir = $dr"
	for i in $dr; do 
		if [[ -d "$i" ]]; then
			#echo "Directory $i found"
			again=1
		else #if it is not a directory 
			mv "$i" "${i//[\/<>:\\|*\'\"?]/_}"
			echo "$i"
		fi
	done

	if [[ "$again" -eq "1" ]]; then
		dr="$dr/*"
		echo "Again is 1 . New Dir = $dr"
	fi
done


# Various HowTo
# Check if a slash '/' exist in the end of variable and add it if it is missing
# root@debi64:/home/gv/Desktop/PythonTests# echo "/home/gv/Desktop" |sed 's![^/]$!&/!'
# /home/gv/Desktop/

# multi grep with reverse operation : grep -v -e "pattern" -e "pattern"
# grep -nA1 -e "====" c.txt |grep -B1 -e "====" |grep -v -e ":" -e "--"

# sed: http://stackoverflow.com/questions/83329/how-can-i-extract-a-range-of-lines-from-a-text-file-on-unix
# get a range of lines with sed: sed -n '16224,16482p;16483q' filename
# mind the 16483q command. Instructs sed to quit. Without this , sed will keep scanning up to EOF.
# To do that with variables: $ sed -n "$FL,$LL p" file.txt

# sed -n '/WORD1/,/WORD2/p' /path/to/file # this prints all the lines between word1 and word2
# There is a direct awk alternative: awk '/Tatty Error/,/suck/' a.txt
# you can get line numbering if you first cat -n the file , but you will need an extra pipe for that.

# Find a word in file/stdin and grep from this word up to the last \n = new line = eof.
# Remember that $ represents "last"-end of line in regex
# apt show xfce4-wmdock* |sed -n '/Description/,/$\/n/p'
# You can do the same starting from a line up to eof. 
# Also this should work sed -n '/matched/,$p' file , wher matched can be a line number or a string

# Replace a string with s/ switch
# sed  -n 's/Tatty Error/suck/p' a.txt # This one replaces Tatty Error with word suck and prints the whole changed line
# echo "192.168.1.0/24" | sed  -n 's/0.24/2/p' 
# More Sed replace acc to http://unix.stackexchange.com/questions/112023/how-can-i-replace-a-string-in-a-files
# Replace foo with bar only if there is a baz later on the same line:
# sed -i 's/foo\(.*baz\)/bar\1/' file #mind the -i switch which writes the replacement in file (-i = inplace).
# Multiple replace operations: replace with different strings
# You can combine sed commands: sed -i 's/foo/bar/g; s/baz/zab/g; s/Alice/Joan/g' file #/g means global = all matches in file
#
# Replace any of foo, bar or baz with foobar : sed -Ei 's/foo|bar|baz/foobar/g' file

# Trick to get only one line from file using head and tail
# Usage: bash viewline myfile 4
# head -n $2 "$1" | tail -n 1
#
# ls alternatives
# find /home/gv -maxdepth 1 -type d -> list only directories
# find /home/gv -maxdepth 1 -type f -> lists only files
# find /home/gv -maxdepth 1 -> lists both
# output of find can be piped to wc -l as well.
#
# More Text Replace with sed
# Consider file containing:
# ltm node /test/10.90.0.1 {
#    address 10.90.0.1
#}
# 1. Let's suppose you want to add at the end of address %200
# sed '/address/ s/$/%200/' a.txt
# s = replace, $= end of line
# Alternatives
# str="address 10.90.0.1";newstr=$(awk -F"." '{print $1"."$2"."$3"."$4"%200"}'<<<$str);echo $newstr 
# awk '/address/ && sub("$","%200") || 1' file.txt
#
# 2. Lets suppose you want to replace the last digit with .20
# sed '/address/ s/.[0-9]*$/.20/' a.txt
# .[0-9]*$ = regex = starts with dot, contains numbers in range 0-9, multiple numbers (*) and then EOL ($)
# alternatives
# str="address 10.90.0.1";newstr=$(awk -F"." '{print $1"."$2"."$3".20"}'<<<$str);echo $newstr

# Use a variable in sed
# You just need to double qute the sed actions instead of single quotes.

# Search for a process using top . Top seems to catch all processes:
# top -p $(echo $(pgrep time) |sed 's/ /,/g')
# pgrep search for processes matching pattern even partially. pidof could be used if exact process name is known.
# Defaut output of pgrep is to seperate processes found with new lines. By echo \n is removed and a space is used.
# If you replaace that space with a comma, then can be fed to top -p which accepts multiple pids (comma seperated)

# Comparing files and variables:
# diff can compare two files line by line.
# You can also trick use diff like this to compare two variables line by line : diff <(echo "$a") <(echo "$b") or diff <(cat <<<"$a") <(cat <<<"$b")

# Processes List and Kill
# ps all and ps aux
# list all of tty1 : ps -t tty1
# Isolate pids: ps -t tty1 |cut -d" " -f1
# Remove new line chars: ps -t tty1 |echo $(cut -d" " -f1)
# Kill all those processes at once: kill -9 $(ps -t tty1 |echo $(cut -d" " -f1)) # kill requires pids to be seperated by spaces, not new lines.
