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

#include <boost/program_options.hpp>

#include <tr1/unordered_map>

#include "Estimators.h"
#include "Data.h"
#include "Sentence.h"
#include "mhs.h"    // random.h is included here
#include "precrec.h"
#include "util.h"   // namespace tr1 defined here
#include "Base.h"

using namespace std;

const char* program_options =
"Test code\n"
"Options:";

uniform01_type unif01;

U debug_level;
std::string sep;          //!< separator used to separate fields during printing of results
//extern string S::data;   //!< global data object, which holds training and eval data

typedef CharSeq0<string> Monkeys;
typedef CharSeqLearned<string> LearnedMonkeys;

void test_base_distribution(Monkeys& base) {
  cout.precision(6);
  string a("hi");
  string b("hi");
  string c("bye");
  base.insert(a);
  base.insert(b);
  base.insert(c);
  base.insert(c);
  cout << base.get_nchars() << " " << base.get_nstrings() << " " 
       << base("h") << " " << base("by") << endl;
}

void test_random(uniform01_type& u01) {
  for (int i=0; i < 10; i++) {
    cout << u01() << endl;
  }
}

void test_adaptor(Monkeys& base, uniform01_type& u01, F a, F b) {
  PYAdaptor<Monkeys> py(base, u01, a, b);
  cout << py.insert("a") << endl;
  cout << py.insert("b") << endl;
  cout << py.insert("a") << endl;
  cout << py.insert("a") << endl;
  cout << py.insert("a") << endl;
  cout << py << endl;
  cout << base("a") << " " << py("a") << " " << py("b") << endl;
}

