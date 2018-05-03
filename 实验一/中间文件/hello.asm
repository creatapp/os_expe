
global start

section .text
start:
    mov rdx,    output
    mov byte [rdx],  '%'

draw:
    mov     rax,    1;write system call
    mov     rdi,    1;file handle 1 is output
    mov     rsi,    output
    mov     rdx,    1;num of bytes
    syscall
    mov     rax,    60;exit
    xor     rdi,    rdi;status:0
    syscall
    
section .bss
output:     resb    1