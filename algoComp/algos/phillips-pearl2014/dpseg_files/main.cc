// created by Sharon Goldwater
// modified by Lisa Pearl, Oct 7, 2009
#include <algorithm>
#include <cassert>
#include <cmath>
#include <fstream>
#include <functional>
#include <iostream>
#include <iterator>
#include <map>
#include <set>
#include <string>
#include <vector>
#include <locale.h>

#include <boost/program_options.hpp>

#define BOOST_UTF8_BEGIN_NAMESPACE
#define BOOST_UTF8_END_NAMESPACE
#define BOOST_UTF8_DECL

//#include <boost/detail/utf8_codecvt_facet.hpp>
#include "utf8_codecvt_facet.cpp"

#include <tr1/unordered_map>

#include "Estimators.h"
#include "Data.h"
#include "Sentence.h"
#include "mhs.h"    // random.h is included here
#include "precrec.h"
#include "util.h"   // namespace tr1 defined here
#include "Base.h"

using namespace std;

//inline std::wostream& operator<< (std::wostream & ostr,
//   std::wstring const & str )
//{
//     std::copy(str.begin(), str.end(),
//        std::ostream_iterator<std::wchar_t>(ostr) );
//   return ostr;
//}


const char* program_options =
"Test code\n"
"Options:";

uniform01_type unif01;

U debug_level;
std::wstring sep;          //!< separator used to separate fields during printing of results
//extern string S::data;   //!< global data object, which holds training and eval data

typedef CharSeq0<wstring> Monkeys;
typedef CharSeqLearned<wstring> LearnedMonkeys;

void test_base_distribution(Monkeys& base) {
  wcout.precision(6);
  wstring a(L"hi");
  wstring b(L"hi");
  wstring c(L"bye");
  base.insert(a);
  base.insert(b);
  base.insert(c);
  base.insert(c);
  wcout << base.get_nchars() << " " << base.get_nstrings() << " "
       << base(L"h") << " " << base(L"by") << endl;
}

void test_random(uniform01_type& u01) {
  for (int i=0; i < 10; i++) {
    wcout << u01() << endl;
  }
}

void test_adaptor(Monkeys& base, uniform01_type& u01, F a, F b) {
  PYAdaptor<Monkeys> py(base, u01, a, b);
  wcout << py.insert(L"a") << endl;
  wcout << py.insert(L"b") << endl;
  wcout << py.insert(L"a") << endl;
  wcout << py.insert(L"a") << endl;
  wcout << py.insert(L"a") << endl;
  wcout << py << endl;
  wcout << base(L"a") << " " << py(L"a") << " " << py(L"b") << endl;
}

/* figure this out if i ever want multiple particles.
void test_adaptor_copy(LearnedMonkeys& base, uniform01_type& u01, F a, F b) {
  cout << "test: copying unigram monkeys" << endl;
  PYAdaptor<LearnedMonkeys> py(base, u01, a, b);
  cout << py.insert("a") << endl;
  cout << py.insert("b") << endl;
  cout << py.insert("a") << endl;
  cout << base("a") << " " << py("a") << " " << py("b") << endl;
  //copy old base distr.
  LearnedMonkeys base2(base);
  PYAdaptor<LearnedMonkeys> pz(py); // has shared base distribution
  PYAdaptor<LearnedMonkeys> pq(py,base2); // has separate base distribution

  //insertions will now affect common base distribution, but
  // counts will remain separate.
  cout << pz.base_dist()("a") << " " << pz("a") << " " << pz("b") << endl;
  cout << pz.insert("a") << endl;
  cout << pz.insert("b") << endl;
  cout << py.insert("c") << endl;
  //now py should contain "c", while pz does not, but both will have
  // the same base probability for it.
  cout << "py:" << endl;
  cout << py << endl;
  cout << py.base_dist()("c") << " " << py.base_dist()("a") << " " << py("a") << " " << py("b") << endl;
  cout << "pz:" << endl;
  cout << pz << endl;
  cout << pz.base_dist()("c") << " " << pz.base_dist()("a") << " " << pz("a") << " " << pz("b") << endl;
  // pq should have a different base probability for "c" (and "a").
  cout << pq.base_dist()("c") << " " << pq.base_dist()("a") << " " << pq("a") << " " << pq("b") << endl;
  cout << pz.insert("d") << endl;
  cout << pq.insert("e") << endl;
  // probabilities of d and e should be different.
  cout << "pq:" << endl << pq << endl;
  //  cout << "pq base:" << endl << pq.base_dist() << endl;
  cout << pq.base_dist()("d") << " " << pq.base_dist()("e") << " " << pq("a") << " " << pq("b") << endl;
  cout << "pz:" << endl << pz << endl;
  //  cout << "pz base:" << endl << pz.base_dist() << endl;
  cout << pz.base_dist()("d") << " " << pz.base_dist()("e") << " " << pz("a") << " " << pz("b") << endl;
}
*/

