;本文对应由提前编写的c语言反汇编得到的代码，并且在理解代码的情况下重新编写
;平台：Debian/x64
;风格： Intel_style

; ~~~~~~~~~~~~~~~~~~~~~~~~~
; |  作者: 王宁  161250139 |
; |  日期：4/13           |
;~~~~~~~~~~~~~~~~~~~~~~~~~

;~~~~~~~~~~~~~~~~~~~~~~~~~~
;程序栈说明
;--main--
;rbp - 0x4  == index:INT 用于计数颜色数组
;rbp - 0x8  == i:INT 从下限到上限的循环计数器i
;rbp - 0xc  == a:INT 范围上限
;rbp - 0x10 == b:INT 范围下限
;rbp - 0x80 == c:CHAR[101] 计数器数组，每一位在0~9之间
;rbp - 0xf0 == re_after:CHAR[101] 转换ascii码的数组
;
;--fibonacci--【注意不同函数的栈不同，rbp的值发生了变化】
;rbp - 0xf4 == integer:INT 斐波那契函数接受的第几项
;rbp - 0x100== result:CHAR* 返回的结果数组
;rbp - 0x80 == tmp_1:CHAR[101] 保存前两项的数组
;rbp - 0xf0 == tmp_2:CHAR[101]
;rbp - 0x8  == carry:INT 标识是否进位
;rbp - 0xc  == index:INT 加法游标
;rbp - 0x10 == i:INT tmp_1[] -> tmp_2[]循环使用i
;rbp - 0x14 == i:INT tmp_2[] -> result[]循环使用i
;
;
;--dowith--
;rbp - 0x18 == nums:CHAR* 也就是fibonacci改变的result
;rbp - 0x20 == str:CHAR* nums修改成ascii的容器
;rbp - 0x4  == i:INT str进行清零的i
;rbp - 0x8  == src_index:INT 源的cursor
;rbp - 0xc  == des_index:INT 写出数组的cursor
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~

;------------
;compile:   nasm -f elf64 -F dwarf -g fibonacci_rewrite.asm
;           ld -m elf_x86_64 -o fib fibonacci_rewrite.o
;
;debug:     gdb ./fib
;

global _start

section .text

;_start
_start:
    jmp     main;从main开始
    ;jmp     $;死循环
    mov     rax,0x3c;exit
    mov     rdi,0
    syscall
;END of _start


;printf
;调用sys_call,需要callee自己准备参数rsi rdx：
;rdi->int fd句柄，file descrel $ tor. 
;0, 1 and 2 for standard input, standard output and standard error
;rsi->char* buf
;rdx->size_t count
;
;return in rax
printf:
    push    rax
    push    rdi
    mov     rax,0x1;write
    mov     rdi,0x1;standard output
    push    r11
    syscall
    pop     r11
    pop     rdi
    pop     rax
    ret
;END of printf




;scanf
;将读入的两个数存入BUFFER中
scanf:
    push    rax;tmp buffer for every byte
    push    rdi;accumulate tmp
    push    rsi;rdx value for 1st number
    push    rdx;index
    mov     rax,0x0;read
    mov     rdi,0x0;standard input
    mov     rsi,BUFFER
    mov     rdx,lenBUFFER;9
    push    r11
    syscall
    pop     r11
;对输入进行处理，约定r8和r9存放这两个数a，b
;需要一个字节一个字节地处理
    xor     rdx,rdx;rdx stores index
read:
    mov     al,[BUFFER+rdx]
    ;blank
    cmp     al,0x20
    je      readone
    ;newline
    cmp     al,0xa
    je     readtwo
    ;继续接受第一个数
    add     rdx,0x1
    jmp     read

readone:;此时第一个数字输入完毕
    cmp     rdx,0x3
    je      bai
    cmp     rdx,0x2
    je      shi
ge:
    xor     rdi,rdi
    movsx   rdi,BYTE [BUFFER]
    sub     rdi,0x30;-48
    mov     rsi,rdx;rsi记录当前位数
    xor     r8,r8
    mov     r8,rdi
    add     rdx,0x1
    jmp     read
bai:
    movsx   rdi,BYTE [BUFFER]
    sub     rdi,0x30
    imul     rdi,0x64;100
    xor     r8,r8
    mov     r8,rdi
    ;
    xor     rdi,rdi
    movsx   rdi,BYTE [BUFFER+0x1]
    sub     rdi,0x30
    imul     rdi,0xa;10
    add     r8,rdi
    ;
    xor     rdi,rdi
    movsx   rdi,BYTE [BUFFER+0x2]
    sub     rdi,0x30
    add     r8,rdi
    ;
    mov     rsi,rdx
    add     rdx,0x1
    jmp     read
