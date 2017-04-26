// util.h
//
// Mark Johnson, 8th November 2007

#ifndef UTIL_H
#define UTIL_H

#include <algorithm>
#include <ctime>
#include <functional>
#include <iostream>
#include <iterator>
#include <map>
#include <numeric>
#include <sstream>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>


//! foreach is a simple loop construct
//!
//!   STORE should be an STL container
//!   TYPE is the typename of STORE
//!   VAR will be defined as a local variable of type TYPE::iterator
//
#define foreach(TYPE, VAR, STORE) \
   for (TYPE::iterator VAR = (STORE).begin(); VAR != (STORE).end(); ++VAR)

//! cforeach is just like foreach, except that VAR is a const_iterator
//!
//!   STORE should be an STL container
//!   TYPE is the typename of STORE
//!   VAR will be defined as a local variable of type TYPE::const_iterator
//
#define cforeach(TYPE, VAR, STORE) \
   for (TYPE::const_iterator VAR = (STORE).begin(); VAR != (STORE).end(); ++VAR)


template <typename X, typename Y>
std::wostream& operator<< (std::wostream& os, const std::pair<X,Y>& xy) {
  return os << '(' << xy.first << ' ' << xy.second << ')';
}

template <typename Key, typename Value>
std::wostream& operator<< (std::wostream& os, const std::unordered_map<Key,Value>& k_v) {
  os << '(';
  const wchar_t* sep = "";
  for (typename std::unordered_map<Key,Value>::const_iterator it=k_v.begin(); it!=k_v.end(); ++it) {
    os << sep << it->first << '=' << it->second;
    sep = ",";
  }
  return os << ')';
}

template <typename Key, typename Value>
std::wostream& operator<< (std::wostream& os, const std::map<Key,Value>& k_v) {
  os << L'(';
  const wchar_t* sep = L"";
  for (typename std::map<Key,Value>::const_iterator it=k_v.begin(); it!=k_v.end(); ++it) {
    os << sep << L'(' << it->first << L' ' << it->second << L')';
    sep = L" ";
  }
  return os << L')';
}

template <typename Value>
std::wostream& operator<< (std::wostream& os, const std::vector<Value>& vs) {
  os << L'(';
  const wchar_t* sep = L"";
  for (typename std::vector<Value>::const_iterator it = vs.begin(); it != vs.end(); ++it) {
    os << sep << *it;
    sep = L" ";
  }
  return os << L')';
}



template<typename T>
inline std::vector<T> operator+= (std::vector<T>& t, const std::vector<T>& v) {
  assert(t.size()==v.size());
  for (size_t i=0; i<v.size(); i++) {
    t[i]+=v[i];
  }
  return t;
}

template<typename T>
inline std::vector<T> operator+ (const std::vector<T>& t, const std::vector<T>& v) {
  std::vector<T> u;
  assert(t.size()==v.size());
  u.resize(v.size());
  for (size_t i=0; i<v.size(); i++) {
    u[i] = t[i]+v[i];
  }
  return u;
}

template<typename T>
inline std::vector<double> operator/ (const std::vector<T>& t, double d) {
  std::vector<double> u(t.size());
  for (size_t i=0; i<t.size(); i++) {
    u[i] = t[i]/d;
  }
  return u;
}


//returns a random double between 0 and n, inclusive
inline double randd (int n=1)
{return n * double(rand()) / RAND_MAX;}

// //returns a random int between 0 and n-1, inclusive
// inline int randi (int n)
// {return int(std::floor(n * double(rand()) / RAND_MAX));}

// //returns a random int between n and m, inclusive
// inline int randi (int n, int m)
// {return int(std::floor((m-n+1) * double(rand()) / RAND_MAX) + n);}

//returns 2 random gaussians
inline std::pair<double,double> rand_normals (double mean=0, double std=1) {
  double r1 = randd(1);
  double r2 = randd(1);
  return std::pair<double,double>(std*sqrt(-2*log(r1))*cos(2*M_PI*r2) + mean,
			   std*sqrt(-2*log(r1))*sin(2*M_PI*r2) + mean);
}

