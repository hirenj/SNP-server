# I am a comment, and I want to say that the variable CC will be
# the compiler to use.
CC=gcc
# Hey!, I am comment number 2. I want to say that CFLAGS will be the
# options I'll pass to the compiler.
CFLAGS=-O2

all: fast_diff

fast_diff:
	$(CC) src/fast_diff.c -o bin/fast_diff

clean:
	rm -rf *o bin/fast_diff