shi:
    xor     r8,r8
    xor     rdi,rdi
    movsx   rdi,BYTE [BUFFER]
    sub     rdi,0x30
    imul     rdi,0xa
    mov     r8,rdi
    ;
    xor     rdi,rdi
    movsx   rdi,BYTE [BUFFER+0x1]
    sub     rdi,0x30
    add     r8,rdi
    ;
    mov     rsi,rdx
    add     rdx,0x1
    jmp     read
    ;;;;;;;;;;;;;;;;
readtwo:;保存第二个数然后退出
    ;用rdx判断位数
    sub     rdx,rsi;
    sub     rdx,0x1

    cmp     rdx,0x3
    je      nbai
    cmp     rdx,0x2
    je      nshi
nge:
    xor     rdi,rdi
    movsx   rdi,BYTE [BUFFER+rsi+0x1]
    sub     rdi,0x30;-48
    xor     r9,r9
    mov     r9,rdi
    jmp     endread
nbai:
    movsx   rdi,BYTE [BUFFER+rsi+0x1]
    sub     rdi,0x30
    imul     rdi,0x64;100
    xor     r9,r9
    mov     r9,rdi
    ;
    xor     rdi,rdi
    movsx   rdi,BYTE [BUFFER+0x2+rsi]
    sub     rdi,0x30
    imul     rdi,0xa;10
    add     r9,rdi
    ;
    xor     rdi,rdi
    movsx   rdi,BYTE [BUFFER+0x3+rsi]
    sub     rdi,0x30
    add     r9,rdi
    ;
    jmp     endread
nshi:
    xor     r9,r9
    xor     rdi,rdi
    movsx   rdi,BYTE [BUFFER+rsi+0x1]
    sub     rdi,0x30
    imul     rdi,0xa
    mov     r9,rdi
    ;
    xor     rdi,rdi
    movsx   rdi,BYTE [BUFFER+0x2+rsi]
    sub     rdi,0x30
    add     r9,rdi
    ;
    jmp     endread

endread:
    pop     rdx
    pop     rsi
    pop     rdi
    pop     rax
    ret
;END of scanf




;main函数入口
main:
    push    rbp     ;保存栈基址
    mov     rbp,rsp
    sub     rsp,0xf0    ;分出15 × 16字节内存
;打印提示文字
    ; lea     rdi,[rel $ +0x0]  ;lea直接放值，mov是读取地址里面的值
    mov     rsi,TIP
    mov     rdx,lenTIP
    call    printf
;0x17
    ; mov     DWORD [rbp-0x4],0x0 ;int index = 0;是颜色数组的计数器
    
;scanf
    call    scanf
    mov     rax,r9;取第二个数字
    mov     DWORD [rbp-0x10],eax;b
    mov     rax,r8;取第一个数字
    mov     DWORD [rbp-0xc],eax;a

    ; lea     rdx,[rbp-0x10]  ;赋值a和b
    ; lea     rax,[rbp-0xc]
    ; mov     rsi,rax
    ; lea     rdi,[rel $ +0x0]
    ; mov     eax,0x0
;0x3a
    lea     rdx,[rbp-0x80]  ;分配char c[101]
    mov     eax,0x0
    mov     ecx,0xd
    mov     rdi,rdx
P1: mov QWORD [rdi],rax ;连续写0xc × 8 bytes 个 0
    add     rdi,0x8
    loop    P1
    mov     rdx,rdi
    mov     DWORD [rdx],eax
    add     rdx,0x4
    mov     BYTE [rdx],al
    add     rdx,0x1

;分配re_after
    lea     rdx,[rbp-0xf0]
    mov     eax,0x0
    mov     ecx,0xd
    mov     rdi,rdx
P2: mov QWORD [rdi],rax
    add     rdi,0x8
    loop    P2
    mov     rdx,rdi
    mov     DWORD [rdx],eax
    add     rdx,0x4
    mov     BYTE [rdx],al
    add     rdx,0x1
    ;;;;
    ;用r12作为色彩的index
    ;;;;
    mov     r12,0x0
    mov     r11,0x0;计数器
;主循环
    mov     eax,DWORD [rbp-0xc] ;eax = b
    mov     DWORD [rbp-0x8],eax ;i = b
    jmp     L3
