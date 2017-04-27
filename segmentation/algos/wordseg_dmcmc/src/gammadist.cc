/*
  Copyright 2008 Mark Johnson, Brown University

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

#include <assert.h>
#include <math.h>

#include "gammadist.h"
#include "mt19937ar.h"

/* gammadist() returns the probability density of x under a
   Gamma(alpha,beta) distribution
*/
double gammadist(double x, double alpha, double beta)
{
    assert(alpha > 0);
    assert(beta > 0);
    return  pow(x/beta, alpha-1) * exp(-x/beta) / (tgamma(alpha)*beta);
}

/* lgammadist() returns the log probability density of x under a
   Gamma(alpha,beta) distribution
*/
double lgammadist(double x, double alpha, double beta)
{
    assert(alpha > 0);
    assert(beta > 0);
    return (alpha-1)*log(x) - alpha*log(beta) - x/beta - lgamma(alpha);
}

/* This definition of gammavariate is from Python code in the Python
   random module.
*/
double gammavariate(double alpha, double beta)
{
    assert(alpha > 0);
    assert(beta > 0);

    if (alpha > 1.0)
    {
        /* Uses R.C.H. Cheng, "The generation of Gamma variables with
           non-integral shape parameters", Applied Statistics, (1977), 26,
           No. 1, p71-74 */
        double ainv = sqrt(2.0 * alpha - 1.0);
        double bbb = alpha - log(4.0);
        double ccc = alpha + ainv;

        while (1)
        {
            double u1 = mt_genrand_real3();
            if (u1 > 1e-7  || u1 < 0.9999999)
            {
                double u2 = 1.0 - mt_genrand_real3();
                double v = log(u1/(1.0-u1))/ainv;
                double x = alpha*exp(v);
                double z = u1*u1*u2;
                double r = bbb+ccc*v-x;
                if (r + (1.0+log(4.5)) - 4.5*z >= 0.0 || r >= log(z))
                    return x * beta;
            }
        }
    }
    else if (alpha == 1.0)
    {
        double u = mt_genrand_real3();
        while (u <= 1e-7)
            u = mt_genrand_real3();
        return -log(u) * beta;
    }
    else
    {
        /* alpha is between 0 and 1 (exclusive)
           Uses ALGORITHM GS of Statistical Computing - Kennedy & Gentle */

        while (1)
        {
            double u = mt_genrand_real3();
            double b = (exp(1) + alpha)/exp(1);
            double p = b*u;
            double x = (p <= 1.0) ? pow(p, 1.0/alpha) : -log((b-p)/alpha);
            double u1 = mt_genrand_real3();
            if (! (((p <= 1.0) && (u1 > exp(-x))) ||
                   ((p > 1.0)  &&  (u1 > pow(x, alpha - 1.0)))))
                return x * beta;
        }
    }
}


/* betadist() returns the probability density of x under a
   Beta(alpha,beta) distribution.
*/
double betadist(double x, double alpha, double beta)
{
    assert(x >= 0);
    assert(x <= 1);
    assert(alpha > 0);
    assert(beta > 0);
    return pow(x,alpha-1)*pow(1-x,beta-1)*tgamma(alpha+beta)/(tgamma(alpha)*tgamma(beta));
}


/* lbetadist() returns the log probability density of x under a
   Beta(alpha,beta) distribution.
*/
double lbetadist(double x, double alpha, double beta)
{
    assert(x > 0);
    assert(x < 1);
    assert(alpha > 0);
    assert(beta > 0);
    return (alpha-1)*log(x)+(beta-1)*log(1-x)+lgamma(alpha+beta)-lgamma(alpha)-lgamma(beta);
}


/* betavariate() generates a sample from a Beta distribution with
   parameters alpha and beta.

   0 < alpha < 1, 0 < beta < 1, mean is alpha/(alpha+beta)
*/
double betavariate(double alpha, double beta)
{
    double x = gammavariate(alpha, 1);
    double y = gammavariate(beta, 1);
    return x/(x+y);
}
