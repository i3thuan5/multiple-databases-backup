#!/bin/bash
exit_code=0
shellcheck --severity=info scripts/*;
tsitkai="$?"
exit_code=$(( tsitkai != 0 ? tsitkai : exit_code))
while IFS= read -r -d '' file
do
    shellcheck --severity=info "$file";
    tsitkai="$?"
    exit_code=$(( tsitkai != 0 ? tsitkai : exit_code))
done <   <(find . -type f -name '*.sh' -not -path './venv/*' -not -path './scripts/*' -print0)
exit $(( exit_code == 0 ? 0 : 1))