;0x8e,调用fibonacci
L0:
    lea     rdx,[rbp-0x80]  ;c array
    mov     eax,DWORD [rbp-0x8];i
    mov     rsi,rdx
    mov     edi,eax
    call    fibonacci
    ;;;test;;;
    mov     al,BYTE [rbp-0x80+0x63];+99
    mov     al,BYTE [rbp-0x80+0x62]
    mov     al,BYTE [rbp-0x80+0x64]
    ;;;test;;;
;0x9f,此处确定index的值
    mov     eax,DWORD [rbp-0x4] ;index
    add     eax,0x1
    cmp     eax,0x4
    jg      L1
    mov     eax,DWORD [rbp-0x4]
    add     eax,0x1
    jmp     L2
L1:
    mov     eax,0x0                                 
L2:
    mov     DWORD [rbp-0x4],eax;写入index+1     
;调用dowith将计数器数组的前导0去掉，转为ascii字符+48
    lea     rdx,[rbp-0xf0];re_after
    lea     rax,[rbp-0x80];计数器地址
    mov     rsi,rdx ;调用参数
    mov     rdi,rax
    call    dowith
;    call    d0
;0xd0,print最终结果
    ; mov     eax,DWORD [rbp-0x4] ;index
    ; cdqe    ;x64专有指令，将eax带符号扩展成rax
    ; lea     rdx,[rax*8+0x0]
    ; lea     rax,[rel $ +0x0]
    ; mov     rax,QWORD [rdx+rax*1]
    ; lea     rdx,[rbp-0xf0];re_after
    ; lea     rcx,[rel $ +0x0]
    ; mov     rsi,rax ;color[]
    ; lea     rdi,[rel $ +0x0];NONE结束符标志
    ; mov     eax,0x0
;   call    10a
;--------------------
;这里需要考虑拼接不同字符串，获取需要打印的字符串个数，控制颜色变化
;TODO   
;-------------------- 
    mov     rsi,RED     
    add     rsi,r12
    mov     rdx,lenRED
    ;push    r11
    call    printf
    ;pop     r11
    ;------
    ;改变R12
    ;-------
    add     r12,lenRED
    inc     r11
    
    cmp     r11,0x4
    jle     Z0;<=4就可以继续打印
    mov     r11,0x0;否则置为0,
    mov     r12,0x0
    ; mov     rsi,TIP
    ; mov     rdx,lenTIP
    ; call    printf
    ;;;test;;;
Z0:
    mov     BYTE [rbp-0xf0+0x64],0x0;防止打印出界限
    ; mov     al,BYTE [rbp-0xf0+0x63];+99
    ; mov     al,BYTE [rbp-0xf0+0x62]
    ; mov     al,BYTE [rbp-0xf0+0x64]
    ;;;test;;;
    mov     BYTE [rbp-0xf0+0x64],0x0;保护位
    lea     rsi,[rbp-0xf0]
    mov     rdx,r10
    call    printf
    ;
    ;
    ;
    mov     rsi,NONE
    mov     rdx,lenNONE
    call    printf
;~~~~~~~~~~~~~~~~~~~~~~~~

;0x10a,main函数for循环
    add     DWORD [rbp-0x8],0x1;i
;0x10e
L3:
    mov     eax,DWORD [rbp-0x10];
    cmp     DWORD [rbp-0x8],eax;i vs b
    jle     L0
    mov     eax,0x0

    leave
    ret
;END of main





fibonacci:
;fibonacci函数
;进入方法体
    push    rbp
    mov     rbp,rsp
    sub     rsp,0x88
    mov     DWORD [rbp-0xf4],edi;integer:INT
    mov     QWORD [rbp-0x100],rsi;result:CHAR×
;开始for循环，将result清0
    mov     DWORD [rbp-0x4],0x0;i = 0
    jmp     M0
;0x142
M1:
    mov     eax,DWORD [rbp-0x4]
    movsxd  rdx,eax;将双字带符号移动到四字
    mov     rax,QWORD [rbp-0x100];result
    add     rax,rdx;result中的偏移
    mov     BYTE [rax],0x0
    add     DWORD [rbp-0x4],0x1
;0x159
M0:
    cmp     DWORD [rbp-0x4],0x64;100
    jle     M1
;以下分配tmp_1:CHAR[101]和tmp_2:CHAR[101]用来保存前两项
    lea     rdx,[rbp-0x80]
    mov     eax,0x0
    mov     ecx,0xd
    mov     rdi,rdx