void write_corpus_gold(const CorpusData& d) {
cerr<< "Debug: writing corpus gold\n";
//     Bs gold_boundary(S::data.size());      //!< gold_boundary[i] is true iff there really is a boundary at i
//     for (U i = 0; i < S::data.size(); ++i)
//       if (S::data[i] == '\n' || S::data[i-1] == '\n') {
// 	gold_boundary[i] = true;          // insert sentence boundaries into gold_boundary[]
//       }
//     cforeach (Us, it, d.gold_boundary_list()) {    // set gold_boundary[]
//       gold_boundary[*it] = true;
//     }
//     //  cout << gold_boundary << endl;
  d.write_segmented_corpus(d.true_boundaries(), wcout);
}

std::wstring str2wstr(std::string str)
{
	// FIXME: JPW: Very possible that this routine is returning a pointer to
	// stack allocated space.  I dunno enough C++ to know for sure and don't
	// have time to look at the moment.  It runs for me but YMMV.

	std::wstring temp_str(str.length(), L' '); // Make room for characters
	std::copy(str.begin(), str.end(), std::back_inserter(temp_str));

	return temp_str;
}

int main(int argc, char** argv) {
  //  TRACE(setlocale(LC_ALL,"en_US.utf8"));

  // Need to make output streams handle utf8.
  // Otherwise we'll get aborts when trying to output large character values.
  std::locale old_locale;
  std::locale utf8_locale(old_locale,new utf8_codecvt_facet());
  // Set a New global locale
  std::locale::global(utf8_locale);

  wcout.imbue(utf8_locale);
  wcerr.imbue(utf8_locale);

  wcout.precision(5);

  CorpusData d;
  std::string csep;
  std::ios_base::sync_with_stdio(false);
  std::cin.tie(0);

  namespace po = boost::program_options;
  po::options_description desc("program_options");
  desc.add_options()
    ("help,h", "produce help message")
    ("config-file,C", po::value<std::string>(), "read options from this file")
    ("debug-level,d", po::value<U>(&debug_level)->default_value(0), "debugging level")
    ("data-file", po::value<std::string>(), "training data file (default is stdin)")
    ("data-start-index", po::value<U>()->default_value(0), "sentence index to start reading training data file")
    ("data-num-sents", po::value<U>()->default_value(0), "number of training sentences to use (0 = all)")
    ("eval-file", po::value<std::string>(), "testing data file (default is training file)")
    ("eval-start-index", po::value<U>()->default_value(0), "sentence index to start reading eval data file")
    ("eval-num-sents", po::value<U>()->default_value(0), "number of testing sentences to use (0 = all)")
    ("eval-maximize", po::value<U>()->default_value(0), "1 = choose max prob segmentation of test sentences, 0 (default) = sample instead")
	("eval-interval", po::value<U>()->default_value(0), "how frequently eval set is evaluated, 0 (default) = don't evaluate before training is done")
    ("output-file,o", po::value<std::string>(), "segmented output file")
    ("estimator", po::value<std::string>()->default_value("F"), "possible values are: V(iterbi), F(lip), T(ree), D(ecayed Flip)")
	("decay_rate", po::value<F>()->default_value(1.0), "decay rate for D(ecayed Flip), default = 1.0")
	("samples_per_utt", po::value<U>()->default_value(1000), "samples per utterance for D(ecayed Flip), default = 1000")
    ("mode", po::value<std::string>()->default_value("batch"), "possible values are: online, batch")
    ("ngram", po::value<U>()->default_value(2), "possible values are: 1 (unigram), 2 (bigram)")
    ("do_mbdp", po::value<bool>(&d.do_mbdp)->default_value(false), "maximize using Brent ngram instead of DP")
    ("a1", po::value<F>(&d.a1)->default_value(0), "Unigram Pitman-Yor a parameter")
    ("b1", po::value<F>(&d.b1)->default_value(1), "Unigram Pitman-Yor b parameter")
    ("a2", po::value<F>(&d.a2)->default_value(0), "Bigram Pitman-Yor a parameter")
    ("b2", po::value<F>(&d.b2)->default_value(1), "Bigram Pitman-Yor b parameter")
    ("Pstop", po::value<F>(&d.Pstop)->default_value(0.5), "Monkey model stop probability")
    ("hypersamp-ratio", po::value<F>(&d.hypersampling_ratio)->default_value(0.1), "Standard deviation for new hyperparm proposals (0 turns off hyperp sampling)")
    ("nchartypes", po::value<U>(&d.nchartypes)->default_value(0), "Number of characters assumed in P_0 (default = 0 will compute from input)")
    //    ("p_nl", po::value<F>(&d.p_nl)->default_value(0.5), "End of sentence prob")
    ("aeos", po::value<F>(&d.aeos)->default_value(2), "Beta prior on end of sentence prob")
    ("init_pboundary", po::value<F>(&d.init_pboundary)->default_value(0), "Initial segmentation boundary probability (-1 = gold)")
    ("pya-beta-a", po::value<F>(&d.pya_beta_a)->default_value(1), "if non-zero, a parameter of Beta prior on pya")
    ("pya-beta-b", po::value<F>(&d.pya_beta_b)->default_value(1), "if non-zero, b parameter of Beta prior on pya")
    ("pya-gamma-s", po::value<F>(&d.pyb_gamma_s)->default_value(10), "if non-zero, parameter of Gamma prior on pyb")
    ("pya-gamma-c", po::value<F>(&d.pyb_gamma_c)->default_value(0.1), "if non-zero, parameter of Gamma prior on pyb")
    ("randseed", po::value<U>()->default_value(util::randseed()), "Random number seed")
    ("trace-every", po::value<U>(&d.trace_every)->default_value(100), "Epochs between printing out trace information (0 = don't trace)")
    ("nsubjects,s", po::value<U>()->default_value(1), "Number of subjects to simulate")
    ("forget-rate,f", po::value<F>()->default_value(0), "Number of utterances whose words can be remembered")
    ("burnin-iterations,i", po::value<U>(&d.burnin_iterations)->default_value(2000), "Number of burn-in epochs")
    ("anneal-iterations", po::value<U>(&d.anneal_iterations)->default_value(0), "Number of epochs to anneal for")
    ("anneal-start-temperature", po::value<F>(&d.anneal_start_temperature)->default_value(1), "Start annealing at this temperature")
    ("anneal-stop-temperature", po::value<F>(&d.anneal_stop_temperature)->default_value(1), "Stop annealing at this temperature")
    //    ("anneal-a", po::value<F>(&d.anneal_a)->default_value(10), "Parameter in annealing temperature sigmoid function")
    ("anneal-a", po::value<F>(&d.anneal_a)->default_value(0), "Parameter in annealing temperature sigmoid function (0 = use ACL06 schedule)")
    ("anneal-b", po::value<F>(&d.anneal_b)->default_value(0.2), "Parameter in annealing temperature sigmoid function")
	("result-field-separator", po::value<std::string>(&csep)->default_value("\t"), "Field separator used to print results")
    ("forget-method", po::value< std::string>(&d.forget_method)->default_value("U"), "Method of deleting lexical items: U(niformly), P(roportional)")
    ("token-memory,N", po::value<U>(&d.token_memory)->default_value(0), "Number of tokens that can be remembered (0 = no limit)")
    ("type-memory,L", po::value<U>(&d.type_memory)->default_value(0), "Number of types that can be remembered (0 = no limit)")
    ;

  po::variables_map vm;
  po::store(po::parse_command_line(argc, argv, desc), vm);
  po::notify(vm);    

  if (vm.count("help")) 
    std::cerr << desc << util::exit_failure;

  if (vm.count("config-file") > 0) {
    std::ifstream is(vm["config-file"].as<std::string>().c_str());
    po::store(po::parse_config_file(is, desc), vm);
    po::notify(vm);
  }
  string data_file = "stdin";
  if (vm.count("data-file") > 0) 
    data_file = vm["data-file"].as<std::string>();
  string eval_file = "none";
  if (vm.count("eval-file") > 0) 
    eval_file = vm["eval-file"].as<std::string>();

  // We need a wide version of the result-field-separator parameter string.
  sep.assign(csep.begin(), csep.end());

  if (debug_level >= 100) {
    std::wcout << "# particle" << ", " << util::date
	      << "# debug-level=" << debug_level << std::endl
	      << "# data-file=" << data_file.c_str() << std::endl
	      << "# data-start-index=" << vm["data-start-index"].as<U>() << std::endl
	      << "# data-num-sents=" << vm["data-num-sents"].as<U>() << std::endl
	      << "# eval-file=" << eval_file.c_str() << std::endl
	      << "# eval-start-index=" << vm["eval-start-index"].as<U>() << std::endl
	      << "# eval-num-sents=" << vm["eval-num-sents"].as<U>() << std::endl
	      << "# eval-maximize=" << vm["eval-maximize"].as<U>() << std::endl
		  << "# eval-interval=" <<vm["eval-interval"].as<U>() << std::endl
    	  << "# output-file=" << str2wstr(vm["output-file"].as<std::string>()) << std::endl
	      << "# estimator=" << str2wstr(vm["estimator"].as<std::string>()) << std::endl
		  << "# decay_rate=" << vm["decay_rate"].as<F>() << std::endl
		  << "# samples_per_utt=" << vm["samples_per_utt"].as<U>() << std::endl
	      << "# mode=" << str2wstr(vm["mode"].as<std::string>()) << std::endl
	      << "# ngram=" << vm["ngram"].as<U>() << std::endl
	      << "# do_mbdp=" << vm["do_mbdp"].as<bool>() << std::endl
      	      << "# a1=" << vm["a1"].as<F>() << std::endl
      	      << "# b1=" << vm["b1"].as<F>() << std::endl
      	      << "# a2=" << vm["a2"].as<F>() << std::endl
      	      << "# b2=" << vm["b2"].as<F>() << std::endl
	      << "# Pstop=" << d.Pstop << std::endl
	      << "# hypersamp-ratio=" << d.hypersampling_ratio << std::endl
	      << "# aeos=" << d.aeos << std::endl
	      << "# init_pboundary=" << vm["init_pboundary"].as<F>() << std::endl
	      << "# pya-beta-a="  << d.pya_beta_a << std::endl
	      << "# pya-beta-b="  << d.pya_beta_b << std::endl
	      << "# pyb-gamma-s="  << d.pyb_gamma_s << std::endl
	      << "# pyb-gamma-c="  << d.pyb_gamma_c << std::endl
	      << "# randseed=" << vm["randseed"].as<U>() << std::endl
	      << "# trace-every=" << d.trace_every << std::endl
	      << "# nsubjects=" << vm["nsubjects"].as<U>() << std::endl
	      << "# forget-rate=" << vm["forget-rate"].as<F>() << std::endl
	      << "# burnin-iterations=" << d.burnin_iterations << std::endl
	      << "# anneal-iterations=" << d.anneal_iterations << std::endl
	      << "# anneal-start-temperature=" << d.anneal_start_temperature << std::endl
	      << "# anneal-stop-temperature=" << d.anneal_stop_temperature << std::endl
	      << "# anneal-a=" << d.anneal_a << std::endl
	      << "# anneal-b=" << d.anneal_b << std::endl
	      << "# result-field-separator=" << sep << std::endl
      ;
  }
  unif01.seed(vm["randseed"].as<U>());

//   //  test_random(unif01);
//   Monkeys base(.5,5);
//   // Monkeys base(.4,5);   // result: 10 4 0.08 0.0096
//   test_base_distribution(base);  // result: 10 4 0.1 0.01
//   test_adaptor(base,unif01,d.a1,d.b1);
//  LearnedMonkeys base(.5,5);
//   test_adaptor_copy(base,unif01,d.a1,d.b1);
//   exit(0);

  // read training data

  //JPW: Beware this change in Boost 1.42:
  // https://svn.boost.org/trac/boost/ticket/850
  // It now leaves quotes exactly as they appear in the config file.
  // Rather than try to strip them here, I suggest you change your config files...

  if (data_file != "stdin") {
    std::wifstream is(data_file.c_str());
    if (!is) {
      cerr << "Error: couldn't open " << data_file << endl;
      exit(1);
    }
    is.imbue(std::locale(std::locale(), new utf8_codecvt_facet()));
//    assert(is.is_open());
//    assert(is.good());
    d.read(is,vm["data-start-index"].as<U>(),vm["data-num-sents"].as<U>());
  }
  else
    d.read(std::wcin,vm["data-start-index"].as<U>(),vm["data-num-sents"].as<U>());
  if (eval_file !=  "none") {
    std::wifstream is(eval_file.c_str());
    if (!is) {
      cerr << "Error: couldn't open " << eval_file << endl;
      exit(1);
    }
    is.imbue(std::locale(std::locale(), new utf8_codecvt_facet()));
    d.read_eval(is,vm["eval-start-index"].as<U>(),vm["eval-num-sents"].as<U>());
  }
  
  if (debug_level >= 98000) {
    TRACE(S::data.size());
    TRACE(S::data);
    TRACE(d.sentence_boundary_list());
    TRACE(d.nchars());
    TRACE(d.possible_boundaries());
    TRACE(d.true_boundaries());
  }
  if (debug_level >= 100)
    std::wcout << "# nchartypes=" << d.nchartypes << endl
	      << "# nsentences=" << d.nsentences() << endl
      ;
  //  write_corpus_gold(d);
  std::wofstream os(vm["output-file"].as<std::string>().c_str());
  if (! os) {
    cerr << "couldn't open output file: " << vm["output-file"].as<std::string>() << endl;
    exit (1);
  }
  os.imbue(utf8_locale);

  Model* sampler=0;
  U nsubjects = vm["nsubjects"].as<U>();
  for (U subject = 0; subject < nsubjects; subject++) {
  if (vm["ngram"].as<U>() == 2) {
  if (vm["mode"].as<std::string>() == "batch") {
    if (vm["estimator"].as<std::string>() == "F") {
      sampler = new BatchBigramFlipSampler(&d);
    }
    else if (vm["estimator"].as<std::string>() == "V") {
      sampler = new BatchBigramViterbi(&d);
    }
    else if (vm["estimator"].as<std::string>() == "T") {
      sampler = new BatchBigramTreeSampler(&d);
    }
	else if (vm["estimator"].as<std::string>() == "D"){
		std::cerr << "D(ecayed Flip) estimator cannot be used in batch mode." << std::endl; 
	}
    else {
      std::cerr << HERE << " Error: " << vm["estimator"].as<std::string>() 
	      << " is not a recognized value for estimator." << std::endl;
    }
  }
  else if (vm["mode"].as<std::string>() == "online") {
    if (vm["estimator"].as<std::string>() == "F") {
      std::cerr << "Error: F(lip) estimator cannot be used in online mode."  << endl;
    }
    else if (vm["estimator"].as<std::string>() == "V") {
      sampler = new OnlineBigramViterbi(&d);
    }
    else if (vm["estimator"].as<std::string>() == "T") {
      sampler = new OnlineBigramTreeSampler(&d);
    }
	else if (vm["estimator"].as<std::string>() == "D") {
	  if(debug_level >= 1000){
		std::cerr << "Creating Bigram DecayedMCMC model, with decay rate " << vm["decay_rate"].as<F>()  
					<< " and samples per utterance " << vm["samples_per_utt"].as<U>() << std::endl; 
	  }	
	  sampler = new OnlineBigramDecayedMCMC(&d, vm["forget-rate"].as<F>(), vm["decay_rate"].as<F>(), vm["samples_per_utt"].as<U>());

	}
    else {
      std::cerr << HERE << " Error: " << vm["estimator"].as<std::string>() 
	      << " is not a recognized value for estimator." << std::endl;
    }
  }
  else {
    std::cerr << HERE << " Error: " << vm["mode"].as<std::string>() 
	      << " is not a recognized value for mode." << std::endl;
  }
  }
  else {
  if (vm["mode"].as<std::string>() == "batch") {
    if (vm["estimator"].as<std::string>() == "F") {
      sampler = new BatchUnigramFlipSampler(&d);
    }
    else if (vm["estimator"].as<std::string>() == "V") {
      sampler = new BatchUnigramViterbi(&d);
    }
    else if (vm["estimator"].as<std::string>() == "T") {
      sampler = new BatchUnigramTreeSampler(&d);
  assert(sampler->sanity_check());
    }
	else if (vm["estimator"].as<std::string>() == "D") {
		std::cerr << "D(ecayed Flip) estimator cannot be used in batch mode." << std::endl; 
	}
    else {
      std::cerr << HERE << " Error: " << vm["estimator"].as<std::string>() 
	      << " is not a recognized value for estimator." << std::endl;
    }
  }
  else if (vm["mode"].as<std::string>() == "online") {
    if (vm["estimator"].as<std::string>() == "F") {
      std::cerr << "Error: F(lip) estimator cannot be used in online mode."  << endl;
    }
    else if (vm["estimator"].as<std::string>() == "V") {
      sampler = new OnlineUnigramViterbi(&d, vm["forget-rate"].as<F>());
    }
    else if (vm["estimator"].as<std::string>() == "T") {
      sampler = new OnlineUnigramTreeSampler(&d, vm["forget-rate"].as<F>());
    }
	else if (vm["estimator"].as<std::string>() == "D") {
	  if(debug_level >= 1000){
		std::cerr << "Creating Unigram DecayedMCMC model, with decay rate " << vm["decay_rate"].as<F>()  
					<< " and samples per utterance " << vm["samples_per_utt"].as<U>() << std::endl; 
	  }	
	  sampler = new OnlineUnigramDecayedMCMC(&d, vm["forget-rate"].as<F>(), vm["decay_rate"].as<F>(), vm["samples_per_utt"].as<U>());

	}
    else {
      std::cerr << HERE << " Error: " << vm["estimator"].as<std::string>() 
	      << " is not a recognized value for estimator." << std::endl;
    }
  }
  else {
    std::cerr << HERE << " Error: " << vm["mode"].as<std::string>() 
	      << " is not a recognized value for mode." << std::endl;
  }
  }
  wcout << "initial probability = " << sampler->log_posterior() << endl;
  assert(sampler->sanity_check());
  // if want to evaluate test set during training intervals, need to add
  // that into estimate function
  if(vm["estimator"].as<std::string>() == "D"){
	sampler->estimate(d.burnin_iterations, wcout, vm["eval-interval"].as<U>(),
						1, vm["eval-maximize"].as<U>(), true);
  }else{
	sampler->estimate(d.burnin_iterations, wcout, vm["eval-interval"].as<U>(),
						1, vm["eval-maximize"].as<U>(), false);  
  }						
  // evaluates test set at the end of training
  if (eval_file == "none") {
    sampler->print_segmented(os);
    sampler->print_scores(wcout);
      wcout << "final posterior = " << sampler->log_posterior() << endl;
  }
  else {
    if (debug_level >= 5000) {
      wcout << "segmented training data:" << endl;
      sampler->print_segmented(wcout);
      sampler->print_scores(wcout);
	wcout << "training final posterior = " << sampler->log_posterior() << endl;
      wcout << "segmented test data:" << endl;
    }
	wcout << "Test set at end of training " << endl;
    sampler->run_eval(os,1,vm["eval-maximize"].as<U>());
      wcout << "testing final posterior = " << sampler->log_posterior() << endl;
    sampler->print_eval_segmented(os);
    sampler->print_eval_scores(wcout);
  }
  os << endl;
  delete sampler;
  } // end for subject
}  // main()


