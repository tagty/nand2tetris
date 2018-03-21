// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)

    @sum   // sum=0
    M=0
    @R1    // count=R1
    D=M
    @count
    M=D
(LOOP)
    @count // if (count)=0 goto END
    D=M
    @END
    D;JEQ
    @R0    // sum=sum+R0
    D=M
    @sum
    M=M+D
    @count // count-=1
    M=M-1
    @LOOP
    0;JMP
(END)
    @sum   // R2=sum
    D=M
    @R2
    M=D
