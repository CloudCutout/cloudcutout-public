#!/bin/bash
TOKEN=
QUEUE=demo
URL=https://api.cloudcutout.com/cloudcutout-workflow-job-service/rest
TODO=$1
DONE=$2

unamestr=$(uname)
if [[ "$unamestr" == 'Linux' ]]; then
	FILES=$(find $TODO -regextype posix-extended -iregex ".*\.(jpg|gif|png|jpeg)")
elif [[ "$unamestr" == 'Darwin' ]]; then
	FILES=$(find -E $TODO -iregex ".*\.(jpg|gif|png|jpeg)")
fi

for f in $FILES
do
	path=${f%/*} 
	base=${f##*/}
	pref=${base%.*}
	db=${path}/.$pref
	touch $db
	state=($(cat $db))
	id=${state[0]}
	status=${state[1]}

	if [ "${id}" = '' ]; then
		id=$(curl -w '' -s -k -F "file=@$f" -X POST "${URL}/queue/${QUEUE}/todo?token=${TOKEN}&filename=$base")
		if [ $? -eq 0 ]; then
			echo $id > $db
		else
			echo "Upload failed"
		fi	
	else
		status=$(curl -w '' -s -k -X GET "${URL}/queue/${QUEUE}/${id}/status?token=${TOKEN}")
		if [ $? -eq 0 ]; then
			echo $id > $db
			echo $status >> $db
		else
			echo "Status update failed"
		fi
		if [ "${status}" = 'ok' ]; then
			url=$(curl -w '' -s -k -X GET "${URL}/queue/${QUEUE}/${id}?token=${TOKEN}")
			if [ $? -eq 0 ]; then
				ext=${url%\?*}
				ext=${ext##*.}
				output=$DONE/${f#$TODO}
				output=${output%.*}.${ext}
				mkdir -p $DONE/${path#$TODO}
				wget ${url} -O $output
				if [ $? -eq 0 ]; then
					rm $db
					rm $f
				else
					echo "Download failed"
				fi
			else
				echo "URL download failed"
			fi
		fi
	fi
	echo "$f : $base : $id : $status"
done
