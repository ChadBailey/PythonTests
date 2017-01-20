#!/bin/bash

{ #Declarations
export TMPFILE=/tmp/yadvalues
set -f
#Declarations 
}

function pkgselect { 
#echo "Args Received by caller = $@" |yad --text-info
#$0 " , " $1 " , " $2 " , " $3 " , " $4 " , " $5
#echo -e "FILEID=\"$1\"\nFILENAME=\"$4\"\nFILECOMMAND=\"$5\"" > $TMPFILE
echo -e "PKGDIS=\"$2\"\nPKGVER=\"$4\"" > $TMPFILE
#cat $TMPFILE |yad --text-info
}
export -f pkgselect

function pkgdisplay { 
source $TMPFILE
#descr=$( apt show "$PKGDIS" )
#yad --title="Package Display-$PKGDIS" --no-markup --center --text="${descr[@]}" --width=800 --height=200 --button="Go Back":0

pkgdis2=$(echo $PKGDIS |cut -f1 -d"/")
descr=$(echo -e "------------------# apt policy $pkgdis2 #---------------------- \n ")
descr+=$( apt policy "$pkgdis2" )
descr+=$(echo -e "\n ------------------# apt show $PKGDIS #----------------------\n ")
descript=$( apt show "$PKGDIS" )
if [[ "$descript" =~ "Description:" ]];then
descr+=$( apt show "$PKGDIS" )
else
descr+=$(echo -e "\n ------------------# No description available #----------------------\n ")
fi
displ=$(yad --title="Package Display-$PKGDIS" --no-markup --text-info<<<"$descr" --center --width 800 --height=400 --editable --wrap --button="Go Back":0)
#If you don't use this method (displ=$(yad....) then the whole yad text-info will be printed in the terminal.
}
export -f pkgdisplay

function savepkglist {
IFS= 
#for some reason the expected IFS=$'\n' is messing things up
printf "%s\n" ${LIST3[@]} >pkglist.dat # this prints the LIST3 correctly at file.

if [[ $? == 0 ]]; then
yad --text="Package List saved to comma separated file pkglist.dat"
fi
unset IFS
}
export -f savepkglist

function aptinstall {
for i in ${toinstall[@]}; do #$toninstall array is global var assigned in the main programm by yad.
	istrip1=$(echo $i |cut -f1 -d"/")
	istrip2=$(echo $i |cut -f2 -d"/")
	if [ $istrip2 == "experimental" ]; then
	echo "Experimental Package Detected"
	fi
	#exit
	echo "preparing to install :" $i
	read -p "Press any key to continue installing $i or type s/q to skip/exit:" next
	if [[ $next == "q" ]]; then
		exit 1
	elif [[ $next != "s" ]]; then
		if [ $istrip2 == "experimental" ]; then
			echo "Experimental Package Detected"
			apt install -t experimental $i
		else 
			apt install $i
		fi
		#echo "This is just an echo for testing: Command that should run is # apt install $i # " && echo "installation of package #$i# finished"
		# Combining commands with && means that next command is executed only when prev command exited with code 0 = success.
	fi
done
}

function selectpackages {
if [[ "$1" != "" ]]; then # is arg $1 is not empty = arg is sent 
ptrn="$1"
else #if arg $1 is empty , apply the existed value.
ptrn=$pattern
fi
selections=$(yad --title="Select Files"--window-icon="gtk-find" --center --form --separator="," \
		--date-format="%Y-%m-%d" \
		--field="Pattern:" "$ptrn" --field="Exclude1:" "dbg" --field="Exclude2:" "dev" \
		--field="Show installed":CB "All!Not Installed!Installed!All Unstable!Installed vs Unstable!All Experimental!Installed vs Experimental" )

if [ $? == 1 -o $? == 252 ]; then #1 is for Cancel Button, 252 is for ESC button
echo "Script Exit."
exit 1
fi

echo $selections
pattern=`echo $selections | awk -F',' '{print $1}'`
#pattern=$(echo -e \"$pattern\")
if [[ $pattern = "*" ]]; then
pattern=""
fi

if [[ "${pattern: -1}" != "*" ]]; then
pattern=$(echo "$pattern""*")
fi
echo "Pattern for apt list = $pattern"
#sleep 5 && apt list "$pattern" 2>&1 && exit

exclude1=`echo $selections | awk -F',' '{print $2}'`
exclude2=`echo $selections | awk -F',' '{print $3}'`
installed=`echo $selections | awk -F',' '{print $4}'`

}

