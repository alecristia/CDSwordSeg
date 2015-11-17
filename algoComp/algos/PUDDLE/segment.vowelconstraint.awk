# Code shared by Padraic Monaghan
# If considering reusing this code, please contact him at p.monaghan@lancaster.ac.uk
# this is a version used in the following publication:
# Monaghan, P., & Christiansen, M. H. (2010). Words in puddles of sound: modelling psycholinguistic effects in speech segmentation. Journal of child language, 37(03), 545-564.


# do "we" want to search for chunks biggest first or smallest first?
# eg if utterances are "uhoh oh uhoh", then uhoh, oh get stored as chunks, then do we want 2nd uhoh to remain as a chunk or be divided into uh and oh?
# can sort chunks for length, age of acquisition or activation.
#
# at the moment this model does it according to activation
#
# assuming input is sequence of phonemes, each line is one utterance
#
# this model has constraint of biphones ending and finishing word
# AND constraint of word boundary not being across word internal biphone

function vowel(vow){
  if(vow~/aa/ || vow~/ae/ || vow~/ah/ || vow~/ao/ || vow~/aw/ || vow~/ax/ || vow~/ay/ || vow~/eh/ || vow~/er/ || vow~/ey/ || vow~/ih/ || vow~/iy/ || vow~/ow/ || vow~/oy/ || vow~/uh/ || vow~/uw/ ) return 1;
  else return 0;
}


