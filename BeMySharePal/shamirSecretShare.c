
// GLibFacade.h---------------------------------------------------------------------------------------------------------------

/*
 *	GLibFacade.h
 *	MultiMarkdown
 *	
 *		https://github.com/fletcher/MultiMarkdown-4/
 *
 *	Created by Daniel Jalkut on 7/26/11.
 *	Copyright 2011 __MyCompanyName__. All rights reserved.
 */

#ifndef __MARKDOWN_GLIB_FACADE__
#define __MARKDOWN_GLIB_FACADE__

/* peg_markdown uses the link symbol for its own purposes */
#define link MARKDOWN_LINK_IGNORED
#include <unistd.h>
#undef link

#include <stdbool.h>
#include <ctype.h>

typedef int gboolean;
typedef char gchar;

/* This style of bool is used in shared source code */
#define FALSE false
#define TRUE true

/** @brief Minimal replacement for GLib's GString class.
 *  
 *
 * WE implement minimal mirror implementations of GLib's GString and GSList 
 * sufficient to cover the functionality required by MultiMarkdown.
 *
 * NOTE: THese are 100% clean, from-scratch implementations using only the 
 * GLib function prototype as guide for behavior.
 */

typedef struct 
{	
	/* Current UTF8 byte stream this string represents */
	char* str;

	/* Where in the str buffer will we add new characters */
	/* or append new strings? */
	int currentStringBufferSize;
	int currentStringLength;
} GString;

GString* g_string_new(char *startingString);
char* g_string_free(GString* ripString, bool freeCharacterData);

void g_string_append_c(GString* baseString, char appendedCharacter);
void g_string_append(GString* baseString, char *appendedString);

void g_string_prepend(GString* baseString, char* prependedString);

void g_string_append_printf(GString* baseString, char* format, ...);

/* Just implement a very simple singly linked list. */

typedef struct _GSList
{
	void* data;	
	struct _GSList* next;
} GSList;

void g_slist_free(GSList* ripList);
GSList* g_slist_prepend(GSList* targetElement, void* newElementData);
GSList* g_slist_reverse(GSList* theList);

#endif

//GLibFacade.c------------------------------------------------------------------------------------------------------------------------------------------

/*
 *	GLibFacade.c
 *	MultiMarkdown
 *	
 *		https://github.com/fletcher/MultiMarkdown-4/
 *
 *	Created by Daniel Jalkut on 7/26/11.
 *  Modified by Fletcher T. Penney on 9/15/11.
 *  Modified by Dan Lowe on 1/3/12.
 *	Copyright 2011 __MyCompanyName__. All rights reserved.
 */

//#include "GLibFacade.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

/*
 * The following section came from:
 *
 *	http://lists-archives.org/mingw-users/12649-asprintf-missing-vsnprintf-
 *		behaving-differently-and-_vsncprintf-undefined.html
 *
 * and
 *
 *	http://groups.google.com/group/jansson-users/browse_thread/thread/
 *		76a88d63d9519978/041a7d0570de2d48?lnk=raot
 */

/* Solaris and Windows do not provide vasprintf() or asprintf(). */
#if defined(__WIN32) || (defined(__SVR4) && defined(__sun))
int vasprintf( char **sptr, char *fmt, va_list argv ) 
{ 
    int wanted = vsnprintf( *sptr = NULL, 0, fmt, argv ); 
    if( (wanted > 0) && ((*sptr = malloc( 1 + wanted )) != NULL) ) 
        return vsprintf( *sptr, fmt, argv ); 
 
    return wanted; 
} 
 
int asprintf( char **sptr, char *fmt, ... ) 
{ 
    int retval; 
    va_list argv; 
    va_start( argv, fmt ); 
    retval = vasprintf( sptr, fmt, argv ); 
    va_end( argv ); 
    return retval; 
} 
#endif


/* GString */

#define kStringBufferStartingSize 1024
#define kStringBufferGrowthMultiplier 2

