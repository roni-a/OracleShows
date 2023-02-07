#!/bin/awk -f
# concatante multi lines into one line
# /\\bibitem/ {for (i=1;i<nu;i++){printf "%s",string[i]}

{nu++;string[nu]=$0} 
 /\\ / {for (i=1;i<nu;i++){printf "%s",string[i]}
     printf "\n%s",string[nu];nu=0}
 END{for (i=1;i<=nu;i++){printf "%s",string[i]}
                                        printf "\n"}