BEGIN{
  c=0;
  bec=0;bbc=0;bic=0;

  ## sort by length then by frequency, longest first:
  command = "sort -k 3,3nr -k 2,2nr";

  ##for sort by frequency use this:
  #command = "sort -k 2,2nr";
}
{
  printf $0 " : ";


  # w[i] is word chunk i
  # c is number of word chunks

  # go through current utterance segment by segment:
  if(NF>0){

    buffer="";
    for(i=1;i<=length($1);i++){
      ##print NR,i,substr($1,i,1);
      
      # search for matcher beginning with first segment:
      matcher=0;
      for(j=1;j<=c && matcher==0;j++){

	if(substr($1,i,length(w[j]))== w[j])matcher++;

	####### boundary conditions satisfied?
	if(matcher==1 && (bef[substr(buffer,length(buffer)-1,2)]==0 && buffer!="" && i!=1)) matcher=0; # previous must be word-end
	if(matcher==1 && (bbf[substr($1,i+length(w[j]),2)]==0 && (i+length(w[j])-1!=length($1))) )matcher=0; # following must be word-start

	####### glue condition satisfied?
	#if(matcher==1 && bif[substr(buffer,length(buffer),1) substr($1,i,1)]>0 && buffer!="") matcher = 0; # word-internal across initial boundary
	#if(matcher==1 && bif[substr($1,i+length(w[j])-1,2)]>0) matcher = 0; # word-internal across final boundary
	
	###### vowel constraint satisfied?
	if(matcher==1 && (( vowel(buffer)==0 && length(buffer)>0 ) || ( vowel(substr($1,i+length(w[j]),length($1)-i-length(w[j])+1))==0 && (length($1)-i-length(w[j])+1)>0))) matcher=0;

        ####### got a match, so update words and biphones
	if(matcher==1){ 
	  ##print "matcher";
	  if(buffer>0){ # if there's anything in buffer add it to chunks:
	    ##print "newchunk:", buffer;
	    c++;
	    w[c]=buffer;
	    f[c]=1;

	    # add to boundaries
	    if(length(buffer)>=2){
	      bbf[substr(buffer,1,2)]++;
	      if(bbf[substr(buffer,1,2)]==1){bbc++;bb[bbc]=substr(buffer,1,2);}
	      bef[substr(buffer,length(buffer)-1,2)]++;
	      if(bef[substr(buffer,length(buffer)-1,2)]==1){bec++;be[bec]=substr(buffer,length(buffer)-1,2);}
	    }
            # add to glue
	    for(k=1;k<length(buffer);k++){
	      bif[substr(buffer,k,2)]++;
	      if(bif[substr(buffer,k,2)]==1){bic++;bi[bic]=substr(buffer,k,2);}
	    }
	  
	    printf buffer " ;aword ";    # REAL OUTPUT
	  }
	  buffer = ""; # empty buffer
	  f[j]++; # add to frequency of chunk
	  i+=length(w[j]); #advance in chunk

          # add to boundaries
	  if(length(w[j])>=2){
	    bbf[substr(w[j],1,2)]++;
	    if(bbf[substr(w[j],1,2)]==1){bbc++;bb[bbc]=substr(w[j],1,2);}
	    bef[substr(w[j],length(w[j])-1,2)]++;
	    if(bef[substr(w[j],length(w[j])-1,2)]==1){bec++;be[bec]=substr(w[j],length(w[j])-1,2);}
	  }
            # add to glue
	  for(k=1;k<length(w[j]);k++){
	    bif[substr(w[j],k,2)]++;
	    if(bif[substr(w[j],k,2)]==1){bic++;bi[bic]=substr(w[j],k,2);}
	  }

	  printf w[j] " ;aword ";     # REAL OUTPUT
	  i--;
	}
      }
      if(matcher==0){
	##print "no matcher. current buffer:",buffer;
	buffer= buffer substr($1,i,1); # add segment to buffer
	##print "new buffer:",buffer;
	##print "c: ", c;
      }
    }

    if(length(buffer)>0){ # if got to end and there's something in buffer:
      c++;
      w[c]=buffer;
      f[c]=1;

      # add to boundaries
      if(length(w[c])>=2){
	bbf[substr(w[c],1,2)]++;
	if(bbf[substr(w[c],1,2)]==1){bbc++;bb[bbc]=substr(w[c],1,2);}
	bef[substr(w[c],length(w[c])-1,2)]++;
	if(bef[substr(w[c],length(w[c])-1,2)]==1){bec++;be[bec]=substr(w[c],length(w[c])-1,2);}
      }
      # add to glue
      for(k=1;k<length(w[c]);k++){
	bif[substr(w[c],k,2)]++;
	if(bif[substr(w[c],k,2)]==1){bic++;bi[bic]=substr(w[c],k,2);}
      }

      ##print "if got to end without segmenting... new buffer:",buffer; 
      printf buffer " ;aword ";   REAL OUTPUT
      buffer = "";
    }
  }
  printf "\n";

  # apply decay to words
  decay = 0;
  ##print "applying decay";
  for(i=1;i<=c;i++){
    f[i]-=decay;
    if(f[i]<=decay/2)f[i]=0;
  }

  cc=0;
  # remove chunks that have fallen out.
  for(i=1;i<=c;i++){
    if(f[i]>0){
      cc++;
      f[cc]=f[i];
      w[cc]=w[i];
    }
  }
  c = cc;

  # sort chunks according to their frequency:

  for(i=1;i<=c;i++) print w[i],f[i],length(w[i]) |& command;
  close(command,"to");
  for(i=1;i<=c;i++){
    command |& getline b[i];
    split(b[i], temp, " ");
    w[i]=temp[1];f[i]=temp[2];
  }
  close(command);

  # apply decay to beginnings
  for(i=1;i<=bbc;i++){
    bbf[bb[i]]-=decay;
    if(bbf[bb[i]]<=decay/2)bbf[bb[i]]=0;
  }
  bbcc=0;
  # remove begs that have fallen out.
  for(i=1;i<=bbc;i++){
    if(bbf[bb[i]]>0){
      bbcc++;
      bb[bbcc]=bb[i];
    }
  }
  bbc = bbcc;

  # apply decay to endings
  for(i=1;i<=bec;i++){
    bef[be[i]]-=decay;
    if(bef[be[i]]<=decay/2)bef[be[i]]=0;
  }
  becc=0;
  for(i=1;i<=bec;i++){
    if(bef[be[i]]>0){
      becc++;
      be[becc]=be[i];
    }
  }
  bec = becc;

  # apply decay to glue
  for(i=1;i<=bic;i++){
    bif[bi[i]]-=decay;
    if(bif[bi[i]]<=decay/2)bif[bi[i]]=0;
  }
  bicc=0;
  for(i=1;i<=bic;i++){
    if(bif[bi[i]]>0){
      bicc++;
      bi[bicc]=bi[i];
    }
  }
  bic = bicc;


  if(NR%100000==0){
     print wordchunks
    print "printing wordchunks...";
    for(i=1;i<=c;i++){
      print "\tw",w[i],f[i];
    }
    # print biphones
    print "printing beginning biphones...";
    for(i=1;i<=bbc;i++){
      print "\t\tbb",bb[i],bbf[bb[i]];
    }
    print "printing ending biphones...";
    for(i=1;i<=bec;i++){
      print "\t\tbe",be[i],bef[be[i]];
    }
    print "printing glue...";
    for(i=1;i<=bic;i++){
      print "\t\tbi",bi[i],bif[bi[i]];
    }
  }
}