GString* g_string_new(char *startingString)
{
	GString* newString = malloc(sizeof(GString));

	if (startingString == NULL) startingString = "";

	size_t startingBufferSize = kStringBufferStartingSize;
	size_t startingStringSize = strlen(startingString);
	while (startingBufferSize < (startingStringSize + 1))
	{
		startingBufferSize *= kStringBufferGrowthMultiplier;
	}
	
	newString->str = malloc(startingBufferSize);
	newString->currentStringBufferSize = startingBufferSize;
	strncpy(newString->str, startingString, startingStringSize);
	newString->str[startingStringSize] = '\0';
	newString->currentStringLength = startingStringSize;
	
	return newString;
}

char* g_string_free(GString* ripString, bool freeCharacterData)
{	
	char* returnedString = ripString->str;
	if (freeCharacterData)
	{
		if (ripString->str != NULL)
		{
			free(ripString->str);
		}
		returnedString = NULL;
	}
	
	free(ripString);
	
	return returnedString;
}

static void ensureStringBufferCanHold(GString* baseString, size_t newStringSize)
{
	size_t newBufferSizeNeeded = newStringSize + 1;
	if (newBufferSizeNeeded > baseString->currentStringBufferSize)
	{
		size_t newBufferSize = baseString->currentStringBufferSize;	

		while (newBufferSizeNeeded > newBufferSize)
		{
			newBufferSize *= kStringBufferGrowthMultiplier;
		}
		
		baseString->str = realloc(baseString->str, newBufferSize);
		baseString->currentStringBufferSize = newBufferSize;
	}
}

void g_string_append(GString* baseString, char* appendedString)
{
	if ((appendedString != NULL) && (strlen(appendedString) > 0))
	{
		size_t appendedStringLength = strlen(appendedString);
		size_t newStringLength = baseString->currentStringLength + appendedStringLength;
		ensureStringBufferCanHold(baseString, newStringLength);

		/* We already know where the current string ends, so pass that as the starting address for strncat */
		strncat(baseString->str + baseString->currentStringLength, appendedString, appendedStringLength);
		baseString->currentStringLength = newStringLength;
	}
}

void g_string_append_c(GString* baseString, char appendedCharacter)
{	
	size_t newSizeNeeded = baseString->currentStringLength + 1;
	ensureStringBufferCanHold(baseString, newSizeNeeded);
	
	baseString->str[baseString->currentStringLength] = appendedCharacter;
	baseString->currentStringLength++;	
	baseString->str[baseString->currentStringLength] = '\0';
}

void g_string_append_printf(GString* baseString, char* format, ...)
{
	va_list args;
	va_start(args, format);
	
	char* formattedString = NULL;
	vasprintf(&formattedString, format, args);
	if (formattedString != NULL)
	{
		g_string_append(baseString, formattedString);
		free(formattedString);
	}
	va_end(args);
} 

void g_string_prepend(GString* baseString, char* prependedString)
{
	if ((prependedString != NULL) && (strlen(prependedString) > 0))
	{
		size_t prependedStringLength = strlen(prependedString);
		size_t newStringLength = baseString->currentStringLength + prependedStringLength;
		ensureStringBufferCanHold(baseString, newStringLength);

		memmove(baseString->str + prependedStringLength, baseString->str, baseString->currentStringLength);
		strncpy(baseString->str, prependedString, prependedStringLength);
		baseString->currentStringLength = newStringLength;
		baseString->str[baseString->currentStringLength] = '\0';
	}
}

/* GSList */

void g_slist_free(GSList* ripList)
{
	GSList* thisListItem = ripList;
	while (thisListItem != NULL)
	{
		GSList* nextItem = thisListItem->next;
		
		/* I guess we don't release the data? Non-retained memory management is hard... let's figure it out later. */
		free(thisListItem);
		
		thisListItem = nextItem;
	}
}

