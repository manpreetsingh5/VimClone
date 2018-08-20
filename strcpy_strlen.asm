# grading strings for strcpy and srtlen

.data

__string1: .asciiz "Stony Brook University"
.space 10
__string2: .asciiz "I love CSE220"
.space 10
__string3: .asciiz "Far Beyond"
.space 10
__string4: .asciiz "i\0love\nCSE220"
.space 10
__string_space: .asciiz " "
.space 10
__strlen_1: .asciiz " helloworld"
.space 10
__strlen_2: .asciiz "helloworld "
.space 10
__strlen_3: .asciiz "helloworld goodbyeworld\n"
.space 10 
__strlen_4: .asciiz "helloworld\0goodbyeworld\n"
.space 10
__strlen_5: .asciiz "helloworld\ngoodbyeworld\0"

