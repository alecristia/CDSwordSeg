#include "Scoring.h"

#include <string>


void Scoring::reset()
{
    _sentences = 0;
    _words_correct = 0;
    _segmented_words = 0;
    _reference_words = 0;
    _bs_correct = 0;
    _segmented_bs = 0;
    _reference_bs = 0;
    _reference_lex.clear();
    _segmented_lex.clear();
}

void Scoring::add_words_to_lexicon(const Sentence::Words& words, Lexicon& lex)
{
    for(const auto& word: words)
        lex.inc(word);
}

void Scoring::print_results(std::wostream& os) const
{
    os.precision(4);
    os << "P " << 100*precision()
       << " R " << 100*recall()
       << " F " << 100*fmeas()
       << " BP " << 100*b_precision()
       << " BR " << 100*b_recall()
       << " BF " << 100*b_fmeas()
       << " LP " << 100*lexicon_precision()
       << " LR " << 100*lexicon_recall()
       << " LF " << 100*lexicon_fmeas()
       << std::endl;
    os.precision(6);
}

void Scoring::print_final_results(std::wostream& os) const
{
    os << "Reference lexicon summary:" << std::endl;
    print_lexicon_summary(_reference_lex);
    os << std::endl;
    os << "Segmented lexicon summary:" << std::endl;
    print_lexicon_summary(_segmented_lex);
    os << std::endl;
    print_results();
}

/*
  Looks up each word in the segmented lexicon to see whether it's also
  in the reference lexicon.  We need to calculate this each time it's
  called because the number of correct words and lexicon size changes.
*/
int Scoring::lexicon_correct() const
{
    int correct = 0;
    for(const auto& val: _segmented_lex)
        if (_reference_lex.count(val.first))
            correct++;

    return correct;
}

void Scoring::print_segmented_lexicon(std::wostream& os) const
{
    os << "Segmented lexicon:" << std::endl;
    print_lexicon(_segmented_lex);
    os << std::endl;
    os << "Total segmented lexicon types: " << _segmented_lex.ntypes() << std::endl;
    os << "Total segmented lexicon tokens: " << _segmented_words << std::endl;
}

void Scoring::print_reference_lexicon(std::wostream& os) const
{
    os << "Reference lexicon:" << std::endl;
    print_lexicon(_reference_lex);
    os << std::endl;
    os << "Total reference lexicon types: " << _reference_lex.ntypes() << std::endl;
    os << "Total reference lexicon tokens: " << _reference_words << std::endl;
}

void Scoring::print_lexicon(const Lexicon& lexicon, std::wostream& os) const
{
    /*
    //  Cs length_counts(Sentence::MAX_LENGTH, 0);
    vector<SC> word_counts;
    Count tot = 0;
    cforeach(Lexicon, iter, lexicon) {
    word_counts.push_back(SC(*iter));
    tot += iter->second;
    }
    sort(word_counts.begin(), word_counts.end(),
    second_greaterthan());
    foreach(vector<SC>, iter, word_counts) {
    if (_reference_lex.count(iter->first))
    os << "+ ";
    else
    os << "- ";
    os << iter->second << " " << iter->first << endl;
    }
    print_lexicon_summary(lexicon);
    */
}

void Scoring::print_lexicon_summary(const Lexicon& lexicon, std::wostream& os) const
{
    /*
      Cs length_counts(Sentence::MAX_LENGTH, 0);
      Cs length_types(Sentence::MAX_LENGTH, 0);
      Count tot = 0;
      cforeach(Lexicon, iter, lexicon) {
      length_counts[iter->first.length()] += iter->second;
      tot += iter->second;
      length_types[iter->first.length()]++;
      }
      os << endl << "Total words of each length (token/type): " << endl;
      Float total_counts = 0;
      Float total_types = 0;
      for (Count i=0; i<length_counts.size(); i++) {
      if (length_counts[i] > 0) {
      total_counts += length_counts[i]*i;
      total_types += length_types[i]*i;
      os << i << ": " << length_counts[i] << " ("
      << 100.0*length_counts[i]/tot << "%) / "
      << length_types[i] << " ("
      << 100.0*length_types[i]/lexicon.ntypes() << "%)" << endl;
      }
      }
      os << "Average word length: "
      << total_counts/tot << " / "
      << total_types/lexicon.ntypes() << endl;
    */
}
