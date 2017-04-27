/*
  Copyright 2006 Mark Johnson

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

#ifndef MT19937AR_H
#define MT19937AR_H

#ifdef __cplusplus
extern "C" {
#endif

  /* initializes mt[N] with a seed */
  void mt_init_genrand(unsigned long s);

  /* initialize by an array with array-length */
  /* init_key is the array for initializing keys */
  /* key_length is its length */
  /* slight change for C++, 2004/2/26 */
  void mt_init_by_array(unsigned long init_key[], int key_length);

  /* generates a random number on [0,0xffffffff]-interval */
  unsigned long mt_genrand_int32(void);

  /* generates a random number on [0,0x7fffffff]-interval */
  long mt_genrand_int31(void);

  /* generates a random number on [0,1]-real-interval */
  double mt_genrand_real1(void);

  /* generates a random number on [0,1)-real-interval */
  double mt_genrand_real2(void);

  /* generates a random number on (0,1)-real-interval */
  double mt_genrand_real3(void);

  /* generates a random number on [0,1) with 53-bit resolution*/
  double mt_genrand_res53(void);

#ifdef __cplusplus
};
#endif

#endif /* MT19937AR_H */
