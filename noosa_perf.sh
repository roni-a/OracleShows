# -------------------------------------------
ShowCPU () {
echo
echo "procs                      memory      swap          io    system       cpu"
echo " r  b   swpd   free   buff  cache   si   so    bi    bo   in     cs us sy id wa"
echo "== == ====== ====== ====== ======= ==== ==== ===== ===== ==== ===== == == == =="
i=5
while [ $i -gt 0 ]
do
vmstat 1 2 | egrep -v "^procs|^ r" | tail -1
sleep 3
let "i = i - 1"
done
}

# -------------------------------------------
ShowDSK () {
echo
echo "Device:    rrqm/s wrqm/s   r/s   w/s  rsec/s  wsec/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util"
echo "------ ---------- ------ ----- ----- ------- ------- -------- -------- -------- -------- ------- ------ ------"
i=5
while [ $i -gt 0 ]
do
iostat -x 1 2 | grep sdb | tail -1
sleep 3
let "i = i - 1"
done
}

# -------------------------------------------
#
AllStats () {
echo
i=5
while [ $i -gt 0 ]
do
echo "procs                      memory      swap          io    system       cpu"
echo " r  b   swpd   free   buff  cache   si   so    bi    bo   in     cs us sy id wa"
echo "== == ====== ====== ====== ======= ==== ==== ===== ===== ==== ===== == == == =="
vmstat 1 2 | egrep -v "^procs|^ r" | tail -1

echo
echo "Device:    rrqm/s wrqm/s   r/s   w/s  rsec/s  wsec/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util"
echo "------ ---------- ------ ----- ----- ------- ------- -------- -------- -------- -------- ------- ------ ------"
iostat -x 1 2 | grep sdb | tail -1
echo
sleep 3
let "i = i - 1"
done
}

# -----------------------------------------------------
# UsingTop
#------------------------------------------------------
UsingTop () {
   printf '\n%s\n' "CPU states:  cpu    user    nice  system    irq  softirq  iowait    idle"
   printf '%s\n'   "            ---- ------- ------- ------- ------ -------- ------- -------"
   top -b n 1 | \egrep "\Mem:|Swap|total|actv,"
   printf '%s\n\n' "------------------------------------------------------------------------"
}

# M A I N
# -------------------------------------------

case $1 in
   top ) UsingTop ;;
   cpu ) ShowCPU ;;
   dsk ) ShowDSK ;;
   *   ) AllStats ;;
esac


