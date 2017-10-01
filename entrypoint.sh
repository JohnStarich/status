#!/bin/bash -e

BASE_DIR=/var/www/html
SERVICES_FILE=$BASE_DIR/services.json
TMP_FILE=$BASE_DIR

CMD="$1"
ARG="$2"

function print_usage() {
	cat >&2 <<EOT
Usage:
    johnstarich/status file FILE_NAME
    johnstarich/status json JSON_STRING
    johnstarich/status stdin < FILE_NAME
EOT
}

function error() {
    echo "$*" >&2
}

if [[ "$CMD" == 'file' ]]; then
	error 'Reading services file from file location.'
	if [[ -n "$ARG" ]]; then
		# if a file name was provided, move it to services.json
		if [[ -f "$ARG" ]]; then
			TMP_FILE=$ARG
		elif [[ -f "$BASE_DIR/$ARG" ]]; then
			TMP_FILE="$BASE_DIR/$ARG"
		else
			error "Error: Provided file with name '$ARG' could not be found."
			print_usage
			exit 2
		fi
		echo "Copying contents of $TMP_FILE to $SERVICES_FILE"
		mv "$TMP_FILE" "$SERVICES_FILE"
	fi
elif [[ "$CMD" == 'json' ]]; then
	error 'Writing json string to services file.'
	echo "$ARG" > "$SERVICES_FILE"
elif [[ "$CMD" == 'stdin' ]]; then
	error 'Reading services file from stdin.'
	# stdin is not a tty, process standard input
	rm -f "$SERVICES_FILE"
	while read -r line || [[ -n "$line" ]]; do
		# put stdin contents into services.json
		echo "$line" >> "$SERVICES_FILE"
	done
else
	error "Error: Invalid command '$CMD'"
	print_usage
	exit 2
fi

apache2-foreground
