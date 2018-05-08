global  my_print
section .text

;my_print(char* buf, size_t size);
;when call this file, the caller will pass augs following rdi,rsi

;调用sys_call,需要callee自己准备参数rsi rdx：
;rdi->int fd句柄，file descrel $ tor. 
;0, 1 and 2 for standard input, standard output and standard error
;rsi->char* buf
;rdx->size_t count
;
;return in rax
my_print:
    push    rdx
    mov     rdx,rsi
    mov     rsi,rdi
    mov     rax,0x1;write
    mov     rdi,0x1;standard output
    syscall
    pop     rdx
    ret
;END of printf