//returns 1 random gaussian
inline double rand_normal (double mean=0, double std=1) {
  double r1 = randd(1);
  double r2 = randd(1);
  return std*sqrt(-2*log(r1))*cos(2*M_PI*r2) + mean;
}

inline double normal_density (double val, double mean=0, double std=1) {
  return 1.0/(std*sqrt(2*M_PI)) * exp(-1*pow(val-mean,2)/(2*std*std));
}

inline double log_gamma_density(double x, double shape, double scale=1) {
  //note: gamma() and lgamma() both produce log of Gamma function.
  return (shape-1)*log(x) - shape*log(scale) - lgamma(shape) - x/scale;
}


// define some useful macros

#define HERE   __FILE__ << ":" << __LINE__ << " in " << __func__

#ifndef __STRING
#define __STRING(x) #x
#endif

#define TRACE(expr) std::wcerr << HERE << ", " << __STRING(expr) << " = " << (expr) << std::endl

#define TRACE1(expr) std::wcerr << HERE << ", " << __STRING(expr) << " = " << (expr) << std::endl

#define TRACE2(expr1, expr2)						     \
  std::wcerr << HERE                                                          \
            << ", " << __STRING(expr1) << " = " << (expr1)                   \
            << ", " << __STRING(expr2) << " = " << (expr2) << std::endl

#define TRACE3(expr1, expr2, expr3)					     \
  std::wcerr << HERE                                                          \
            << ", " << __STRING(expr1) << " = " << (expr1)                   \
            << ", " << __STRING(expr2) << " = " << (expr2)                   \
            << ", " << __STRING(expr3) << " = " << (expr3) << std::endl

#define TRACE4(expr1, expr2, expr3, expr4)				     \
  std::wcerr << HERE                                                          \
            << ", " << __STRING(expr1) << " = " << (expr1)                   \
            << ", " << __STRING(expr2) << " = " << (expr2)                   \
            << ", " << __STRING(expr3) << " = " << (expr3)                   \
            << ", " << __STRING(expr4) << " = " << (expr4) << std::endl

#define TRACE5(expr1, expr2, expr3, expr4, expr5)			     \
  std::wcerr << HERE                                                          \
            << ", " << __STRING(expr1) << " = " << (expr1)                   \
            << ", " << __STRING(expr2) << " = " << (expr2)                   \
            << ", " << __STRING(expr3) << " = " << (expr3)                   \
            << ", " << __STRING(expr4) << " = " << (expr4)                   \
            << ", " << __STRING(expr5) << " = " << (expr5) << std::endl

#define TRACE6(expr1, expr2, expr3, expr4, expr5, expr6)		     \
  std::wcerr << HERE                                                          \
            << ", " << __STRING(expr1) << " = " << (expr1)                   \
            << ", " << __STRING(expr2) << " = " << (expr2)                   \
            << ", " << __STRING(expr3) << " = " << (expr3)                   \
            << ", " << __STRING(expr4) << " = " << (expr4)                   \
            << ", " << __STRING(expr5) << " = " << (expr5)                   \
            << ", " << __STRING(expr6) << " = " << (expr6) << std::endl

#define TRACE7(expr1, expr2, expr3, expr4, expr5, expr6, expr7)		     \
  std::wcerr << HERE                                                          \
            << ", " << __STRING(expr1) << " = " << (expr1)                   \
            << ", " << __STRING(expr2) << " = " << (expr2)                   \
            << ", " << __STRING(expr3) << " = " << (expr3)                   \
            << ", " << __STRING(expr4) << " = " << (expr4)                   \
            << ", " << __STRING(expr5) << " = " << (expr5)                   \
            << ", " << __STRING(expr6) << " = " << (expr6)                   \
            << ", " << __STRING(expr7) << " = " << (expr7) << std::endl


#endif // UTIL_H
