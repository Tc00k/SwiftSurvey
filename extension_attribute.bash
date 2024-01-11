#!/bin/sh

RESULT="happy"

if [ -f "/private/var/sadface.txt" ] ; then
	RESULT="sad"
fi

echo "<result>$RESULT</result>"