/* Currently only used for markdown_output.c endnotes printing */
GSList* g_slist_reverse(GSList* theList)
{	
	GSList* lastNodeSeen = NULL;
	
	/* Iterate the list items, tacking them on to our new reversed List as we find them */
	GSList* listWalker = theList;
	while (listWalker != NULL)
	{
		GSList* nextNode = listWalker->next;
		listWalker->next = lastNodeSeen;
		lastNodeSeen = listWalker;
		listWalker = nextNode;
	}
	
	return lastNodeSeen;
}

GSList* g_slist_prepend(GSList* targetElement, void* newElementData)
{
	GSList* newElement = malloc(sizeof(GSList));
	newElement->data = newElementData;
	newElement->next = targetElement;
	return newElement;
}

//strtok.h---------------------------------------------------------------------------------------------------------------------------------------------
/* This file is only included since MINGW doesn't have strtok_r, so I can't
   compile for Windows without this */

#include <string.h>

char* strtok_rr(
    char *str, 
    const char *delim, 
    char **nextp);


// strtok.c-------------------------------------------------------------------------------------------------------------------------------

/* 
 * public domain strtok_r() by Charlie Gordon
 *
 *   from comp.lang.c  9/14/2007
 *
 *      http://groups.google.com/group/comp.lang.c/msg/2ab1ecbb86646684
 *
 *     (Declaration that it's public domain):
 *      http://groups.google.com/group/comp.lang.c/msg/7c7b39328fefab9c
 */

/* This file is only included since MINGW doesn't have strtok_r, so I can't
   compile for Windows without this */

/* Also, fixed by Fletcher T. Penney --- added the "return NULL" when *nextp == NULL */

/* This fix is also in the public domain */

//#include "strtok.h"

char* strtok_rr(
    char *str, 
    const char *delim, 
    char **nextp)
{
    char *ret;

    if (str == NULL)
    {
        str = *nextp;
    }

	if (str == NULL) {
		return NULL;
	}

    str += strspn(str, delim);

    if (*str == '\0')
    {
        return NULL;
    }

    ret = str;

    str += strcspn(str, delim);

    if (*str)
    {
        *str++ = '\0';
    }

    *nextp = str;

    return ret;
}


//shamir.h--------------------------------------------------------------------------------------------------
#ifndef SHAMIRS_SECRET_SHARING_H
#define SHAMIRS_SECRET_SHARING_H

//#include "strtok.h"

#ifdef TEST
#include "CuTest.h"
#endif

/** 

@file

@brief Simple library for providing SSS functionality.


*/

/// Seed the random number generator.  MUST BE CALLED before using the library (unless on arc4random() system).
void seed_random(void);

/// Given a secret, `n`, and `t`, create a list of shares (`\n` separated).
char * generate_share_strings(char * secret, int n, int t);

/// Given a list of shares (`\n` separated without leading whitespace), recreate the original secret.
char * extract_secret_from_share_strings(const char * string);

#endif


//shamir.c--------------------------------------------------------------------------------------------------
/*

	shamir.c -- Shamir's Secret Sharing

	Inspired by:

		http://en.wikipedia.org/wiki/Shamir's_Secret_Sharing#Javascript_example


	Compatible with:

		http://www.christophedavid.org/w/c/w.php/Calculators/ShamirSecretSharing

	Notes:

		* The secrets start with 'AABBCC'
		* 'AA' is the hex encoded share # (1 - 255)
		* 'BB' is the threshold # of shares, also in hex
		* 'CC' is fake for compatibility with the web implementation above (= 'AA')
		* Remaining characters are encoded 1 byte = 2 hex characters, plus
			'G0' = 256 (since we use 257 prime modulus)

	Limitations:

		* rand() needs to be seeded before use (see below)


	Copyright © 2015 Fletcher T. Penney. Licensed under the MIT License.

	## The MIT License ##

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
*/

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <string.h>
#include <math.h>
#include <unistd.h>

//#include "shamir.h"


static int prime = 257;	


