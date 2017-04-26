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
#include <utility>
#include <vector>

#include <tr1/unordered_map>

inline void error(const char *s)
{ std::cerr << "error: " << s << std::endl; abort(); exit(1); }
inline void error(const std::string s) { error (s.c_str()); }
inline void warn(const char *s)
{ std::cerr << "warning: " << s << std::endl; }
inline void warn(const std::string s) { warn (s.c_str()); }

#ifdef NDEBUG
#define my_assert(X,Y) /* do nothing */
#else
#define my_assert(X,Y) if(!(X)){ std::wcerr << "data is " << (Y) << std::endl; assert(X); }
#endif


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

// computes the mean of items in positions begin through end
// (incl. begin, not incl. end).
template<typename T>
inline double mean (std::vector<T>& v, size_t begin=0, size_t end=0) {
  if (end == 0) end = v.size();
  assert(begin < end);
  double t=0;
  for (size_t i=begin; i<end; i++) {
    t+=v[i];
  }
  return t/(end-begin);
}

template<typename T>
inline double stdev (std::vector<T>& v) {
  double m=mean(v);
  double t=0;
  for (size_t i=0; i<v.size(); i++) {
    t+=(v[i]-m)*(v[i]-m);
  }
  return sqrt(t/v.size());
}

//returns a random double between 0 and n, inclusive
inline double randd (int n=1) 
{return n * double(rand()) / RAND_MAX;}

//returns a random int between 0 and n-1, inclusive
inline int randi (int n) 
{return int(floor(n * double(rand()) / RAND_MAX));}

//returns a random int between n and m, inclusive
inline int randi (int n, int m) 
{return int(floor((m-n+1) * double(rand()) / RAND_MAX) + n);}

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

#if (__GNUC__ > 3) || (__GNUC__ >= 3 && __GNUC_MINOR__ >= 1)
#define EXT_NAMESPACE __gnu_cxx
#else
#define EXT_NAMESPACE std
#endif

namespace ext = EXT_NAMESPACE;

namespace tr1 = std::tr1;

///////////////////////////////////////////////////////////////////////////
//                                                                       //
//                              Looping constructs                       //
//                                                                       //
///////////////////////////////////////////////////////////////////////////

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



namespace util {

  ///////////////////////////////////////////////////////////////////////////
  //                                                                       //
  //                             Map searching                             //
  //                                                                       //
  // dfind(map, key) returns the key's value in map, or map's default      //
  //   value if no such key exists (the default value is not inserted)     //
  //                                                                       //
  // afind(map, key) returns a reference to the key's value in map, and    //
  //    asserts that this value exists                                     //
  //                                                                       //
  ///////////////////////////////////////////////////////////////////////////

  //! dfind(Map, Key) returns the value Map associates with Key, or the
  //!  Map's default value if no such Key exists
  //
  template <class Map, class Key>
  inline typename Map::mapped_type dfind(const Map& m, const Key& k)
  {
    typename Map::const_iterator i = m.find(k);
    if (i == m.end())
      return typename Map::mapped_type();
    else
      return i->second;
  }  // util::dfind()

  //! afind(map, key) returns a reference to the value associated
  //!  with key in map.  It uses assert to check that the key's value
  //!  is defined.
  //
  template <class Map, class Key>
  inline typename Map::mapped_type& afind(Map& m, const Key& k)
  {
    typename Map::iterator i = m.find(k);
    assert(i != m.end());
    return i->second;
  }  // util::afind()

  template <class Map, class Key>
  inline const typename Map::mapped_type& afind(const Map& m, const Key& k)
  {
    typename Map::const_iterator i = m.find(k);
    assert(i != m.end());
    return i->second;
  }  // util::afind()

  //! incr() increments the value associated with key in map, deleting the key,value
  //! pair if the incremented value is zero.
  //
  template <typename Map, typename Key, typename Inc>
  inline typename Map::mapped_type incr(Map& m, const Key& k, Inc i) {
    std::pair<typename Map::iterator, bool> itb = m.insert(typename Map::value_type(k,i));
    if (itb.second==false && (itb.first->second += i) == typename Map::mapped_type()) {
      m.erase(itb.first);
      return typename Map::mapped_type();
    }
    else
      return itb.first->second;    
  }  // util::incr()

