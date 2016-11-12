# color variables
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_RESET='\033[0m'

# enter test directory
pushd ./test > /dev/null

# clean actual and result directory and recreate
rm -rf actual result
mkdir actual result

processTexFile() {
  printf "Processing '%s'\n" "${1}";
  pdflatex -output-directory actual "${1}" > /dev/null 2>&1
  if [ "$?" == 0 ]; then
    printf "Processing of '%s' finished\n" "${1}";
  else
    printf "%bProcessing of '%s' failed%b\n" "${C_RED}" "${1}" "${C_RESET}";
  fi
}

# run pdflatex on all files ending with ".tex" and output to folder actual
for file in *.tex; do
  (processTexFile "${file}")& # run i parallel
done;

# wait for all pdflatex children
wait

# if expected folder exist compare to actual
if [ ! -d "./expected" ]; then
  printf "Missing expected directory, can not compare\n";
  exit 1;
else
  pushd expected > /dev/null
  for file in *.pdf; do
    # make sure the actual version exist
    if [ ! -f "../actual/${file}" ]; then
      printf "%bTest '%s' is missing%b\n" "${C_RED}" "${file}" "${C_RESET}";
    else
      diff-pdf --output-diff="../result/${file}" "${file}" "../actual/${file}";
      # if actual is equal to expected (exit code == 0) rm result file
      if [ "$?" == 0 ]; then
        rm "../result/${file}";
        printf "%bTest '%s' succeeded%b\n" "${C_GREEN}" "${file}" "${C_RESET}";
      else
        printf "%bTest '%s' failed%b\n" "${C_RED}" "${file}" "${C_RESET}";
      fi
    fi
  done
  popd > /dev/null
fi

# return from test directory
popd > /dev/null
