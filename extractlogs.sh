#########################################################################################################
# 		This script is used to copy log files from a specified server environment and archive them 		#
#########################################################################################################

#--------------------------------------------------------------------------------------------------------
#File Name 	:	extractlogs.sh
#Version 	:	1.6
#Author		:	Ihsan Izwer 
#--------------------------------------------------------------------------------------------------------

ocounter=0
acounter=1
typearr=()

clear
if [ $# -lt 3 ];then
		echo "Missing or invalid arguments. Usage : ./extractlogs.sh <env_name> <date in YYYY/MM/DD format> <space seperated log file names>"
		echo "Example : ./extractlogs.sh dev 2016/11/11 Gateway1 Market21"
		exit 1
	fi

envname=$1
reqdate=$2

for args in $@
	do
		if [ $acounter -ge 3 ];then
			typearr+=($args)
		fi
		((acounter++))
	done

case ${reqdate} in
	[2-9][0-9][0-9][0-9]/[0-1][0-9]/[0-3][0-9])
		ryear=`echo $reqdate | cut -d'/' -f1`
		rmonth=`echo $reqdate | cut -d'/' -f2`
		rday=`echo $reqdate | cut -d'/' -f3`
		if [ $rmonth -gt 12 ];then
			echo "Invalid start date. Please retype again"
			exit 1
		elif [ $rmonth -le 0 ];then
			echo "Invalid start date. Please retype again"
			exit 1
		fi
		if [ $rday -gt 31 ];then
			echo "Invalid start date. Please retype again"
			exit 1
		elif [ $rday -le 0 ];then
			echo "Invalid start date. Please retype again"
			exit 1
		fi
		;;
	*)
		echo "Invalid date. Please retype again";;
esac
reqdate=${ryear}/${rmonth}/${rday}
echo "The date you entered is $reqdate"

#Absolute Path to the log files. Change or add as needed.
	
	dev_logs_path=/x01/uat2/archived_logs/${ryear}${rmonth}${rday}/uat2/logs/15.192.56.*/
	dev2_logs_path=/u01/dev2/archived_logs/${ryear}${rmonth}${rday}/logs/12.129.96.30/
	uat_logs_path=/u01/uat/archived_logs/${ryear}${rmonth}${rday}/uat/logs/12.129.86.*/
	uat2_logs_path=/x01/uat2/archived_logs/${ryear}${rmonth}${rday}/uat2/logs/12.129.86.*/
	prod_logs_path=/x01/prod/archived_logs/${ryear}${rmonth}${rday}/*/logs/12.129.88.*/
	test_logs_path=/u01/uat/archived_logs/${ryear}${rmonth}${rday}/uat/logs/15.192.56.*/

#Change Server/Environment names as needed for the company
count=0
for valenv in 'dev' 'dev2' 'uat' 'uat2' 'prod' 'test'
do
	if [ $envname = $valenv ];then
		break
	fi
	((count++))
done

if [ $count -eq 6 ]; then
	echo "Invalid environment specified. Please reenter the correct environment."
	exit 1
fi

tarname=${envname}${ryear}${rmonth}${rday}
destfolder=${tarname}

if [ -f $destfolder ] || [ -d $destfolder ] ;then
	rm -rf $destfolder
	rm -rf ${destfolder}.tar.gz
fi

mkdir $destfolder

echo "----------------------------------------------------------------------------------------------"
echo "Copy following logs: ${typearr[@]} from $envname  to $destfolder ? Enter y/n"
echo "----------------------------------------------------------------------------------------------"
read status

#Change the vairable names of server environments in the case and the cp statements below as required
if [ $status = 'y' ];then
	case $envname in 
	dev)
		for currenttype in ${typearr[@]}
		do
			cp ${dev_logs_path}/*${currenttype}* $destfolder
			echo "copied $currenttype log files to $destfolder"
		done
	;;
	dev2)
		for currenttype in ${typearr[@]}
		do
			cp ${dev2_logs_path}/*${currenttype}* $destfolder
			echo "copied $currenttype log files to $destfolder"
		done
	;;
	uat)
		for currenttype in ${typearr[@]}
		do
			cp ${uat_logs_path}/*${currenttype}* $destfolder
			echo "copied $currenttype log files to $destfolder"
		done
	;;
	uat2)
		for currenttype in ${typearr[@]}
		do
			cp ${uat2_logs_path}/*${currenttype}* $destfolder
			echo "copied $currenttype log files to $destfolder"
		done
	;;
	prod)
		for currenttype in ${typearr[@]}
		do
			cp ${prod_logs_path}/*${currenttype}* $destfolder
			echo "copied $currenttype log files to $destfolder"
		done
	;;
	test)
		for currenttype in ${typearr[@]}
		do
			cp ${test_logs_path}/*${currenttype}* $destfolder
			echo "copied $currenttype log files to $destfolder"
		done
	;;
	esac
	else
	exit
fi


tar -cvf ${tarname}.tar $destfolder
echo "Tarfile created."
gzip -9 ${tarname}.tar
echo "--------------------------------------------------------------------------------------"
echo "Following are the content of the compressed Directory"
echo "--------------------------------------------------------------------------------------"
ls -lrth $destfolder
echo "--------------------------------------------------------------------------------------"
echo "Task Complete!"
exit 