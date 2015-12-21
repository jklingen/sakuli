#!/bin/bash

/root/scripts/vnc_startup.sh

# argument of sakuli.sh start with a dash.
# If not, assume that CMD was not meant as an argument
# for sakuli.sh (=ENTRYPOINT). Hence, try to execute CMD standalone.
if [ "${1:0:1}" == "-" ]; then
        i=$(eval echo $*)
        $SAKULI_HOME/bin/sakuli.sh $i
else
        exec $1
fi

res=$?
echo "SAKULI_RETURN_VAL: $res"

# modify $SAKULI_TEST_SUITE permissions to ensure, that volume-mounted log files can be deleted afterwards
chmod -R a+rw $SAKULI_TEST_SUITE

exit $res
