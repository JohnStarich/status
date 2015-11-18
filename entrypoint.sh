#!/bin/bash -e

BASE_DIR=/var/www/html
SERVICES_FILE=$BASE_DIR/services.json
TMP_FILE=$BASE_DIR

if [ -t 0 ]; then
	# stdin is a tty, process command line
	if [ "$1" ]; then
		# if a file name was provided, move it to services.json
		if [ -f "$1" ]; then
			TMP_FILE="$1"
		elif [ -f "$BASE_DIR/$1" ]; then
			TMP_FILE="$BASE_DIR/$1"
		else
			echo "Error: Provided file with name '$1' could not be found." >&2
			echo "Usage: entrypoint.sh <file_name>" >&2
			echo "    or cat <file_name> | entrypoint.sh" >&2
			exit 2
		fi
		echo "Copying contents of $TMP_FILE to $SERVICES_FILE"
		mv $TMP_FILE $SERVICES_FILE
	fi
else
	echo 'Reading Service file from stdin.'
	# stdin is not a tty, process standard input
	echo '' > $SERVICES_FILE
	while read -r LINE || [[ -n $LINE ]]; do
		# put stdin contents into services.json
		echo "$LINE" >> $SERVICES_FILE
	done
fi

apache2-foreground
