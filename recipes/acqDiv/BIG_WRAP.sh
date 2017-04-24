ACQDIV_FOLDER="../../../acqDivVisible/" #FOLDER containing all the versions of the acqdiv corpus -- please remember to mount it before running this script

#module add python-anaconda
#export LC_CTYPE="C"

for LANGUAGE in japanese chintang
do


./1-phonologize.sh $LANGUAGE "../../phonologization/" $ACQDIV_FOLDER
echo "done phonologisation and syllabification of corpora"


./2-segment.sh $LANGUAGE  "../../algoComp/segment.py" $ACQDIV_FOLDER
echo "done segmentation for chintang and japanese"

done
