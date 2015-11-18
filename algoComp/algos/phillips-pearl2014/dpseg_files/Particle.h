#ifndef _PARTICLE_H_
#define _PARTICLE_H_

#include <iostream.h>
#include "Unigrams.h"
#include "Sentence.h"
#include "Estimators.h"

//June 09: have moved code into here and Particle.cc now that I'm not
//working on multi-particle filter, to get it out of the way. 
//To start working on this again, may need to move back to Estimators.h
//and Estimators.cc.  (Also commented out sme in mhs.h and main.cc).

class UnigramParticle {
public:
  UnigramParticle(F p_nl, U nc, F a1, F b1):
    _base(p_nl, nc), _lex(_base, unif01, a1, b1) {}
  // create a new copy of the base distribution for the
  // copy of the adapter.
    UnigramParticle(const UnigramParticle& u):
      _base(u._base), _lex(u._lex, _base) {}
    const P0& base_dist() const {return _base;}
    const Unigrams& unigrams() const {return _lex;}
    P0& base_dist() {return _base;}
    Unigrams& unigrams() {return _lex;}
 private:
  P0 _base;
  Unigrams _lex;
};

class UnigramParticleFilter: public ModelBase {
public:
  UnigramParticleFilter(Data*);
  virtual ~UnigramParticleFilter() {}
  virtual bool sanity_check() const;
  virtual F log_posterior() const{
    F logprob = 0;
    cforeach (Particles, p, _particles) {
      logprob += ModelBase::log_posterior(p->unigrams());
    }
    return logprob;
  }
  virtual void estimate(U iters, std::ostream& os);
protected:
  typedef vector<UnigramParticle> Particles;
  Particles _particles;
  virtual void estimate_sentence(Sentence& s, F temperature);
};

#endif