/*
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

void write_corpus_gold(const Data& d) {
    Bs gold_boundary(S::data.size());      //!< gold_boundary[i] is true iff there really is a boundary at i
    for (U i = 0; i < S::data.size(); ++i)
      if (S::data[i] == '\n' || S::data[i-1] == '\n') {
	gold_boundary[i] = true;          // insert sentence boundaries into gold_boundary[]
      }
    cforeach (Us, it, d.gold_boundary_list()) {    // set gold_boundary[]
      gold_boundary[*it] = true;
    }
    //  cout << gold_boundary << endl;
  d.write_segmented_corpus(gold_boundary, cout);
}

int main(int argc, char** argv) {
  ExperimentalData d;
  std::ios_base::sync_with_stdio(false);
  std::cin.tie(0);

  namespace po = boost::program_options;
  po::options_description desc("program_options");
  desc.add_options()
    ("help,h", "produce help message")
    ("config-file,C", po::value<std::string>(), "read options from this file")
    ("debug-level,d", po::value<U>(&debug_level)->default_value(0), "debugging level")
    ("data-file", po::value<std::string>(), "training data file (default is stdin)")
    ("output-file,o", po::value<std::string>(), "segmented output file")
    ("nsentences,n", po::value<U>()->default_value(0), "number of training sentences to use (0 = all)")
    ("eval-sentences", po::value<std::string>()->default_value("0 0"), "List of (begin,end) pairs of sentence numbers for evaluation")
    ("estimator", po::value<std::string>()->default_value("T"), "possible values are: V(iterbi), F(lip), T(ree)")
    ("mode", po::value<std::string>()->default_value("online"), "possible values are: online, batch")
    ("ngram", po::value<U>()->default_value(1), "possible values are: 1 (unigram), 2 (bigram)")
    ("do_mbdp", po::value<bool>(&d.do_mbdp)->default_value(false), "maximize using Brent ngram instead of DP")
    ("a1", po::value<F>(&d.a1)->default_value(0), "Unigram Pitman-Yor a parameter")
    ("b1", po::value<F>(&d.b1)->default_value(1), "Unigram Pitman-Yor b parameter")
    ("a2", po::value<F>(&d.a2)->default_value(0), "Bigram Pitman-Yor a parameter")
    ("b2", po::value<F>(&d.b2)->default_value(1), "Bigram Pitman-Yor b parameter")
    ("Pstop", po::value<F>(&d.Pstop)->default_value(0.5), "Monkey model stop probability")
    ("nchartypes", po::value<U>(&d.nchartypes)->default_value(0), "Number of characters assumed in P_0 (default = 0 will compute from input)")
    //    ("p_nl", po::value<F>(&d.p_nl)->default_value(0.5), "End of sentence prob")
    ("aeos", po::value<F>(&d.aeos)->default_value(2), "Beta prior on end of sentence prob")
    ("init_pboundary", po::value<F>(&d.init_pboundary)->default_value(0), "Initial segmentation boundary probability (-1 = gold)")
    ("randseed", po::value<U>()->default_value(util::randseed()), "Random number seed")
    ("trace-every", po::value<U>(&d.trace_every)->default_value(100), "Epochs between printing out trace information (0 = don't trace)")
    ("nsubjects,s", po::value<U>()->default_value(1), "Number of subjects to simulate")
    ("forget-rate,f", po::value<U>(&d.forget_rate)->default_value(0), "Number of utterances whose words can be remembered (0 = no limit)")
    ("token-memory,N", po::value<U>(&d.token_memory)->default_value(0), "Number of tokens that can be remembered (0 = no limit)")
    ("type-memory,L", po::value<U>(&d.type_memory)->default_value(0), "Number of types that can be remembered (0 = no limit)")
    ("forget-method", po::value< std::string>(&d.forget_method)->default_value("U"), "Method of deleting lexical items: U(niformly), P(roportional)")
    ("burnin-iterations,i", po::value<U>(&d.burnin_iterations)->default_value(1), "Number of burn-in epochs")
    ("anneal-iterations", po::value<U>(&d.anneal_iterations)->default_value(0), "Number of epochs to anneal for")
    ("anneal-start-temperature", po::value<F>(&d.anneal_start_temperature)->default_value(1), "Start annealing at this temperature")
    ("anneal-stop-temperature", po::value<F>(&d.anneal_stop_temperature)->default_value(1), "Stop annealing at this temperature")
    //    ("anneal-a", po::value<F>(&d.anneal_a)->default_value(10), "Parameter in annealing temperature sigmoid function")
    ("anneal-a", po::value<F>(&d.anneal_a)->default_value(0), "Parameter in annealing temperature sigmoid function (0 = use ACL06 schedule)")
    ("anneal-b", po::value<F>(&d.anneal_b)->default_value(0.2), "Parameter in annealing temperature sigmoid function")
    ("result-field-separator", po::value<std::string>(&sep)->default_value("\t"), "Field separator used to print results")
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


  if (debug_level >= 100)
    std::cout << "# particle" << ", " << util::date
	      << "# debug-level=" << debug_level << std::endl
	      << "# data-file=" << vm["data-file"].as<std::string>() << std::endl
	      << "# nsentences=" << vm["nsentences"].as<U>() << std::endl
      	      << "# output-file=" << vm["output-file"].as<std::string>() << std::endl
	      << "# eval-sentences=" << vm["eval-sentences"].as<std::string>() << std::endl
	      << "# estimator=" << vm["estimator"].as<std::string>() << std::endl
	      << "# mode=" << vm["mode"].as<std::string>() << std::endl
	      << "# ngram=" << vm["ngram"].as<U>() << std::endl
	      << "# do_mbdp=" << vm["do_mbdp"].as<bool>() << std::endl
      	      << "# a1=" << vm["a1"].as<F>() << std::endl
      	      << "# b1=" << vm["b1"].as<F>() << std::endl
      	      << "# a2=" << vm["a2"].as<F>() << std::endl
      	      << "# b2=" << vm["b2"].as<F>() << std::endl
	      << "# Pstop=" << d.Pstop << std::endl
	      << "# aeos=" << d.aeos << std::endl
	      << "# init_pboundary=" << vm["init_pboundary"].as<F>() << std::endl
	      << "# randseed=" << vm["randseed"].as<U>() << std::endl
	      << "# trace-every=" << d.trace_every << std::endl
	      << "# nsubjects=" << vm["nsubjects"].as<U>() << std::endl
	      << "# forget-rate=" << d.forget_rate << std::endl
	      << "# token-memory=" << d.token_memory << std::endl
	      << "# type-memory=" << d.type_memory << std::endl
	      << "# forget-method=" << d.forget_method << std::endl
	      << "# burnin-iterations=" << d.burnin_iterations << std::endl
	      << "# anneal-iterations=" << d.anneal_iterations << std::endl
	      << "# anneal-start-temperature=" << d.anneal_start_temperature << std::endl
	      << "# anneal-stop-temperature=" << d.anneal_stop_temperature << std::endl
	      << "# anneal-a=" << d.anneal_a << std::endl
	      << "# anneal-b=" << d.anneal_b << std::endl
	      << "# result-field-separator=" << sep << std::endl
      ;
  unif01.seed(vm["randseed"].as<U>());
//   //  test_random(unif01);
//   Monkeys base(.5,5);
//   // Monkeys base(.4,5);   // result: 10 4 0.08 0.0096
//   test_base_distribution(base);  // result: 10 4 0.1 0.01
//   test_adaptor(base,unif01,d.a1,d.b1);
//  LearnedMonkeys base(.5,5);
//   test_adaptor_copy(base,unif01,d.a1,d.b1);
//   exit(0);

//error checks
  if ((d.forget_rate >0 && (d.token_memory >0 || d.type_memory >0))
      || (d.token_memory >0 && d.type_memory >0)) {
      cerr << "Error: only one of (forget-rate, token-memory, type-memory) may be greater than zero" << endl;
      exit (1);
  }
  if (d.type_memory >0 && !(d.forget_method == "U" || d.forget_method == "P")) {
    cerr << "Error: only 'U'(niform) or 'P'(roportional) forget-methods are allowed for type-memory" << endl;
    exit (1);
  }
  if (d.token_memory >0 && !(d.forget_method == "U")) {
    cerr << "Error: only 'U'(niform) forget-method is allowed for token-memory" << endl;
    exit (1);
  }

  // read training data

  if (vm.count("data-file") > 0) {
    std::ifstream is(vm["data-file"].as<std::string>().c_str());
    if (!is) {
      cerr << "Error: couldn't open " << vm["data-file"].as<std::string>() << endl;
      exit(1);
    }
    d.read(is);
  }
  else
    d.read(std::cin);
  
  if (debug_level >= 98000) {
    TRACE(S::data.size());
    TRACE(S::data);
    TRACE(d.gold_boundary_list());
    TRACE(d.sentence_boundary_list());
  }
  d.initialize(vm["nsentences"].as<U>());
  if (debug_level >= 98000) {
    TRACE(d.nchars());
    TRACE (d.get_test_pairs());
    TRACE (d.possible_boundaries());
  }
  if (debug_level >= 100)
    std::cout << "# nchartypes=" << d.nchartypes << endl
	      << "# nsentences=" << d.nsentences() << endl
      ;
  //  write_corpus_gold(d);
  std::ofstream os(vm["output-file"].as<std::string>().c_str());
  if (! os) {
    cerr << "couldn't open output file: " << vm["output-file"].as<std::string>() << endl;
    exit (1);
  }
  Model* sampler;
  U nsubjects = vm["nsubjects"].as<U>();
  Fs averages;
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
      sampler = new OnlineUnigramViterbi(&d, d.forget_rate);
    }
    else if (vm["estimator"].as<std::string>() == "T") {
      sampler = new OnlineUnigramTreeSampler(&d, d.forget_rate);
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
  assert(sampler->sanity_check());

  cerr << "Subject " << subject << endl;
  sampler->estimate(d.burnin_iterations, cerr);

  os << "Subject " << subject << endl;
  sampler->print_segmented(os);
  sampler->print_lexicon(os);
  os << endl;

  Fs predictions = sampler->predict_pairs(d.get_test_pairs());
  F average = mean(predictions);
  cout << "Subject " << subject << ": " << average << endl;
  averages.push_back(average);
  delete sampler;
  } // end for subject
  cout << "Average over " << nsubjects << " subjects = " << mean(averages) << endl;
}  // main()