function printarray {
arr=("${@}")
ind=0
	echo "Start of Array"	
	echo "Array[@]=" "${arr[@]}"
	for e in "${arr[@]}"; do
		echo "Array[$ind]=" $e
		ind=$(($ind+1))
	done
 	printf "End of Array\n\n"

}

function listdeb {
	source $TMPFILE
	pkg="$PKGDIS"
	aptpkg="$PKGDIS"
	echo "Package: $aptpkg"
	debname=$(find . -name "$pkg*.deb")
	if [[ "$debname" == "" ]];then 
		apt-get download "$aptpkg" 2>/dev/null |yad --progress --pulsate --auto-close --title="Downloading..."
		debname=$(find . -name "$pkg*.deb")
	fi
	echo "Deb Name = $debname"
	datatar=$(ar t "$debname" |grep "data.tar")
	echo "data.tar = $datatar"

	if [[ ${datatar##*.} == "gz" ]];then 
		options="z"
	elif [[ ${datatar##*.} == "xz" ]];then
		options="J"
	else
		return 1
	fi
	debcontents=$(ar p "$debname" "$datatar" | tar t"$options")
	echo -e "${debname:2}\n\n$debcontents" |yad --text-info --center --height 500 --width 500
	rm -f $debname
}
export -f listdeb

function readmanpage {
	source $TMPFILE
	pkg="$PKGDIS"
	aptpkg="$PKGDIS"
	if [[ "$PKGVER" != "(none)" ]];then
		man $pkg 2>&1 |yad --text-info --height=700 --width=1100 --center --title="$pkg Manual " --wrap --show-uri --no-markup \
		--button="Try Online":10 \
		--button="gtk-ok":0 \
		--button="gtk-cancel":1
		resp=$?
		[[ "$resp" -ne 10 ]] && return 0
	fi
	echo "Package: $aptpkg"
	debname=$(find . -name "$pkg*.deb")
	if [[ "$debname" == "" ]];then 
		apt-get download "$aptpkg" 2>/dev/null |yad --progress --pulsate --auto-close --title="Downloading..."
		debname=$(find . -name "$pkg*.deb")
	fi
	echo "Deb Name = $debname"
	datatar=$(ar t "$debname" |grep "data.tar")
	echo "data.tar = $datatar"

	if [[ ${datatar##*.} == "gz" ]];then 
		options="z"
	elif [[ ${datatar##*.} == "xz" ]];then
		options="J"
	else
		echo "data.tar is not a gz or xz archive. Exiting" |yad --text-info --height 500 --width 500
		return 1
	fi
	manpage+=($(ar p $debname $datatar | tar t"$options" |grep "man/man" |grep -vE "\/$" |awk '{print $NF}'))
		if [[ -z $manpage ]];then
			debcontents=$(ar p "$debname" "$datatar" | tar t"$options")
			echo -e "No man pages found in deb package. \n${debname:2} Contents \n \n $debcontents" |yad --text-info --center --height 500 --width 500
			rm -f $debname
			return 1
		else
			echo "man page found: ${#manpage[@]}"
			#declare -p manpage |sed 's/declare -a manpage=(//g' |tr ' ' '\n' |sed 's/)$//g'
		fi
	
		if [[ ${#manpage[@]} -eq 1 ]]; then
			echo "man page found - Display "
			#ar p "$debname" "$datatar" | tar xO"$options" $manpage |man /dev/stdin |yad --text-info --height=500 --width=800 --center --title="$pkg Manual " --wrap --show-uri --no-markup
			mpg=$(man <(ar p "$debname" "$datatar" | tar xO"$options" $manpage))
			tit="$pkg Manual"
		else
			echo "Display all"
			#ar p "$debname" "$datatar" | tar xO"$options" ${manpage[@]} |man /dev/stdin |yad --text-info --height=500 --width=800 --center --title="$pkg All Manuals " --wrap --show-uri --no-markup
			mpg=$(man <(ar p "$debname" "$datatar" | tar xO"$options" ${manpage[@]}))
			tit="$pkg All Manuals"
		fi
	yad --text-info<<<"$mpg" --height=500 --width=800 --center --title="$tit" --wrap --show-uri --no-markup \
	--button="Show Deb":10 \
	--button="gtk-ok":0 \
	--button="gtk-cancel":1
	resp1=$?
	[[ "$resp1" -eq 10 ]] && listdeb || rm -f $debname

}
export -f readmanpage

#-----------------------MAIN PROGRAM----------------------------------#
stop=0
selectpackages "xfce*"
#toremove=()
while [[ $stop -eq 0 ]];do
#selectpackages
case "$installed" in
"Not Installed") 
readarray -t fti < <(apt list "$pattern" |grep -v -e "$exclude1" -e "$exclude2" -e "installed" -e "Listing" |cut -f 1 -d "/");;
"Installed")
readarray -t fti < <(apt list "$pattern" |grep -v "Listing" |grep  "installed" |cut -f1 -d "/");;
"All")
readarray -t fti < <(apt list "$pattern" |grep -v "Listing" |cut -f1 -d "/");;
"All Experimental")
#here the things are a bit different. Get all exprimental packages (either installed or not) that match the pattern provided
readarray -t fti < <(apt list --all-versions "$pattern" |grep -v "Listing" |grep "/experimental" |cut -f1 -d " " |cut -f1 -d ",");;
"Installed vs Experimental")
#here the things are a bit different. Get all experimental pkgs from the --installed list
readarray -t fti < <(apt list --installed --all-versions "$pattern" 2>&1 |grep -v "Listing" |grep "/experimental" |cut -f1 -d " " |cut -f1 -d",");; #we need to cut even for coma to catch the case "experimental,now"
"All Unstable")
readarray -t fti < <(apt list --all-versions "$pattern" |grep -v "Listing" |grep "unstable" |grep -v "testing" |cut -f1 -d " " |cut -f1 -d",");;
"Installed vs Unstable")
readarray -t fti < <(apt list --installed --all-versions "$pattern" |grep -v "Listing" |grep "unstable" |grep -v "testing" |cut -f1 -d " " |cut -f1 -d",");;
esac

IFS=$'\n' 
c=${#fti[@]} # c=number of packages, items in array fti

for (( item=0; item<=$c; item++ )); do
echo "fti[$item] = ${fti[$item]}"
pd+=("${fti[$item]}")
done
aptshow=$(apt show ${pd[@]})
#declare -p aptshow
#echo "$aptshow" |grep "virtual"
#exit
pddescription=$(grep -e "Description:" <<< $aptshow)
#pddescription=$(grep -e "Package:\|Description:\|not a real package" <<< $aptshow)
#declare -p pddescription && set +f && exit
pdsizeDown=$(grep "Download-Size:" <<< $aptshow)
pdsizeInst=$(grep "Installed-Size:" <<< $aptshow)

pdss=($(printf "%s\n" ${pddescription[@]} |cut -f2-3 -d ":"))
pdszd=($(printf "%s\n" ${pdsizeDown[@]} |cut -f2 -d ":"))
pdszi=($(printf "%s\n" ${pdsizeInst[@]} |cut -f2 -d ":"))


:<<newcode
for (( item=0; item<=$c; item++ )); do
echo "fti[$item] = ${fti[$item]}"
aptshow=$(apt show ${fti[$item]})
pddescription=$(grep "Description:" <<< $aptshow)
if [[ $pddescription != "" ]];then 
	pdsizeDown=$(grep "Download-Size:" <<< $aptshow)
	pdsizeInst=$(grep "Installed-Size:" <<< $aptshow)
	pdss+=($(printf "%s\n" ${pddescription[@]} |cut -f2-3 -d ":"))
	pdszd+=($(printf "%s\n" ${pdsizeDown[@]} |cut -f2 -d ":"))
	pdszi+=($(printf "%s\n" ${pdsizeInst[@]} |cut -f2 -d ":"))
else
	pddescription="not available"
	pdsizeDown="not available"
	pdsizeInst="not available"
	pdss+=( "not availble" )
	pdszd+=( "NA" )
	pdszi+=( "NA" )
fi
done
newcode

# To be noted:
# when using apt list a*, virtual packages were also listed.
# As a result, the apt show of virtual packages returns
# Package: abiword-gnome - State: not a real package (virtual)
# PS: run apt show "a*" |grep -i -C20 "State:"
# This has not Description and thus the description array broke.
# But in VM machine , apt version 1.3.1 , apt list is not displaying virtual packages (!), thus this scripts does not break since apt show is called using the pkgs listed by apt-list
# This can be verified by running 'apt list "abi*" ' (abiword-gnome is missing) and also 'apt list -a abiword-gnome' returns nothing.
# apt show abiword-gnome returns: --> Package: abiword-gnome --> State: not a real package (virtual)
# apt --version : apt 1.3.1 (amd64) (ps: it is further upgradable to 1.4~beta3 amd64)
# uname -a : Linux debi64 4.8.0-1-amd64 #1 SMP Debian 4.8.5-1 (2016-10-28) x86_64 GNU/Linux
#
# The behavior of home pc is different i think. To be checked.
# Also mind that in home pc kernel is version 4.7, while on VM we have 4.8.5
# Tip : You can see changelog of any pkg by "apt-get changelog pkg (apt in my case)"
# breaks at apt-spy plg in home pc. 
# At Home pc - apt 1.4-beta 3 - apt show apt-spy returns that it is a virtual package.
# On VBox apt show apt-spy returns correctly description , everything.
# Search term of apt-s* in VBox returns packages apt-show-source, apt-show-versions, apt-spy, apt-src
# As proved, in VBox we don't have apt pinning enabled. All versions are reported by apt policy with priority 500 (stable, testing,sid) and priority 1 for experimental.
# apt various config files exist in /etc/apt/apt.conf.d directory.
# Maybe apt pinning is the conflict , since home pc is restricted to testing and package apt-spy exists only in sid.
# check man apt_preferences for advise in the package pin numbers. Seems that negative numbers are not a good idea.
#
# Package: apt-spy
# Version: 3.2.2-1
# Priority: optional
# Section: admin
# Maintainer: Stefano Canepa <sc@linux.it>
# Installed-Size: 108 kB
# Depends: libc6 (>= 2.3), libcurl3 (>= 7.16.2)
# Download-Size: 29.5 kB
# APT-Sources: http://httpredir.debian.org/debian sid/main amd64 Packages
# Description: writes a sources.list file based on bandwidth tests Parses the list of mirrors downloaded from ftp.debian.org and then based on
# the region specified by the user each of testes mirrors for bandwidth, at the end it writes /etc/apt/sources.list.d/apt-spy.list using the best mirror it found out.


if [ $installed = "All Experimental" -o $installed = "Installed vs Experimental" -o $installed = "All Unstable" -o $installed = "Installed vs Unstable" ]; then
echo "grab versions differently in experimental packages"
pdpolicy=$(grep "^Version:" <<< $aptshow) #get the candidate versions at experimental
#pdpc=($(printf "%s\n" ${pdpolicy[@]} |grep -e "Version:" |awk -F'Version:' '{print $2}')) #candidate
pdpc=($(printf "%s\n" ${pdpolicy[@]} |awk -F'Version:' '{print $2}')) #candidate version stripped

#get installed version
fti2=($(printf "%s\n" ${pd[@]} |cut -f1 -d'/')) #remove the /experimental string from pkg name 
pdpolicy2=$(apt policy ${fti2[@]} |grep -e "Installed:") #apt policy doesnot accept pkg/experimental format
pdpi=($(printf "%s\n" ${pdpolicy2[@]} |grep -e "Installed:" |cut -f4 -d " "))

else
echo "Classic version grab"
pdpolicy=$(apt policy ${pd[@]} |grep -e "Installed:" -e "Candidate:" )
pdpi=($(printf "%s\n" ${pdpolicy[@]} |grep -e "Installed:" |cut -f4 -d " ")) #pdpi=pdpolicy installed
pdpc=($(printf "%s\n" ${pdpolicy[@]} |grep -e "Candidate:" |cut -f4 -d " ")) #pdpc=pdpolicy candidate
fi


#echo "${pdss[@]}"
#exit
list2=($(echo -e "CHKBOX,Package,PkgDescription,Installed, Candidate,DownSize,Installed Size,\n")) #Header Line

for (( pitem=0; pitem<=$c; pitem++ )); do
#Build the list for yad with double quotes and space.
list+=( "FALSE" "${fti[pitem]}" "${pdss[pitem]}" "${pdpi[pitem]}" "${pdpc[pitem]}" "${pdszd[pitem]}" "${pdszi[pitem]}" ) #to be used by yad only - no new lines (\n) allowed by yad list.

list2+=($(echo -e "FALSE,${fti[pitem]},${pdss[pitem]},${pdpi[pitem]},${pdpc[pitem]},${pdszd[pitem]},${pdszi[pitem]},\n"))
# Format of List2 is different. $list for yad has been built in order to be understood by yad = not \n chars inside.
# We could export list to list2 as it was, but will be saved later infiles as one line without \n. 
# It is though strange that if you printf the $list with IFS=$'\n', you get seperate lines for every field change.

done
#printarray ${list[@]}
printf "%s\n" ${list2[@]} # this prints the list2 correctly on terminal but not in file even if you export it at line 154
export LIST3=$(printf "%s\n" ${list2[@]})

toinstall=($(yad --list --title="Files Browser" --no-markup --width=1200 --height=600 --center --checklist \
--select-action 'bash -c "pkgselect %s "' \
--print-column=2 \
--separator="\n" \
--button="Show Deb Pkg":'bash -c "listdeb"' \
--button="Show manual":'bash -c "readmanpage"' \
--button="Save List":'bash -c "savepkglist"' \
--button="Display":'bash -c "pkgdisplay"' \
--button="gtk-ok":0 \
--button="gtk-cancel":1 \
--button="New Selection":10 \
--column="Install":CHK \
--column="File" \
--column="Description" \
--column="Installed" \
--column="Candidate" \
--column="Download Size" \
--column="Installed Size" \
"${list[@]}" ))
#the --checklist option is required by yad in order to print all entries with value of "true". If you ommit this option, only the last entry is printed.
#alternativelly with option --print-all you can print ALL the list including true - false selection of rows

btn=$?
echo "Button Pressed:" $btn
case $btn in 
0) 	
	echo "Package list to be installed"
	printf "%s\n" ${toinstall[@]} #this prints the list correctly.
	aptinstall #call the aptinstall function to install selected packages.
	unset IFS
	unset c pd aptshow pddescription pdsizeDown pdsizeInst pdss pdszd pdszi pdpolicy pdpc 
	unset fti2 pdpolicy2 pdpi pitem list list2 LIST3 toinstall
	# Reset all variables except variables in selectpackages function (pattern, etc)
	# selectpacakges is not called again - previous selections are used. While loop will poll again all the data and thus list will be refreshed.
	;;
1) #Exit. Setting stop=1 while loop ends - script exits.
	stop=1
	unset IFS
	;;
252) #Exit. Setting stop=1 while loop ends - script exits.
	stop=1
	unset IFS
	;;
10) # New Selection
	unset c pd aptshow pddescription pdsizeDown pdsizeInst pdss pdszd pdszi pdpolicy pdpc 
	unset fti2 pdpolicy2 pdpi pitem list list2 LIST3 toinstall IFS
	selectpackages #by not sending an arg to selectpackages, previously values are used.
	# Just unset all variables, and allow the while loop to be repeated
esac	
unset IFS
done
#declare -p removeit
#echo "removeit=${removeit[@]}"
#rm -i ${toremove[@]}
set +f
exit

#To be done:
# You can assign a button to see upgradeble pkgs , you can list them, display them and user to select which pkgs want to upgrade.
# Command apt install --upgrade pkgname works , but pkgname* gets all pkgs (both installed and not installed)
#
# Trick: Get apt list in a regular var - not array
# ass+=$(apt list $1 2>/dev/null |grep -v "Listing" |sed "s#\\n# #g" |cut -d/ -f1);apt show $ass |less
# Since apt list skips the virtual packages , instead of apt show pkg* you can use above command and thus apt show will call only 
# valid packages reported by apt list. I have also an alias for this (aptshowsmart) 
#
# Trick1: the following command asks for a package name , load all pkgs found in a array, and prompts you to install them.
# It also runs as one line in terminal:
# root@debi64:/home/gv/Desktop# read -p "give package name: " pkg;readarray pkgs< <(apt list --upgradable |egrep "^$pkg" |cut -f1 -d'/');echo ${pkgs[@]};for i in ${pkgs[@]};do read -p "press any key to install next package = $i or press s to skip: " ans;if [[ $ans != 's' ]];then apt install -y --upgrade $i;fi;done
# 
# Trick2: The following command gives info about all versions of pkgs, including experimental repo:
# root@debi64:/home/gv/Desktop/PythonTests# apt list --all-versions xfce4* |cut -f1 -d" "
# you can combine with grep experimental to see only pkgs available in experimental repo.
# You then can install a package of a specific varsion using apt install pkg/experimental or apt -t experimental install pkg 
# apt list --all-versions  |grep -v "installed" |grep experimental -> list all not installed files from experimental repo
# apt list --installed --all-versions  |grep experimental -> Find and list experimental versions of all installed files
# apt list --all-versions  |grep experimental -> list experimental versions of all the pkgs (both installed and not installed)
# You can limit the listing like apt list --installed --all-versions xfce* |grep experimental

#
#Trick3: By Running just apt list (no arguments) or apt list --all-versions will give you huge lists of ALL packages (installed and not installed) available in repos.
# You can combine with grep "installed" (or even --installed switch) to see only the installed packages.

# Trick4: You can also see the installed packages using dpkg-query --list instead of apt.
#Moreover you can print the packages in a customized show format:
#root@debi64:/home/gv# dpkg-query -W -f='${binary:Package},${Version},${Architecture},${binary:Summary}\n'
#-W = --show , -F = --showformat. See man dpkg-query for more info
#The comma between fields is printed. You can apply your own dilimiter or you can apply \t,\n,etc.

# You can install the package apt-show-versions and locate all available versions of a package (or more packages)
# For example try this : apt-show-versions -a -r |grep -v "No experimental" |grep experimenta
# -r enables regex to be used (useless in this case but usefull if you combine -r xfce*)
# -a options lists all versions, including experimental.

# One line dependency checker for a given package (similar to apt-cache depends pkgname):
#root@debi64:/home/gv/Desktop/PythonTests# read -p "Package= " a;pkgs=$(apt show $a | grep Depends | awk -F'Depends: ' '{print $2}');IFS=', ';for p in $pkgs; do pkg=$(echo $p |grep -v -e '(' -e ')');if [[ $pkg != '' ]] ;then echo -e "$pkg\c";apt-cache -q policy $pkg |grep 'Installed';fi;done

#You can expanded it in a script and provide also the "Candidate:" version field , or grep the version inside () provided by apt show
# Thus you can have three columns: Required - Installed - Candidate. 
# This is just informational. You do not need to install dependencies seperatelly - will be installed by defaul with apt install pkgname.

# Tips: A lot of yad dialogues work well with pipes.
# For example this works perfectly : apt install geany |yad --text-info (it does not work with simple --text)


# apt full-upgrade >fullupgrade.txt
# cp fullupgrade.txt fullupgradenice.txt
# sed -n '/upgraded/,$p' fullupgradenice.txt >fullupgradenice2.txt
# geany fullupgradenice2.txt &
# cat fullupgradenice2.txt |tr "\n" " " >fullupgradenice3.txt
# cat fullupgradenice3.txt |sed -e 's/   / /g' >fullupgradenice4.txt
# pattern=$(cat fullupgradenice4.txt);apt list $pattern >fullupgradepkgs.list #wait for apt list to finish... needs time
# cat fullupgradepkgs.list |grep -v "testing" -> should give you only /stable packages and not unstable.