P3: mov QWORD [rdi],rax
    add     rdi,0x8
    loop    P3
    mov     rdx,rdi ;rdi指向最后一个
    mov     DWORD [rdx],eax
    add     rdx,0x4
    mov     BYTE [rdx],al ;字符串数组的后面标识的'/0'
    add     rdx,0x1
;tmp_2:CHAR[101]
    lea     rdx,[rbp-0xf0]
    mov     eax,0x0
    mov     ecx,0xd
    mov     rdi,rdx
P4: mov QWORD [rdi],rax
    add     rdi,0x8
    loop    P4
    mov     rdx,rdi ;rdi指向最后一个
    mov     DWORD [rdx],eax
    add     rdx,0x4
    mov     BYTE [rdx],al;字符串数组的后面标识的'/0'
    add     rdx,0x1
    mov     BYTE [rbp-0x8d],0x1;倒数第二位置为1
;carry指明是否进位
    mov     DWORD [rbp-0x8],0x0
;index从后往前做加法的游标cursor
    mov     DWORD [rbp-0xc],0x63;99
;对第一项返回0
    cmp     DWORD [rbp-0xf4],0x0
    jg      M2
    mov     rax,QWORD [rbp-0x100]
    add     rax,0x63
    mov     BYTE [rax],0x0
    jmp     M3;return
;0x1d9,第二项返回1
M2:
    cmp     DWORD [rbp-0xf4],0x1
    jne     M4 
    mov     rax,QWORD [rbp-0x100]
    add     rax,0x63
    mov     BYTE [rax],0x1
    jmp     M3;return
;进入位数相加环节
;0x1f9,index<0
M8:
    cmp     DWORD [rbp-0xc],0x0
    js      M5
;result[index] = tmp_1[index] + tmp_2[index]
    mov     eax,DWORD [rbp-0xc]
    movsxd  rdx,eax;index
    mov     rax,QWORD [rbp-0x100]
    add     rdx,rax;result[index]
    mov     eax,DWORD [rbp-0xc]
    cdqe
    xor     ecx,ecx
    mov     cl,BYTE [rbp+rax*1-0x80];0扩展移动，tmp_1[index]第一项
 ;   mov     ecx,eax
    mov     eax,DWORD [rbp-0xc]
    cdqe
    xor     rbx,rbx
    mov     bl,BYTE [rbp+rax*1-0xf0]
    add     ecx,ebx     ;plus here
    mov     BYTE [rdx],cl
;进位carry=1
    cmp     DWORD [rbp-0x8],0x1
    jne     M6
    mov     DWORD [rbp-0x8],0x0
;result[index] += 1
    mov     eax,DWORD [rbp-0xc]
    movsxd  rdx,eax
    mov     rax,QWORD [rbp-0x100];result
    add     rax,rdx
    mov     edx,DWORD [rbp-0xc]
    movsxd  rcx,edx
    mov     rdx,QWORD [rbp-0x100]
    add     rdx,rcx
    mov     dl,BYTE [rdx]
    add     edx,0x1
    mov     BYTE [rax],dl
;0x265 if(result[index] > 9)需要进位
M6:
    mov     eax,DWORD [rbp-0xc]
    movsxd  rdx,eax
    mov     rax,QWORD [rbp-0x100]
    add     rax,rdx
    mov     al,BYTE [rax]
    cmp     al,0x9
    jle     M7 
;carry=1
    mov     DWORD [rbp-0x8],0x1
;result[index] -= 10
    mov     eax,DWORD [rbp-0xc]
    movsxd  rdx,eax
    mov     rax,QWORD [rbp-0x100]
    add     rax,rdx
    mov     edx,DWORD [rbp-0xc]
    movsxd  rcx,edx
    mov     rdx,QWORD [rbp-0x100]
    add     rdx,rcx
    mov     dl,BYTE [rdx]
    sub     edx,0xa
    mov     BYTE [rax],dl
;0x2ab,index--
M7:
    sub     DWORD [rbp-0xc],0x1
;如果index<0就说明已经移动所有位，跳出
    jmp     M8
;0x2b4
M5:
    nop ;
;更新tmp_1为tmp_2,使用逐个赋值的方法，理论上memset快一点，但是怕引入string.h增加复杂程度
    mov     DWORD [rbp-0x10],0x0;新的循环使用的i
    jmp     M9