  template <typename Map, typename Key>
  inline typename Map::mapped_type incr(Map& m, const Key& k) { return incr(m, k, 1); }

  //! insert_newkey(map, key, value) checks that map does not contain
  //! key, and binds key to value.
  //
  template <class Map, class Key, class Value>
  inline typename Map::value_type& 
  insert_newkey(Map& m, const Key& k,const Value& v) 
  {
    std::pair<typename Map::iterator, bool> itb 
      = m.insert(Map::value_type(k, v));
    assert(itb.second);
    return *(itb.first);
  }  // util::insert_newkey()

  ///////////////////////////////////////////////////////////////////////////
  //                                                                       //
  //                  insert and increment iterators                       //
  //                                                                       //
  ///////////////////////////////////////////////////////////////////////////

  //! An assoc_insert_iterator inserts an object into an associative container.
  //! This implementation is based on the Josuttis "The C++ Standard Library", p 289.
  //
  template <typename Container>
  class assoc_insert_iterator : public std::iterator<std::output_iterator_tag,void,void,void,void> 
  {
  protected:
    Container& container;           //!< container into which objects are inserted
    
  public:
    explicit assoc_insert_iterator(Container& c) : container(c) { }

    //! operator= inserts value into container
    //
    assoc_insert_iterator<Container>& 
    operator= (const typename Container::value_type& value) {
      container.insert(value);
      return *this;
    }

    //! operator* is a no-op that returns the iterator
    //
    assoc_insert_iterator<Container>& operator* () { return *this; }

    //! operator++ is a no-op that returns the iterator
    //
    assoc_insert_iterator<Container>& operator++ () { return *this; }

    //! operator++ is a no-op that returns the iterator
    //
    assoc_insert_iterator<Container>& operator++ (int) { return *this; }
    
  };  // util::assoc_insert_iterator{}

  //! inserter() selects the right kind of insert_iterator for this container
  //
  template <typename Key, typename Value> inline assoc_insert_iterator<tr1::unordered_map<Key,Value> > 
  inserter(tr1::unordered_map<Key,Value>& c) {
    return assoc_insert_iterator<tr1::unordered_map<Key,Value> >(c);
  }  // util::inserter()

  template <typename Key, typename Value> inline assoc_insert_iterator<std::map<Key,Value> > 
  inserter(std::map<Key,Value>& c) {
    return assoc_insert_iterator<std::map<Key,Value> >(c);
  }  // util::inserter()

  template <typename X> inline std::back_insert_iterator<std::vector<X> >
  inserter(std::vector<X>& c) {
    return std::back_insert_iterator<std::vector<X> >(c);
  }  // util::inserter()

  //! An assoc_increment_iterator increments the count associated with a key by 1
  //
  template <typename Container>
  class assoc_increment_iterator : public std::iterator<std::output_iterator_tag,void,void,void,void> 
  {
  protected:
    Container& container;           //!< container into which objects are inserted
    
  public:
    explicit assoc_increment_iterator(Container& c) : container(c) { }

    //! operator= inserts value into container
    //
    assoc_increment_iterator<Container>& 
    operator= (const typename Container::key_type& key) {
      incr(container, key);
      return *this;
    }

    //! operator* is a no-op that returns the iterator
    //
    assoc_increment_iterator<Container>& operator* () { return *this; }

    //! operator++ is a no-op that returns the iterator
    //
    assoc_increment_iterator<Container>& operator++ () { return *this; }

    //! operator++ is a no-op that returns the iterator
    //
    assoc_increment_iterator<Container>& operator++ (int) { return *this; }
    
  };  // util::assoc_increment_iterator{}

