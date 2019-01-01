# tinyC Assignment - 6 ( CS39003 Compilers Laboratory )

## COMPILING and GENERATING the quads.s file : 
1. make
2. make run

## CLEAN : 
1. make clean

## PLEASE SEE : 

1. the translator.cxx file is a combination of the intended translator.cxx ( Lines 1 - 488 ) and target_translator.cxx ( Lines 490 - 1192 ) . 

2. the quads.s file is a combination of the Interemediate Representation Code ( starting of the file ) and the Assembly Language Code 
( after the IR Code ) . 


## WARNINGS :  
1. No variable name can start with letter 't'.
2. In case we wish to execute the .s file we need to comment out the  	 IR Code part which is present in the starting. 
   Use of the command: 
						gcc myl.o test1.s -o test1.out

