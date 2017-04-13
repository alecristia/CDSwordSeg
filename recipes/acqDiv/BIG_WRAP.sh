# take out input from rda file

# Adapt the following variables, being careful to provide absolute paths
ROOT="/Users/bootphonproject/Desktop/segmentation/scripts"	#path to the CDSwordSeg folder - E.g. PATH_TO_SCRIPTS="/home/xcao/cao/projects/ANR_Alex/CDSwordSeg/"
INPUT_FILE="/Users/bootphonproject/Desktop/segmentation/acqdiv_corpus_2016-09-22_ctn_jap.rda" #E.g INPUT_FILES="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/childes_info.txt"
PROCESSED_FILE="/Users/bootphonproject/Desktop/segmentation/results/chintang/clean_corpus.txt"	#this is where we will put the processed versions of the transcripts E.g. RES_FOLDER="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/" - NOTICE THE / AT THE END OF THE NAME
PROCESSED_FILE2="/Users/bootphonproject/Desktop/segmentation/results/chintang/clean_corpus-tags.txt"
LANGUAGE="chintang"
RESULT_FOLDER="/Users/bootphonproject/Desktop/segmentation/results/chintang/"


#module add festival
#module add python-anaconda

mkdir -p $RES_FOLDER	
#R CMD BATCH $ROOT/1.sel_clean.R   
#echo "done extracting info from corpora"

bash 2.phonologize.sh $LANGUAGE $ROOT $RESULT_FOLDER
echo "done phonologisation and syllabification of corpora"

#python $ROOT/4a.format_TP.py $PROCESSED_FILE2
#python $ROOT/4b.TPsegmentation.py $RESULT_FOLDER/syllableboundaries_marked.txt $RESULT_FOLDER/outputREL.txt
#echo "done TP segmentation"


export LC_CTYPE="C"


PIPELINE="/Users/bootphonproject/Downloads/CDSwordSeg-master-2/algoComp/segment.py"
GOLD=`echo $PROCESSED_FILE2 | sed 's/tags/gold/' `
        $PIPELINE $PROCESSED_FILE2 \
                --goldfile $GOLD \
                --output-dir $RESULT_FOLDER/ \
                --algorithms dibs TPs \
                #  --clusterize \
               #   --jobs-basename $VERSION \
              #    --ag-median 5 \
          #  || exit 1


#python 5.evalGold.py -g $RESULT_FOLDER/corpus-gold.txt < $RESULT_FOLDER/outputREL.txt \ > $RESULT_FOLDER/cfgold-res.txt
#echo "done evaluation"
