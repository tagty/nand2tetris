@261
D=A
@0
M=D
@0
D=A
@1
M=D
@2
M=D
@3
M=D
@4
M=D
@5
M=D
@6
M=D
@7
M=D
@8
M=D
@9
M=D
@10
M=D
@11
M=D
@12
M=D
// function Sys.init 0
(Sys.init)
@6
D=A
@0
A=M
M=D
@0
M=M+1
@8
D=A
@0
A=M
M=D
@0
M=M+1
// call Class1.set 2
@call-Class1.set-0
D=A
@0
A=M
M=D
@0
M=M+1
@1
D=M
@0
A=M
M=D
@0
M=M+1
@2
D=M
@0
A=M
M=D
@0
M=M+1
@3
D=M
@0
A=M
M=D
@0
M=M+1
@4
D=M
@0
A=M
M=D
@0
M=M+1
@0
D=M
D=D-1
D=D-1
D=D-1
D=D-1
D=D-1
D=D-1
D=D-1
@2
M=D
@0
D=M
@1
M=D
@Class1.set
0;JMP
(call-Class1.set-0)
@0
M=M-1
A=M
D=M
@5
M=D
@23
D=A
@0
A=M
M=D
@0
M=M+1
@15
D=A
@0
A=M
M=D
@0
M=M+1
// call Class2.set 2
@call-Class2.set-1
D=A
@0
A=M
M=D
@0
M=M+1
@1
D=M
@0
A=M
M=D
@0
M=M+1
@2
D=M
@0
A=M
M=D
@0
M=M+1
@3
D=M
@0
A=M
M=D
@0
M=M+1
@4
D=M
@0
A=M
M=D
@0
M=M+1
@0
D=M
D=D-1
D=D-1
D=D-1
D=D-1
D=D-1
D=D-1
D=D-1
@2
M=D
@0
D=M
@1
M=D
@Class2.set
0;JMP
(call-Class2.set-1)
@0
M=M-1
A=M
D=M
@5
M=D
// call Class1.get 0
@call-Class1.get-2
D=A
@0
A=M
M=D
@0
M=M+1
@1
D=M
@0
A=M
M=D
@0
M=M+1
@2
D=M
@0
A=M
M=D
@0
M=M+1
@3
D=M
@0
A=M
M=D
@0
M=M+1
@4
D=M
@0
A=M
M=D
@0
M=M+1
@0
D=M
D=D-1
D=D-1
D=D-1
D=D-1
D=D-1
@2
M=D
@0
D=M
@1
M=D
@Class1.get
0;JMP
(call-Class1.get-2)
// call Class2.get 0
@call-Class2.get-3
D=A
@0
A=M
M=D
@0
M=M+1
@1
D=M
@0
A=M
M=D
@0
M=M+1
@2
D=M
@0
A=M
M=D
@0
M=M+1
@3
D=M
@0
A=M
M=D
@0
M=M+1
@4
D=M
@0
A=M
M=D
@0
M=M+1
@0
D=M
D=D-1
D=D-1
D=D-1
D=D-1
D=D-1
@2
M=D
@0
D=M
@1
M=D
@Class2.get
0;JMP
(call-Class2.get-3)
(WHILE)
// goto WHILE
@WHILE
0;JMP
// function Class1.set 0
(Class1.set)
@2
A=M
D=M
@0
A=M
M=D
@0
M=M+1
@0
M=M-1
A=M
D=M
@16
M=D
@2
A=M
A=A+1
D=M
@0
A=M
M=D
@0
M=M+1
@0
M=M-1
A=M
D=M
@16
A=A+1
M=D
@0
D=A
@0
A=M
M=D
@0
M=M+1
@1
D=M
@13
M=D
D=D-1
D=D-1
D=D-1
D=D-1
D=D-1
A=D
D=M
@14
M=D
@0
M=M-1
A=M
D=M
@2
A=M
M=D
@2
D=M+1
@0
M=D
@13
A=M
A=A-1
D=M
@4
M=D
@13
A=M
A=A-1
A=A-1
D=M
@3
M=D
@13
A=M
A=A-1
A=A-1
A=A-1
D=M
@2
M=D
@13
A=M
A=A-1
A=A-1
A=A-1
A=A-1
D=M
@1
M=D
@14
A=M
0;JMP
// function Class1.get 0
(Class1.get)
@16
D=M
@0
A=M
M=D
@0
M=M+1
@16
A=A+1
D=M
@0
A=M
M=D
@0
M=M+1
// sub
@0
M=M-1
A=M
D=M
@0
M=M-1
A=M
M=M-D
@0
M=M+1
@1
D=M
@13
M=D
D=D-1
D=D-1
D=D-1
D=D-1
D=D-1
A=D
D=M
@14
M=D
@0
M=M-1
A=M
D=M
@2
A=M
M=D
@2
D=M+1
@0
M=D
@13
A=M
A=A-1
D=M
@4
M=D
@13
A=M
A=A-1
A=A-1
D=M
@3
M=D
@13
A=M
A=A-1
A=A-1
A=A-1
D=M
@2
M=D
@13
A=M
A=A-1
A=A-1
A=A-1
A=A-1
D=M
@1
M=D
@14
A=M
0;JMP
// function Class2.set 0
(Class2.set)
@2
A=M
D=M
@0
A=M
M=D
@0
M=M+1
@0
M=M-1
A=M
D=M
@16
A=A+1
A=A+1
M=D
@2
A=M
A=A+1
D=M
@0
A=M
M=D
@0
M=M+1
@0
M=M-1
A=M
D=M
@16
A=A+1
A=A+1
A=A+1
M=D
@0
D=A
@0
A=M
M=D
@0
M=M+1
@1
D=M
@13
M=D
D=D-1
D=D-1
D=D-1
D=D-1
D=D-1
A=D
D=M
@14
M=D
@0
M=M-1
A=M
D=M
@2
A=M
M=D
@2
D=M+1
@0
M=D
@13
A=M
A=A-1
D=M
@4
M=D
@13
A=M
A=A-1
A=A-1
D=M
@3
M=D
@13
A=M
A=A-1
A=A-1
A=A-1
D=M
@2
M=D
@13
A=M
A=A-1
A=A-1
A=A-1
A=A-1
D=M
@1
M=D
@14
A=M
0;JMP
// function Class2.get 0
(Class2.get)
@16
A=A+1
A=A+1
D=M
@0
A=M
M=D
@0
M=M+1
@16
A=A+1
A=A+1
A=A+1
D=M
@0
A=M
M=D
@0
M=M+1
// sub
@0
M=M-1
A=M
D=M
@0
M=M-1
A=M
M=M-D
@0
M=M+1
@1
D=M
@13
M=D
D=D-1
D=D-1
D=D-1
D=D-1
D=D-1
A=D
D=M
@14
M=D
@0
M=M-1
A=M
D=M
@2
A=M
M=D
@2
D=M+1
@0
M=D
@13
A=M
A=A-1
D=M
@4
M=D
@13
A=M
A=A-1
A=A-1
D=M
@3
M=D
@13
A=M
A=A-1
A=A-1
A=A-1
D=M
@2
M=D
@13
A=M
A=A-1
A=A-1
A=A-1
A=A-1
D=M
@1
M=D
@14
A=M
0;JMP