/*
	http://stackoverflow.com/questions/322938/recommended-way-to-initialize-srand

	http://www.concentric.net/~Ttwang/tech/inthash.htm
	
	Need a less predictable way to seed rand().
*/

unsigned long mix(unsigned long a, unsigned long b, unsigned long c)
{
    a=a-b;  a=a-c;  a=a^(c >> 13);
    b=b-c;  b=b-a;  b=b^(a << 8);
    c=c-a;  c=c-b;  c=c^(b >> 13);
    a=a-b;  a=a-c;  a=a^(c >> 12);
    b=b-c;  b=b-a;  b=b^(a << 16);
    c=c-a;  c=c-b;  c=c^(b >> 5);
    a=a-b;  a=a-c;  a=a^(c >> 3);
    b=b-c;  b=b-a;  b=b^(a << 10);
    c=c-a;  c=c-b;  c=c^(b >> 15);
    return c;
}

void seed_random(void) {
	unsigned long seed = mix(clock(), time(NULL), getpid());
	srand(seed);
}

/*
	from http://stackoverflow.com/questions/18730071/c-programming-to-calculate-using-modular-exponentiation

	Allows working with larger numbers (e.g. 255 shares, with a threshold of 200)
*/

int modular_exponentiation(int base,int exp,int mod)
{
    if (exp == 0)
        return 1;
	else if (exp%2 == 0) {
        int mysqrt = modular_exponentiation(base, exp/2, mod);
        return (mysqrt*mysqrt)%mod;
    }
    else
        return (base * modular_exponentiation(base, exp-1, mod))%mod;
}



/*
	split_number() -- Split a number into shares
	n = the number of shares
	t = threshold shares to recreate the number
*/

int * split_number(int number, int n, int t) {
	int * shares = malloc(sizeof(int)*n);

	int coef[t];
	int x;
	int i;

	coef[0] = number;

	for (i = 1; i < t; ++i)
	{
		/* Generate random coefficients -- use arc4random if available */
#if defined (HAVE_ARC4RANDOM)
		coef[i] = arc4random_uniform(prime - 1);
#else
		coef[i] = rand() % (prime - 1);
#endif
	}

	for (x = 0; x < n; ++x)
	{
		int y = coef[0];

		/* Calculate the shares */
		for (i = 1; i < t; ++i)
		{
			int temp = modular_exponentiation(x+1, i, prime);

			y = (y + (coef[i] * temp % prime)) % prime;
		}

		/* Sometimes we're getting negative numbers, and need to fix that */
		y = (y + prime) % prime;

		shares[x] = y;
	}

	return shares;
}

#ifdef TEST
void Test_split_number(CuTest* tc) {

	seed_random();

	int * test = split_number(1234, 50, 20);

	//printf("Split\n1: %d\n2: %d\n3: %d\n4: %d\n5: %d\n6: %d\n", *test, *(test+1), *(test+2),
	//	*(test+3),*(test+4),*(test+5));

	free(test);

	CuAssertIntEquals(tc, 0, 0);
}
#endif


/*
	Math stuff
*/

int * gcdD(int a, int b) {
	int * xyz = malloc(sizeof(int) * 3);

	if (b == 0) {
		xyz[0] = a;
		xyz[1] = 1;
		xyz[2] = 0;
	} else {
		int n = floor(a/b);
		int c = a % b;
		int *r = gcdD(b,c);

		xyz[0] = r[0];
		xyz[1] = r[2];
		xyz[2] = r[1]-r[2]*n;

		free(r);
	}

	return xyz;
}


/*
	More math stuff
*/

int modInverse(int k) {
	k = k % prime;

	int r;
	int * xyz;

	if (k < 0) {
		xyz = gcdD(prime,-k);
		r = -xyz[2];
	} else {
		xyz = gcdD(prime, k);
		r = xyz[2];
	}

	free(xyz);

	return (prime + r) % prime;
}


/*
	join_shares() -- join some shares to retrieve the secret
	xy_pairs is array of int pairs, first is x, second is y
	n is number of pairs submitted
*/

