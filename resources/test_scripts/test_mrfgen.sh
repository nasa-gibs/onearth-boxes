#!/bin/sh

cd /home/onearth/gibs-onearth-test-area/src/mrfgen

# Run test and pipe output to temp file
./test_mrfgen.py >> /home/onearth/resources/test_scripts/test_results/mrfgen_error_log 3>&1 1>&2 2>&3

if [ "$?" != "0" ]
then
	echo "Test didn't pass! Check mrfgen_error_log for details."
else
	echo "Test passed!"
	rm /home/onearth/resources/test_scripts/test_results/mrfgen_error_log
fi
