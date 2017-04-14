ROOT="../../"	#path to the CDSwordSeg folder - E.g. PATH_TO_SCRIPTS="/home/xcao/cao/projects/ANR_Alex/CDSwordSeg/"
INPUT_FOLDER="../../../acqDivVisible/data/" #FOLDER containing all the versions of the acqdiv corpus -- please remember to mount it before running this script

#module add python-anaconda

for LANGUAGE in Japanese Chintang
do

RESULT_FOLDER="../../../acqDivVisible/results/$LANGUAGE/" #this is where we will put the processed versions of the transcripts E.g. RES_FOLDER="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/" - NOTICE THE / AT THE END OF THE NAME
PROCESSED_FILE="/../../results_acqdiv/$LANGUAGE/clean_corpus.txt"	
PROCESSED_FILE2="/../../results_acqdiv/$LANGUAGE/clean_corpus-tags.txt"


export LC_CTYPE="C"

bash 2.phonologize.sh $LANGUAGE $ROOT $RESULT_FOLDER
echo "done phonologisation and syllabification of corpora"



PIPELINE="/Users/bootphonproject/Downloads/CDSwordSeg-master-2/algoComp/segment.py"
GOLD=`echo $PROCESSED_FILE2 | sed 's/tags/gold/' `
        $PIPELINE $PROCESSED_FILE2 \
                --goldfile $GOLD \
                --output-dir $RESULT_FOLDER/ \
                --algorithms dibs TPs \
                  --clusterize \
               #   --jobs-basename $VERSION \
              #    --ag-median 5 \
          #  || exit 1

done

echo "done segmentation for chintang and japanese"
