// precrec.h  -- A framework for calculating precision, recall and f-score
//
// Mark Johnson, 23rd August 2007

#ifndef PRECREC_H
#define PRECREC_H

#include <iostream>
#include <cmath>


//! sum_second() returns the sum of the second components of a
//! container (e.g., a map)
template <typename XYs>
inline typename XYs::value_type::second_type sum_second(const XYs& xys)
{
    typename XYs::value_type::second_type sum = 0;
    for(const auto& item: xys)
        sum += item.second;
    return sum;
}

// dfind(Map, Key) returns the value Map associates with Key, or the
// Map's default value if no such Key exists
template <class Map, class Key>
inline typename Map::mapped_type dfind(const Map& m, const Key& k)
{
    typename Map::const_iterator i = m.find(k);
    if (i == m.end())
        return typename Map::mapped_type();
    else
        return i->second;
}


template <typename U=unsigned int, typename F=double>
struct basic_precrec_type
{
    typedef U unsigned_type;
    typedef F float_type;
    typedef basic_precrec_type<U,F> precrec_type;

    U ntest, ngold, ncorrect;

    F precision() const
        {
            return ntest > 0 ? F(ncorrect)/F(ntest) : F(0);
        }

    F recall() const
        {
            return ngold > 0 ? F(ncorrect)/F(ngold) : F(0);
        }

    F fscore() const
        {
            U n = ntest+ngold;
            return n > 0 ? 2.0*F(ncorrect)/F(n) : F(0);
        }

    explicit basic_precrec_type()
        : ntest(), ngold(), ncorrect()
        {}

    explicit basic_precrec_type(U nt, U ng, U nc)
        : ntest(nt), ngold(ng), ncorrect(nc)
        {}

    //! this static function constructs a precrec_type{} from a
    //! <key,count> map (i.e., it ignores the counts)
    template <typename TestKeyCounts, typename GoldKeyCounts>
    inline static precrec_type token_based(const TestKeyCounts& tkc, const GoldKeyCounts& gkc)
        {
            U ncorrect = 0;
            for(const auto& tit: tkc)
            {
                U t = tit.second;
                U g = dfind(gkc, tit.first);
                ncorrect += std::min(t, g);
            }

            return precrec_type(U(sum_second(tkc)), U(sum_second(gkc)), ncorrect);
        }

    //! this static function constructs a precrec_type{} from a
    //! <key,count> map using type-based information (i.e., it ignores
    //! the counts)
    template <typename TestKeyCounts, typename GoldKeyCounts>
    inline static precrec_type type_based(const TestKeyCounts& tkc, const GoldKeyCounts& gkc)
        {
            U ncorrect = 0;
            for(const auto& tit: tkc)
            {
                U t = tit.second;
                U g = dfind(gkc, tit.first);
                if (t > 0 and g > 0)
                    ++ncorrect;
            }
            return precrec_type(U(tkc.size()), U(gkc.size()), ncorrect);
        }
};

typedef basic_precrec_type<> precrec_type;

template <typename U, typename F>
inline std::wostream& operator<< (std::wostream& os, const basic_precrec_type<U, F>& pr)
{
    return os << "Precision=" << pr.precision() << "=" << pr.ncorrect << "/" << pr.ntest
              << ", Recall=" << pr.recall() << "=" << pr.ncorrect << "/" << pr.ngold
              << ", F-score=" << pr.fscore();
}


#endif