int join_shares(int *xy_pairs, int n) {
	int secret = 0;
	long numerator;
	long denominator;
	long startposition;
	long nextposition;
	long value;
	int i;
	int j;

	for (i = 0; i < n; ++i)
	{
		numerator = 1;
		denominator = 1;
		for (j = 0; j < n; ++j)
		{
			if(i != j) {
				startposition = xy_pairs[i*2];
				nextposition = xy_pairs[j*2];
				numerator = (numerator * -nextposition) % prime;
				denominator = (denominator * (startposition - nextposition)) % prime;
				//fprintf(stderr, "Num: %lli\nDen: %lli\n", numerator, denominator);
			}
		}

		value = xy_pairs[i * 2 + 1];

		secret = (secret + (value * numerator * modInverse(denominator))) % prime;
	}

	/* Sometimes we're getting negative numbers, and need to fix that */
	secret = (secret + prime) % prime;

	return secret;
}


#ifdef TEST
void Test_join_shares(CuTest* tc) {
	int n = 200;
	int t = 100;

	int shares[n*2];

	int count = 255;	/* How many times should we test it? */
	int j;

	for (j = 0; j < count; ++j)
	{
		int * test = split_number(j, n, t);
		int i;

		for (i = 0; i < n; ++i)
		{
			shares[i*2] = i + 1;
			shares[i*2 + 1] = test[i];
		}

		/* Send all n shares */
		int result = join_shares(shares, n);

		free(test);

		CuAssertIntEquals(tc, j, result);
	}
}
#endif


/*
	split_string() -- Divide a string into shares
	return an array of pointers to strings;
*/

char ** split_string(char * secret, int n, int t) {
	int len = strlen(secret);

	char ** shares = malloc (sizeof(char *) * n);
	int i;

	for (i = 0; i < n; ++i)
	{
		/* need two characters to encode each character */
		/* Need 4 character overhead for share # and quorum # */
		/* Additional 2 characters are for compatibility with:
		
			http://www.christophedavid.org/w/c/w.php/Calculators/ShamirSecretSharing
		*/
		shares[i] = (char *) malloc(2*len + 6 + 1);

		sprintf(shares[i], "%02X%02XAA",(i+1),t);
	}

	/* Now, handle the secret */

	for (i = 0; i < len; ++i)
	{
		// fprintf(stderr, "char %c: %d\n", secret[i], (unsigned char) secret[i]);
		int letter = secret[i]; // - '0';

		if (letter < 0)
			letter = 256 + letter;

		//fprintf(stderr, "char: '%c' int: '%d'\n", secret[i], letter);

		int * chunks = split_number(letter, n, t);
		int j;

		for (j = 0; j < n; ++j)
		{
			if (chunks[j] == 256) {
				sprintf(shares[j] + 6+ i * 2, "G0");	/* Fake code */
			} else {
				sprintf(shares[j] + 6 + i * 2, "%02X", chunks[j]);				
			}
		}

		free(chunks);
	}

	// fprintf(stderr, "%s\n", secret);

	return shares;
}


void free_string_shares(char ** shares, int n) {
	int i;

	for (i = 0; i < n; ++i)
	{
		free(shares[i]);
	}

	free(shares);
}


char * join_strings(char ** shares, int n) {
	/* TODO: Check if we have a quorum */

	if (n == 0)
		return NULL;

	int len = (strlen(shares[0]) - 6) / 2;

	char * result = malloc(len + 1);
	char codon[3];
	codon[2] = '\0';	// Must terminate the string!

	int x[n];
	int i;
	int j;

	for (i = 0; i < n; ++i)
	{
		codon[0] = shares[i][0];
		codon[1] = shares[i][1];

		x[i] = strtol(codon, NULL, 16);
	}

	for (i = 0; i < len; ++i)
	{
		int *chunks = malloc(sizeof(int) * n  * 2);

		for (j = 0; j < n; ++j)
		{
			chunks[j*2] = x[j];

			codon[0] = shares[j][6 + i * 2];
			codon[1] = shares[j][6 + i * 2 + 1];

			if (memcmp(codon,"G0",2) == 0) {
				chunks[j*2 + 1] = 256;
			} else {
				chunks[j*2 + 1] = strtol(codon, NULL, 16);
			}
		}

		//unsigned char letter = join_shares(chunks, n);
		char letter = join_shares(chunks, n);

		free(chunks);

		// fprintf(stderr, "char %c: %d\n", letter, (unsigned char) letter);

		sprintf(result + i, "%c",letter);
	}

	return result;
}


