//! slice-sampler.h is an MCMC slice sampler
//!
//! Mark Johnson, 1st August 2008
//
// sgwater 14 Aug 2009: added pya/pyb code in here, adapted from
// Mark's py-cfg program.

#ifndef SLICE_SAMPLER_H
#define SLICE_SAMPLER_H

#include <algorithm>
#include <cassert>
#include <cmath>
#include <iostream>
#include <limits>
#include "gammadist.h"

//! slice_sampler_rfc_type{} returns the value of a user-specified
//! function if the argument is within range, or - infinity otherwise
//
template <typename F, typename Fn, typename U>
struct slice_sampler_rfc_type {
  F min_x, max_x;
  const Fn& f;
  U max_nfeval, nfeval;
  slice_sampler_rfc_type(F min_x, F max_x, const Fn& f, U max_nfeval) 
    : min_x(min_x), max_x(max_x), f(f), max_nfeval(max_nfeval), nfeval(0) { }
    
  F operator() (F x) {
    if (min_x < x && x < max_x) {
      assert(++nfeval <= max_nfeval);
      F fx = f(x);
      assert(finite(fx));
      return fx;
    }
    else
      return -std::numeric_limits<F>::infinity();
  }
};  // slice_sampler_rfc_type{}

//! slice_sampler1d() implements the univariate "range doubling" slice sampler
//! described in Neal (2003) "Slice Sampling", The Annals of Statistics 31(3), 705-767.
//
template <typename F, typename LogF, typename Uniform01>
F slice_sampler1d(const LogF& logF0,               //!< log of function to sample
		  F x,                             //!< starting point
		  Uniform01& u01,                  //!< uniform [0,1) random number generator
		  F min_x = -std::numeric_limits<F>::infinity(),  //!< minimum value of support
		  F max_x = std::numeric_limits<F>::infinity(),   //!< maximum value of support
		  F w = 0.0,                       //!< guess at initial width
		  unsigned nsamples=1,             //!< number of samples to draw
		  unsigned max_nfeval=200)         //!< max number of function evaluations
{
  typedef unsigned U;
  slice_sampler_rfc_type<F,LogF,U> logF(min_x, max_x, logF0, max_nfeval);

  assert(finite(x));

  if (w <= 0.0) {                           // set w to a default width 
    if (min_x > -std::numeric_limits<F>::infinity() && max_x < std::numeric_limits<F>::infinity())
      w = (max_x - min_x)/4;
    else
      w = std::max(((x < 0.0) ? -x : x)/4, 0.1);
  }
  assert(finite(w));

  F logFx = logF(x);
  for (U sample = 0; sample < nsamples; ++sample) {
    F logY = logFx + log(u01()+1e-100);     //! slice logFx at this value
    assert(finite(logY));

    F xl = x - w*u01();                     //! lower bound on slice interval
    F logFxl = logF(xl);
    F xr = xl + w;                          //! upper bound on slice interval
    F logFxr = logF(xr);

    while (logY < logFxl || logY < logFxr)  // doubling procedure
      if (u01() < 0.5) 
	logFxl = logF(xl -= xr - xl);
      else
	logFxr = logF(xr += xr - xl);
	
    F xl1 = xl;
    F xr1 = xr;
    while (true) {                          // shrinking procedure
      F x1 = xl1 + u01()*(xr1 - xl1);
      if (logY < logF(x1)) {
	F xl2 = xl;                         // acceptance procedure
	F xr2 = xr; 
	bool d = false;
	while (xr2 - xl2 > 1.1*w) {
	  F xm = (xl2 + xr2)/2;
	  if ((x < xm && x1 >= xm) || (x >= xm && x1 < xm))
	    d = true;
	  if (x1 < xm)
	    xr2 = xm;
	  else
	    xl2 = xm;
	  if (d && logY >= logF(xl2) && logY >= logF(xr2))
	    goto unacceptable;
	}
	x = x1;
	goto acceptable;
      }
      goto acceptable;
    unacceptable:
      if (x1 < x)                           // rest of shrinking procedure
	xl1 = x1;
      else 
	xr1 = x1;
    }
  acceptable:
    w = (4*w + (xr1 - xl1))/5;              // update width estimate
  }
  return x;
}




  //////////////////////////////////////////////////////////////////////
  //                                                                  //
  //                   Resample pya and pyb                           //
  //                                                                  //
  //////////////////////////////////////////////////////////////////////

  //! pya_logPrior() calculates the Beta prior on pya.
  //
  static F pya_logPrior(F pya, F pya_beta_a, F pya_beta_b) {
    F prior = lbetadist(pya, pya_beta_a, pya_beta_b);     //!< prior for pya
    return prior;
  }  // pycfg_type::pya_logPrior()

  //! pyb_logPrior() calculates the prior probability of pyb 
  //! wrt the Gamma prior on pyb.
  //
static F pyb_logPrior(F pyb, F pyb_gamma_c, F pyb_gamma_s) {
    F prior = lgammadist(pyb, pyb_gamma_c, pyb_gamma_s);  // prior for pyb
    return prior;
  }  // pcfg_type::pyb_logPrior()


  //! resample_pyb_type{} is a function object that returns the part of log prob that depends on pyb.
  //! This includes the Gamma prior on pyb, but doesn't include e.g. the rule probabilities
  //! (as these are a constant factor)
  //
struct resample_pyb_type {
  Unigrams& lex;
  F pyb_gamma_c, pyb_gamma_s;
  resample_pyb_type(Unigrams& lex, F pyb_gamma_c, F pyb_gamma_s) 
    : lex(lex), pyb_gamma_c(pyb_gamma_c), pyb_gamma_s(pyb_gamma_s)
  { }

  //! operator() returns the part of the log posterior probability that depends on pyb
  //
  F operator() (F pyb) const {
    F logPrior = 0;
    logPrior += pyb_logPrior(lex.pyb(), pyb_gamma_c, pyb_gamma_s);  //!< prior for pyb
    F logProb = lex.logprob();
    TRACE2(logPrior, logProb);
    return logProb+logPrior;
  }
};  // resample_pyb_type{}

//! resample_pya_type{} calculates the part of the log prob that depends on pya.
//! This includes the Beta prior on pya, but doesn't include e.g. the rule probabilities
//! (as these are a constant factor)
//
struct resample_pya_type {
  Unigrams& lex;
  F pya_beta_a, pya_beta_b;
    
  resample_pya_type(Unigrams& lex, F pya_beta_a, F pya_beta_b) 
    : lex(lex), pya_beta_a(pya_beta_a), pya_beta_b(pya_beta_b)
  { }

  //! operator() returns the part of the log posterior probability that depends on pya
  //
  F operator() (F pya) const {
    F logPrior = pya_logPrior(lex.pya(), pya_beta_a, pya_beta_b);     //!< prior for pya
    F logProb = lex.logprob();
    TRACE2(logPrior, logProb);
    return logPrior + logProb;
  }   // pycfg_type::resample_pya_type::operator()

};  // resample_pya_type{}





#endif  // SLICE_SAMPLER_H
