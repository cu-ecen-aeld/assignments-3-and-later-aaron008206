#!/bin/bash

if [ -f ./conf/assignment.txt ]; then
    # This is just one example of how you could find an associated assignment
    assignment=`cat ./conf/assignment.txt`
    if [ -f ./assignment-autotest/test/${assignment}/assignment-test.sh ]; then
        echo "Executing assignment test script"
        ./assignment-autotest/test/${assignment}/assignment-test.sh $test_dir
        rc=$?
        if [ $rc -eq 0 ]; then
            echo "Test of assignment ${assignment} complete with success"
        else
            echo "Test of assignment ${assignment} failed with rc=${rc}"
            exit $rc
        fi
    else
        echo "No assignment-test script found for ${assignment}"
        exit 1
    fi
else
    echo "Missing ./conf/assignment.txt, no assignment to run"
    exit 1
fi