#ifdef TEST
void Test_split_string(CuTest* tc) {
	int n = 255;	/* Maximum n = 255 */
	int t = 254;	/* t <= n, we choose less than that so we have two tests */

	char * phrase = "This is a test of Bücher and Später.";

	int count = 10;
	int i;

	for (i = 0; i < count; ++i)
	{
		char ** result = split_string(phrase, n, t);

		/* Extract secret using first t shares */
		char * answer = join_strings(result, t);
		CuAssertStrEquals(tc, phrase, answer);
		free(answer);

		/* Extract secret using all shares */
		answer = join_strings(result, n);
		CuAssertStrEquals(tc, phrase, answer);
		free(answer);

		free_string_shares(result, n);
	}
}
#endif


/*
	generate_share_strings() -- create a string of the list of the generated shares,
		one per line
*/

char * generate_share_strings(char * secret, int n, int t) {
	char ** result = split_string(secret, n, t);
	
	int len = strlen(secret);
	int key_len = 6 + 2 * len + 1;
	int i;

	char * shares = malloc(key_len * n + 1);

	for (i = 0; i < n; ++i)
	{
		sprintf(shares + i * key_len, "%s\n", result[i]);
	}

	free_string_shares(result, n);

	return shares;
}


/* Trim spaces at end of string */
void trim_trailing_whitespace(char *str) {
	unsigned long l;
	
	if (str == NULL)
		return;
	
	l = strlen(str);
	
	if (l < 1)
		return;
	
	while ( (l > 0) && (( str[l - 1] == ' ' ) ||
		( str[l - 1] == '\n' ) || 
		( str[l - 1] == '\r' ) || 
		( str[l - 1] == '\t' )) ) {
		str[l - 1] = '\0';
		l = strlen(str);
	}
}


/*
	extract_secret_from_share_strings() -- get a raw string, tidy it up
		into individual shares, and then extract secret
*/

char * extract_secret_from_share_strings(const char * string) {
	char ** shares = malloc(sizeof(char *) * 255);

	char * share;
	char * saveptr = NULL;
	int i = 0;

	/* strtok_rr modifies the string we are looking at, so make a temp copy */
	char * temp_string = strdup(string);

	/* Parse the string by line, remove trailing whitespace */
	share = strtok_rr(temp_string, "\n", &saveptr);

	shares[i] = strdup(share);
	trim_trailing_whitespace(shares[i]);

	while ( (share = strtok_rr(NULL, "\n", &saveptr))) {
		i++;

		shares[i] = strdup(share);

		trim_trailing_whitespace(shares[i]);

		if ((shares[i] != NULL) && (strlen(shares[i]) == 0)) {
			/* Ignore blank lines */
			free(shares[i]);
			i--;
		}
	}

	i++;

	char * secret = join_strings(shares, i);


/*
	fprintf(stdout, "count: %d\n", i);

	for (int j = 0; j < i; ++j)
	{
		fprintf(stderr, "'%s'\n", shares[j]);
	}
*/

	free_string_shares(shares, i);

	return secret;
}


//main.c------------------------------------------------------------------------------------------------------------------------------

/*

	main.c -- Template main()

	Copyright © 2015 Fletcher T. Penney. Licensed under the MIT License.

	## The MIT License ##

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.

*/