  //! incrementer() selects the right kind of increment_iterator for this container
  //
  template <typename Key, typename Value> inline assoc_increment_iterator<tr1::unordered_map<Key,Value> > 
  incrementer(tr1::unordered_map<Key,Value>& c) {
    return assoc_increment_iterator<tr1::unordered_map<Key,Value> >(c);
  }  // util::incrementer()

  template <typename Key, typename Value> inline assoc_increment_iterator<std::map<Key,Value> > 
  incrementer(std::map<Key,Value>& c) {
    return assoc_increment_iterator<std::map<Key,Value> >(c);
  }  // util::incrementer()

  
  ///////////////////////////////////////////////////////////////////////////
  //                                                                       //
  //               simplified interface to standard functions              //
  //                                                                       //
  ///////////////////////////////////////////////////////////////////////////

  //! sum() returns the sum of elements in a container
  //
  template <typename Xs> inline typename Xs::value_type 
  sum(const Xs& xs) {
    typedef typename Xs::value_type X;
    return std::accumulate(xs.begin(), xs.end(), X(), std::plus<X>());
  }  // util::sum()

  //! sum_second() returns the sum of the second components of a container (e.g., a map)
  //
  template <typename XYs> inline typename XYs::value_type::second_type
  sum_second(const XYs& xys) {
    typename XYs::value_type::second_type sum=0;
    cforeach (typename XYs, it, xys)
      sum += it->second;
    return sum;
  }  // util::sum_second()

  //! copy() appends all of the elements in Xs onto the end of Ys
  //
  template <typename Xs, typename Ys> void
  copy(const Xs& xs, Ys& ys) {
    std::copy(xs.begin(), xs.end(), inserter(ys));
  }  // util::copy()

  //! sort() sorts all of the elements in a container
  //
  template <typename Xs> inline void
  sort(Xs& xs) {
    std::sort(xs.begin(), xs.end());
  }  // util::sort()

  //! sort() sorts all of the elements in a container ordered by comp
  //
  template <typename Xs, typename Comp> inline void
  sort(Xs& xs, Comp comp) {
    std::sort(xs.begin(), xs.end(), comp);
  }  // util::sort()

  //! partial_sum() replaces each element in a container with the sum of its
  //! value and all preceding elements.  This is the first step in selecting
  //! an element from an urn.
  //
  template <typename Vs> inline void
  partial_sum(Vs& vs) {
    std::partial_sum(vs.begin(), vs.end(), vs.begin());
  }

  //! lower_bound() returns the largest index i such that vs[i] <= bound.
  //! This is the second step in selecting an element from an urn.
  //
  template <typename Vs, typename V> inline unsigned int
  lower_bound(const Vs& vs, const V bound) {
    typename Vs::const_iterator it = std::lower_bound(vs.begin(), vs.end(), bound);
    return it - vs.begin();
  }

  ///////////////////////////////////////////////////////////////////////////
  //                                                                       //
  //                       comparison functions                            //
  //                                                                       //
  ///////////////////////////////////////////////////////////////////////////

  //! first_lessthan()(e1, e2) iff e1.first < e2.first
  //
  struct first_lessthan {
    template <typename T1, typename T2>
    bool operator() (const T1& e1, const T2& e2) {
      return e1.first < e2.first;
    }
  };

  struct second_lessthan {
    template <typename T1, typename T2>
    bool operator() (const T1& e1, const T2& e2) {
      return e1.second < e2.second;
    }
  };

  struct first_greaterthan {
    template <typename T1, typename T2>
    bool operator() (const T1& e1, const T2& e2) {
      return e1.first > e2.first;
    }
  };

  struct second_greaterthan {
    template <typename T1, typename T2>
    bool operator() (const T1& e1, const T2& e2) {
      return e1.second > e2.second;
    }
  };

  ///////////////////////////////////////////////////////////////////////////
  //                                                                       //
  //                          useful functions                             //
  //                                                                       //
  ///////////////////////////////////////////////////////////////////////////

