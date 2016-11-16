
algos=$1
for algo in $algos
do
for i in {0..9}
do 
#python segment.py --algorithms $algo -d res-sub-bern-ADS/sub$i -g ../recipes/bernstein/data_06_10/ADS/subphono/sub$i/sub_gold_bernstein_ADS_$i.txt ../recipes/bernstein/data_06_10/ADS/subphono/sub$i/sub_bernstein_ADS_$i.txt
python segment.py --algorithms $algo -d res-sub-bern-CDS/sub$i -g ../recipes/bernstein/data_06_10/CDS/sub$i/gold.txt ../recipes/bernstein/data_06_10/CDS/sub$i/tags.txt
echo sub $i done
done
echo algo $algo done
done
