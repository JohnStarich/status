#!/bin/bash -e

BASE_DIR=/var/www/html
SERVICES_FILE=$BASE_DIR/services.json
TMP_FILE=$BASE_DIR

CMD="$1"
ARG="$2"

function print_usage() {
	echo "Usages:" >&2
	echo "    entrypoint.sh file [file_name]" >&2
	echo "    entrypoint.sh json [json_string]" >&2
	echo "    entrypoint.sh stdin < [file_name]" >&2
}

if [ -f $SERVICES_FILE ]; then
	echo 'Services file was found.' >&2
	echo 'Starting up with services.json' >&2
elif [[ $CMD == 'file' ]]; then
	echo 'Reading services file from file location.' >&2
	if [ $ARG ]; then
		# if a file name was provided, move it to services.json
		if [ -f $ARG ]; then
			TMP_FILE=$ARG
		elif [ -f "$BASE_DIR/$ARG" ]; then
			TMP_FILE="$BASE_DIR/$ARG"
		else
			echo "Error: Provided file with name '$ARG' could not be found." >&2
			print_usage
			exit 2
		fi
		echo "Copying contents of $TMP_FILE to $SERVICES_FILE"
		mv $TMP_FILE $SERVICES_FILE
	fi
elif [[ $CMD == 'json' ]]; then
	echo 'Writing json string to services file.' >&2
	echo $ARG > $SERVICES_FILE
elif [[ $CMD == 'stdin' ]]; then
	echo 'Reading services file from stdin.' >&2
	# stdin is not a tty, process standard input
	rm -f $SERVICES_FILE
	while read -r LINE || [[ -n $LINE ]]; do
		# put stdin contents into services.json
		echo "$LINE" >> $SERVICES_FILE
	done
else
	echo "Error: Invalid command '$CMD'" >&2
	print_usage
	exit 2
fi

apache2-foreground