;0x2be
M10:
    mov     eax,DWORD [rbp-0x10]
    cdqe
    mov     dl,BYTE [rbp+rax*1-0xf0]
    mov     eax,DWORD [rbp-0x10]
    cdqe
    mov     BYTE [rbp+rax*1-0x80],dl
    add     DWORD [rbp-0x10],0x1
;0x2d8
M9:
    cmp     DWORD [rbp-0x10],0x64;100
    jle     M10
;更新tmp_2为result
    mov     DWORD [rbp-0x14],0x0
    jmp     M11
;0x2e7
M12:
    mov     eax,DWORD [rbp-0x14];第二个循环的i
    movsxd  rdx,eax
    mov     rax,QWORD [rbp-0x100]
    add     rax,rdx
    mov     dl,BYTE [rax]
    mov     eax,DWORD [rbp-0x14]
    cdqe
    mov     BYTE [rbp+rax*1-0xf0],dl;tmp_2
    add     DWORD [rbp-0x14],0x1
;0x30a
M11:
    cmp     DWORD [rbp-0x14],0x64
    jle     M12
;index = 99,index--,
    mov     DWORD [rbp-0xc],0x63
    sub     DWORD [rbp-0xf4],0x1
;0x31e,integer>=2 ?
M4:
    cmp     DWORD [rbp-0xf4],0x1
    jg      M8
;0x32b,leave
M3:
    leave
    ret
;END of fibonacci




dowith:
;
;
;
;使用r10记录有多少个字符将会被打印
;
;
;
;dowith(char* nums, char* str)
    push    rbp
    mov     rbp,rsp
    mov     r10,0x0;最少打印一个字符
    mov     QWORD [rbp-0x18],rdi;nums
    mov     QWORD [rbp-0x20],rsi;str
;对str进行清零
    mov     DWORD [rbp-0x4],0x0;该循环的i
    jmp     N0
;0x342  
N1:  
    mov     eax,DWORD [rbp-0x4]
    movsxd  rdx,eax
    mov     rax,QWORD [rbp-0x20];result
    add     rax,rdx
    mov     BYTE [rax],0x0
    add     DWORD [rbp-0x4],0x1
;0x356
N0:
    cmp     DWORD [rbp-0x4],0x64
    jle     N1
;src_index指示nums的cursor
    mov     DWORD [rbp-0x8],0x0
;des_index指示str的cursor
    mov     DWORD [rbp-0xc],0x0
;移动源的指针到第一个非0位
    jmp     N2
;0x36c
N4:
    add     DWORD [rbp-0x8],0x1
;移到最后一位就指到倒数第二位并且退出
    cmp     DWORD [rbp-0x8],0x64
    jne     N2
    mov     r10,0x1
    mov     DWORD [rbp-0x8],0x63
    jmp     N3
;0x37f
N2:
    mov     eax,DWORD [rbp-0x8]
    movsxd  rdx,eax
    mov     rax,QWORD [rbp-0x18];nums
    add     rax,rdx
    mov     al,BYTE [rax]
    test    al,al;如果al为0就置ZF为1
    je      N4
;0x393，开始改变每一位的ascii码值
N3:
    jmp     N5
;0x395
N6:
    mov     eax,DWORD [rbp-0xc]
    lea     edx,[rax+0x1]
    mov     DWORD [rbp-0xc],edx;des_index = des_index + 1
    add     r10,0x1
    movsxd  rdx,eax
    mov     rax,QWORD [rbp-0x20];局部变量的基地址
    lea     rcx,[rdx+rax*1]
    mov     eax,DWORD [rbp-0x8]
    lea     edx,[rax+0x1]
    mov     DWORD [rbp-0x8],edx;src_index = src_index + 1
    movsxd  rdx,eax
    mov     rax,QWORD [rbp-0x18]
    add     rax,rdx;此时rax是返回地址的+0xn位
    mov     al,BYTE [rax]
    add     eax,0x30;48
    mov     BYTE [rcx],al
;0x3c4重复
N5:
    cmp     DWORD [rbp-0x8],0x63
    jle     N6
    nop
    pop     rbp
    ret
;END of dowith

section .data
RED:        db  `\033[31m`,`\033[32m`,`\033[33m`,`\033[34m`,`\033[35m`
lenRED:     equ  0x5

NONE        db  `\033[0m`,10,0
lenNONE     equ  $-NONE

;提示文字
TIP         db  "two numbers:",10,0
lenTIP      db  $-TIP

; ;输入区域的位置
section .bss
BUFFER      resb    9
lenBUFFER   equ     $-BUFFER