  //! trim_capacity() reallocates a vector to contain just the allocated elements
  //
  template <typename X>
  void trim_capacity(std::vector<X>& xs) {
    std::vector<X>(xs).swap(xs);
  }  // util::trim_capacity()

  //! randseed() returns an integer based on the time, to be used as a random number seed
  //
  inline unsigned int randseed() {
    time_t t;
    return time(&t);
  }  // util::randseed()

  //! split() parses a string by repeatedly reading a value of type Xs::value_type from it and
  //! pushing it onto xs.  It returns the number of characters read from the string.
  //
  template <typename CharT, typename Traits, typename Alloc, typename Xs>
  std::ios::pos_type split(const std::basic_string<CharT,Traits,Alloc>& str, Xs& xs) {
    std::basic_istringstream<CharT,Traits> is(str);
    typename Xs::value_type x;
    while (is >> x)
      xs.push_back(x);
    return is.tellg();
  }  // util::split()

  ///////////////////////////////////////////////////////////////////////////
  //                                                                       //
  //                          useful predicates                            //
  //                                                                       //
  ///////////////////////////////////////////////////////////////////////////

  //! approx_equal() is true of two real numbers if their relative difference
  //! is less than tol
  //
  inline bool approx_equal(double x1, double x2, double rtol=1e-7) {
    return (2*fabs(x1 - x2) < rtol * (fabs(x1) + fabs(x2)));
  }

  //! equal_contents() is true of two unordered_maps if their sorted contents
  //! are the same
  //
  template <typename K, typename V>
  bool equal_contents(const tr1::unordered_map<K,V>& m1, const tr1::unordered_map<K,V>& m2) {
    if (m1.size() != m2.size())   // quick failure test
      return false;
    typedef std::pair<K,V> KV;
    typedef std::vector<KV> KVs;
    KVs kvs1, kvs2;
    std::copy(m1.begin(), m1.end(), std::back_inserter(kvs1));
    assert(m1.size() == kvs1.size());
    std::sort(kvs1.begin(), kvs1.end());
    std::copy(m2.begin(), m2.end(), std::back_inserter(kvs2));
    assert(m2.size() == kvs2.size());
    std::sort(kvs2.begin(), kvs2.end());
    return kvs1 == kvs2;
  }

  ///////////////////////////////////////////////////////////////////////////
  //                                                                       //
  //                          IO stream functions                          //
  //                                                                       //
  ///////////////////////////////////////////////////////////////////////////
  
  //! Standard stream doesn't provide default conversion of narrow to wide.
  //
//  inline std::wostream& operator<< (std::wostream & ostr,
//     std::string const & str )
//  {
////     std::copy(str.begin(), str.end(),
////        std::ostream_iterator<std::wchar_t>(ostr) );
//     return ostr;
//  }

  //! exit_failure() causes the program to halt immediately
  //
  inline std::wostream& exit_failure(std::wostream& os) {
    os << std::endl;
    exit(EXIT_FAILURE);
    return os;
  }  // util::exit_failure

  //! date() prints the current date to the stream
  //
  inline std::wostream& date(std::wostream& os) {
    time_t t;
    time(&t);
    return os << ctime(&t);
  }  // util::date()

  ///////////////////////////////////////////////////////////////////////////
  //                                                                       //
  //                             subsequence                               //
  //                                                                       //
  ///////////////////////////////////////////////////////////////////////////

  //!< A subsequence is a contiguous subsequence of another sequence
  //
  template <typename Iterator>
  struct subsequence {
    typedef Iterator iterator;
    typedef typename std::iterator_traits<Iterator> value_type;

    Iterator first;   //!< value of begin()
    Iterator second;  //!< value of end()

    subsequence(Iterator first, Iterator second) : first(first), second(second) { }
    subsequence(Iterator start, size_t size) : first(start) { std::advance(start, size); second=start; }

    Iterator begin() const { return first; }
    Iterator end() const { return second; }

    template <typename Container>
    bool operator== (const Container& c) const {
      iterator it0  = begin();
      typename Container::iterator it1 = c.begin();
      while (it0 != end()) 
	if (it1 == c.end() || *it0++ != *it1++)
	  return false;
      return it1 == c.end();
    }  // util::subsequence::operator== ()

