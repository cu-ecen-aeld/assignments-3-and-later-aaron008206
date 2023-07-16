#!/bin/bash

export CROSS_COMPILE=aarch64-none-linux-gnu-
mkdir -p ../assignments/assignments2
file01="../assignments/assignments2/cross_compile.txt"
file02="../assignments/assignments2/fileresult.txt"
#compile_path="../assignments/assignments2/cross_compile.txt"

# writing a report of cross-compiler information
echo -e "# cross-compiler \n${CROSS_COMPILE}gcc" > ${file01}
echo -e "\n# target libraries directory" >> ${file01}
${CROSS_COMPILE}gcc -print-sysroot >> ${file01}
echo -e "\n# programs invoked by the compiler" >> ${file01}
${COSS_COMPILE}gcc -v 2>> ${file01}

# writing a report of a cross-compiled file property
make CROSS_COMPILE=aarch64-none-linux-gnu-
echo -e "# property of cross-compiled file" > ${file02}
file writer >> ${file02}
make clean
