
org 07c00h      ;程序从7c00h开始加载

mov ax, cs      ;代码段地址
mov ds, ax      ;数据段
mov es, ax      ;附加段

call DispStr

jmp $       ;从本行循环

DispStr:
    mov ax, BootMessage     ;将字符串地址放进ax
    mov bp, ax              ;基址指针
    mov cx, 16              ;cx是字符串长度
    mov ax, 01301h
    mov bx, 000ch
    mov dl, 0

    int 10h                 ;中断
    ret                     ;返回

BootMessage:    db      "Hello  world, OS"
times       510-($-$$)  db  0       ;填充0

dw  0xaa55