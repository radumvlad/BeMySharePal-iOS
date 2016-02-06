//
//  shamirSecretShare.h
//  BeMySharePal
//
//  Created by Radu on 03/02/16.
//  Copyright © 2016 FMI. All rights reserved.
//

#ifndef shamirSecretShare_h
#define shamirSecretShare_h

char ** split_string(char * secret, int n, int t);
int splitString (char *str, char c, char ***arr);
int modInverse(int k);
int * gcdD(int a, int b);
void trim_trailing_whitespace(char *str);
int modular_exponentiation(int base,int exp,int mod);
int * split_number(int number, int n, int t);
char* strtok_rr(char *str, const char *delim, char **nextp);
void free_string_shares(char ** shares, int n);
int join_shares(int *xy_pairs, int n);
char * extract_secret_from_share_strings(const char * string) ;
char * join_strings(char ** shares, int n);
char * generate_share_strings(char * secret, int n, int t);
char *get_secret(char *share1, char *share2);
char **split_secret(char * secret, int t, int n);

#endif /* shamirSecretShare_h */
