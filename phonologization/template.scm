;; ;; First define a new Utterance type for phonologization
;; (defUttType Syllable
;;   (Initialize utt)
;;   (Text utt)
;;   (Token utt)
;;   (POS utt)
;;   (Phrasify utt)
;;   (Word utt)
;;   (Intonation utt)
;;   (Duration utt)
;;   (Int_Targets utt)
;;   ;(Wave_Synth utt)
;;   )
;; ;(pprintf UttTypes)


(define (phonologize line)
  "(phonologize LINE)
Extract the phonemes of the string LINE as a tree an write it to stdout."
  (set! utterance (eval (list 'Utterance 'Text line)))
  (utt.synth utterance)
  ;; Use of print instead of pprintf to have each utterance on one line
  (print (utt.relation_tree utterance "SylStructure")))


;; This double braket have to be replaced by the name of the text file
;; you want to read data from. To be parsed by festival as a unique
;; utterance, each line of that file must begin and end with
;; double-quotes.
(set! lines (load "{}" t))
(mapcar (lambda (line) (phonologize line)) lines)
