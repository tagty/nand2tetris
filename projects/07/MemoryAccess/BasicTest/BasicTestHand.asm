// Initialize
@256
D=A
@0
M=D
@300
D=A
@1
M=D
// push constant 21
@21
D=A
@0
A=M
M=D
@0
M=M+1
// push constant 22
@22
D=A
@0
A=M
M=D
@0
M=M+1
// push local 10
@10
D=A
@1
A=M
M=D
// pop argument 2
@0
M=M-1
A=M
D=M
// argument
@2
A=M
A=A+1
A=A+1
M=D