    template <typename Container>
    bool operator!= (const Container& c) const {
      return ! operator==(c);
    }  // util::subsequence::operator!= ()

    template <typename Container>
    bool operator< (const Container& c) const { 
      return std::lexicographical_compare(begin(), end(), c.begin(), c.end()); 
    }  // util::subsequence::operator< ()

    template <typename Container>
    bool operator> (const Container& c) const { 
      return std::lexicographical_compare(c.begin(), c.end(), begin(), end()); 
    }  // util::subsequence::operator< ()

    //! hash() computes a hash function for the container
    //
    size_t hash() const {
      size_t h = 0; 
      size_t g;
      iterator p = begin();
      while (p != end()) {
	h = (h << 4) + (*p++);
	if ((g = h&0xf0000000)) {
	  h = h ^ (g >> 24);
	  h = h ^ g;
	}}
      return size_t(h);
    }  // util::subsequence::hash()

  };  // util::subsequence{}
  
}  // namespace util


///////////////////////////////////////////////////////////////////////////
//                                                                       //
//                             Hash functions                            //
//                                                                       //
///////////////////////////////////////////////////////////////////////////

namespace std { namespace tr1 {

  template <typename Iterator> struct hash<util::subsequence<Iterator> >
    : public std::unary_function<util::subsequence<Iterator>, std::size_t> {
    std::size_t operator() (const util::subsequence<Iterator>& s) { return s.hash(); }
  };  // std::tr1::hash<util::subsequence>{}

  //! hash function for arbitrary pairs.  This is actually not such a great hash;
  //! particularly if the pairs are used to build arbitrary trees.
  //
  template <typename T1, typename T2> struct hash<std::pair<T1,T2> >
    : public std::unary_function<std::pair<T1,T2>, std::size_t> {
    std::size_t operator() (const std::pair<T1,T2>& p) const {
      std::size_t h1 = hash<T1>()(p.first);
      std::size_t h2 = hash<T2>()(p.second);
      return h1 ^ (h1 >> 1) ^ h2 ^ (h2 << 1);
    }
  };  // std::tr1::hash<std::pair<T1,T2> >

} }  // namespace std::tr1

///////////////////////////////////////////////////////////////////////////
//                                                                       //
//                           Output functions                            //
//                                                                       //
///////////////////////////////////////////////////////////////////////////

template <typename X, typename Y>
std::wostream& operator<< (std::wostream& os, const std::pair<X,Y>& xy) {
  return os << '(' << xy.first << ' ' << xy.second << ')';
}

template <typename Key, typename Value>
std::wostream& operator<< (std::wostream& os, const std::tr1::unordered_map<Key,Value>& k_v) {
  os << '(';
  const wchar_t* sep = "";
  for (typename tr1::unordered_map<Key,Value>::const_iterator it=k_v.begin(); it!=k_v.end(); ++it) {
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



///////////////////////////////////////////////////////////////////////////
//                                                                       //
//                            Input functions                            //
//                                                                       //
///////////////////////////////////////////////////////////////////////////

//! istream >> const char* consumes the characters from the istream.  
//! Just as in scanf, a space consumes an arbitrary amount of whitespace.
//
inline std::istream& operator>> (std::istream& is, const char* cp)
{
  if (*cp == '\0')
    return is;
  else if (*cp == ' ') {
    char c;
    if (is.get(c)) {
      if (isspace(c))
	return is >> cp;
      else {
	is.unget();
	return is >> (cp+1);
      }
    }
    else {
      is.clear(is.rdstate() & ~std::ios::failbit);  // clear failbit
      return is >> (cp+1);
    }
  }
  else {
    char c;
    if (is.get(c)) {
      if (c == *cp)
	return is >> (cp+1);
      else {
	is.unget();
	is.setstate(std::ios::failbit);
      }
    }
    return is;
  }
}

#endif // UTIL_H
