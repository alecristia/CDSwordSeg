algos=$1
#folder_res=$2
for algo in $algos
do
for i in {0..9}
do
cd /fhgfs/bootphon/scratch/elarsen/CDSwordSeg/algoComp/res-sub-bern-ADS/sub$i
rm -rf $algo
ls
echo delete folder $algo in sub $i  done
done
echo deletion done
done