#include <stdio.h>
#include <stdlib.h>
#include "shamirSecretShare.h"

//#include "GLibFacade.h"

//#include "shamir.h"


char * stdin_buffer() {
	/* Read from stdin and return a char *
		`result` will need to be freed elsewhere */

	GString * buffer = g_string_new("");
	char curchar;
	char * result;

	while ((curchar = fgetc(stdin)) != EOF)
		g_string_append_c(buffer, curchar);

	fclose(stdin);

	result = buffer->str;

	g_string_free(buffer, false);

	return result;
}

char *removeCharFromString(char *array, int position)
{   
    int c;
	for ( c = position - 1 ; c < strlen(array) - 1 ; c++ )
        array[c] = array[c+1];
 
        printf("\n Resultant array is\n");
 
    for( c = 0 ; c < strlen(array) - 1 ; c++ )
       printf("%s \n", array);
         
    return array;
}

char *readFile(char *file){
	   char *source = NULL;
    // citire share-uri din fisier
    FILE *fp = fopen(file, "r");
    if (fp != NULL) {
        /* Go to the end of the file. */
        if (fseek(fp, 0L, SEEK_END) == 0) {
            /* Get the size of the file. */
	        long bufsize = ftell(fp);
	        if (bufsize == -1) { /* Error */ }

	        /* Allocate our buffer to that size. */
	        source = malloc(sizeof(char) * (bufsize + 1));

	        /* Go back to the start of the file. */
	        if (fseek(fp, 0L, SEEK_SET) == 0) { /* Error */ }

	        /* Read the entire file into memory. */
	        size_t newLen = fread(source, sizeof(char), bufsize, fp);
	        if (newLen == 0) {
	            fputs("Error reading file", stderr);
	        } else {
	           source[++newLen] = '\0'; /* Just to be safe. */
	        }
    	}
    	fclose(fp);
    }
    return source;
}


int splitString (char *str, char c, char ***arr)
{
    int count = 1;
    int token_len = 1;
    int i = 0;
    char *p;
    char *t;

    p = str;
    while (*p != '\0')
    {
        if (*p == c)
            count++;
        p++;
    }

    *arr = (char**) malloc(sizeof(char*) * count);
    if (*arr == NULL)
        exit(1);

    p = str;
    while (*p != '\0')
    {
        if (*p == c)
        {
            (*arr)[i] = (char*) malloc( sizeof(char) * token_len );
            if ((*arr)[i] == NULL)
                exit(1);

            token_len = 0;
            i++;
        }
        p++;
        token_len++;
    }
    (*arr)[i] = (char*) malloc( sizeof(char) * token_len );
    if ((*arr)[i] == NULL)
        exit(1);

    i = 0;
    p = str;
    t = ((*arr)[i]);
    while (*p != '\0')
    {
        if (*p != c && *p != '\0')
        {
            *t = *p;
            t++;
        }
        else
        {
            *t = '\0';
            i++;
            t = ((*arr)[i]);
        }
        p++;
    }

    return count;
}



char **split_secret(char * secret, int t, int n){
	// returns shares
	char *t_shares;
	char **shares;
	t_shares = generate_share_strings(secret, n, t);

	int i, c;
	c = splitString(t_shares, '\n', &shares);
	
	/*
	for( i = 0; i < c; i++){
		fprintf(stdout, "%s %s", "\n + share este: ", shares[i]);		
	}*/
	
	return shares;
}


char *get_secret(char *share1, char *share2){
	char *secret;
	char *shares;

    shares = (char *)malloc(((strlen(share1) + strlen(share2)) + 1));
    //fprintf(stdout, "\n share1 :  %s \n", share1);
    //fprintf(stdout, "\n share2 :  %s \n", share2);
    strcpy(shares, share2);
    strcat(shares, "\n");
    strcat(shares, share1);
    //fprintf(stdout, "\n shares :  %s \n", shares);
    secret = extract_secret_from_share_strings(shares);
	return secret;
}

