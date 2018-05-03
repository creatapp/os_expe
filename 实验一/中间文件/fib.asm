
main.o：     文件格式 elf64-x86-64


Disassembly of section .text:

0000000000000000 <main>:
char* color[] =  {RED, GREEN, BLUE, PURPLE, YELLOW};

void fabonacci(int, char[101]);
void dowith(char[101], char[101]);

int main(void){
   0:	55                   	push   rbp
   1:	48 89 e5             	mov    rbp,rsp
   4:	48 81 ec f0 00 00 00 	sub    rsp,0xf0
	printf("%s\n","fabonacci, two numbers required:" );
   b:	48 8d 3d 00 00 00 00 	lea    rdi,[rip+0x0]        # 12 <main+0x12>
  12:	e8 00 00 00 00       	call   17 <main+0x17>

	int a, b;

	int index = 0;
  17:	c7 45 fc 00 00 00 00 	mov    DWORD PTR [rbp-0x4],0x0

	scanf("%d %d",&a, &b);
  1e:	48 8d 55 f0          	lea    rdx,[rbp-0x10]
  22:	48 8d 45 f4          	lea    rax,[rbp-0xc]
  26:	48 89 c6             	mov    rsi,rax
  29:	48 8d 3d 00 00 00 00 	lea    rdi,[rip+0x0]        # 30 <main+0x30>
  30:	b8 00 00 00 00       	mov    eax,0x0
  35:	e8 00 00 00 00       	call   3a <main+0x3a>

	char c[101] = {0};//result
  3a:	48 8d 55 80          	lea    rdx,[rbp-0x80]
  3e:	b8 00 00 00 00       	mov    eax,0x0
  43:	b9 0c 00 00 00       	mov    ecx,0xc
  48:	48 89 d7             	mov    rdi,rdx
  4b:	f3 48 ab             	rep stos QWORD PTR es:[rdi],rax
  4e:	48 89 fa             	mov    rdx,rdi
  51:	89 02                	mov    DWORD PTR [rdx],eax
  53:	48 83 c2 04          	add    rdx,0x4
  57:	88 02                	mov    BYTE PTR [rdx],al
  59:	48 83 c2 01          	add    rdx,0x1

	char re_after[101] = {0};//处理后的数组，可以直接显示
  5d:	48 8d 95 10 ff ff ff 	lea    rdx,[rbp-0xf0]
  64:	b8 00 00 00 00       	mov    eax,0x0
  69:	b9 0c 00 00 00       	mov    ecx,0xc
  6e:	48 89 d7             	mov    rdi,rdx
  71:	f3 48 ab             	rep stos QWORD PTR es:[rdi],rax
  74:	48 89 fa             	mov    rdx,rdi
  77:	89 02                	mov    DWORD PTR [rdx],eax
  79:	48 83 c2 04          	add    rdx,0x4
  7d:	88 02                	mov    BYTE PTR [rdx],al
  7f:	48 83 c2 01          	add    rdx,0x1

	//int i = a;
	//char* strp = "";

	for(int i = a; i <= b; i++){
  83:	8b 45 f4             	mov    eax,DWORD PTR [rbp-0xc]
  86:	89 45 f8             	mov    DWORD PTR [rbp-0x8],eax
  89:	e9 80 00 00 00       	jmp    10e <main+0x10e>
		fabonacci(i,c);
  8e:	48 8d 55 80          	lea    rdx,[rbp-0x80]
  92:	8b 45 f8             	mov    eax,DWORD PTR [rbp-0x8]
  95:	48 89 d6             	mov    rsi,rdx
  98:	89 c7                	mov    edi,eax
  9a:	e8 00 00 00 00       	call   9f <main+0x9f>
        //ltoa(c,strp,10);
		index = (index + 1) > 4 ? 0 : index + 1;
  9f:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
  a2:	83 c0 01             	add    eax,0x1
  a5:	83 f8 04             	cmp    eax,0x4
  a8:	7f 08                	jg     b2 <main+0xb2>
  aa:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
  ad:	83 c0 01             	add    eax,0x1
  b0:	eb 05                	jmp    b7 <main+0xb7>
  b2:	b8 00 00 00 00       	mov    eax,0x0
  b7:	89 45 fc             	mov    DWORD PTR [rbp-0x4],eax

		dowith(c, re_after);
  ba:	48 8d 95 10 ff ff ff 	lea    rdx,[rbp-0xf0]
  c1:	48 8d 45 80          	lea    rax,[rbp-0x80]
  c5:	48 89 d6             	mov    rsi,rdx
  c8:	48 89 c7             	mov    rdi,rax
  cb:	e8 00 00 00 00       	call   d0 <main+0xd0>

		printf("%s%s%s\n", color[index],re_after,NONE);
  d0:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
  d3:	48 98                	cdqe   
  d5:	48 8d 14 c5 00 00 00 	lea    rdx,[rax*8+0x0]
  dc:	00 
  dd:	48 8d 05 00 00 00 00 	lea    rax,[rip+0x0]        # e4 <main+0xe4>
  e4:	48 8b 04 02          	mov    rax,QWORD PTR [rdx+rax*1]
  e8:	48 8d 95 10 ff ff ff 	lea    rdx,[rbp-0xf0]
  ef:	48 8d 0d 00 00 00 00 	lea    rcx,[rip+0x0]        # f6 <main+0xf6>
  f6:	48 89 c6             	mov    rsi,rax
  f9:	48 8d 3d 00 00 00 00 	lea    rdi,[rip+0x0]        # 100 <main+0x100>
 100:	b8 00 00 00 00       	mov    eax,0x0
 105:	e8 00 00 00 00       	call   10a <main+0x10a>
	for(int i = a; i <= b; i++){
 10a:	83 45 f8 01          	add    DWORD PTR [rbp-0x8],0x1
 10e:	8b 45 f0             	mov    eax,DWORD PTR [rbp-0x10]
 111:	39 45 f8             	cmp    DWORD PTR [rbp-0x8],eax
 114:	0f 8e 74 ff ff ff    	jle    8e <main+0x8e>
 11a:	b8 00 00 00 00       	mov    eax,0x0
	}

}
 11f:	c9                   	leave  
 120:	c3                   	ret    

0000000000000121 <fabonacci>:

void fabonacci(int integer, char* result){
 121:	55                   	push   rbp
 122:	48 89 e5             	mov    rbp,rsp
 125:	48 81 ec 88 00 00 00 	sub    rsp,0x88
 12c:	89 bd 0c ff ff ff    	mov    DWORD PTR [rbp-0xf4],edi
 132:	48 89 b5 00 ff ff ff 	mov    QWORD PTR [rbp-0x100],rsi

    for(int i = 0; i < 101; i++)result[i] = 0;
 139:	c7 45 fc 00 00 00 00 	mov    DWORD PTR [rbp-0x4],0x0
 140:	eb 17                	jmp    159 <fabonacci+0x38>
 142:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
 145:	48 63 d0             	movsxd rdx,eax
 148:	48 8b 85 00 ff ff ff 	mov    rax,QWORD PTR [rbp-0x100]
 14f:	48 01 d0             	add    rax,rdx
 152:	c6 00 00             	mov    BYTE PTR [rax],0x0
 155:	83 45 fc 01          	add    DWORD PTR [rbp-0x4],0x1
 159:	83 7d fc 64          	cmp    DWORD PTR [rbp-0x4],0x64
 15d:	7e e3                	jle    142 <fabonacci+0x21>

    char tmp_1[101] = {0};//tmp_1[49] = 0;
 15f:	48 8d 55 80          	lea    rdx,[rbp-0x80]
 163:	b8 00 00 00 00       	mov    eax,0x0
 168:	b9 0c 00 00 00       	mov    ecx,0xc
 16d:	48 89 d7             	mov    rdi,rdx
 170:	f3 48 ab             	rep stos QWORD PTR es:[rdi],rax
 173:	48 89 fa             	mov    rdx,rdi
 176:	89 02                	mov    DWORD PTR [rdx],eax
 178:	48 83 c2 04          	add    rdx,0x4
 17c:	88 02                	mov    BYTE PTR [rdx],al
 17e:	48 83 c2 01          	add    rdx,0x1
	char tmp_2[101] = {0};tmp_2[99] = 1;
 182:	48 8d 95 10 ff ff ff 	lea    rdx,[rbp-0xf0]
 189:	b8 00 00 00 00       	mov    eax,0x0
 18e:	b9 0c 00 00 00       	mov    ecx,0xc
 193:	48 89 d7             	mov    rdi,rdx
 196:	f3 48 ab             	rep stos QWORD PTR es:[rdi],rax
 199:	48 89 fa             	mov    rdx,rdi
 19c:	89 02                	mov    DWORD PTR [rdx],eax
 19e:	48 83 c2 04          	add    rdx,0x4
 1a2:	88 02                	mov    BYTE PTR [rdx],al
 1a4:	48 83 c2 01          	add    rdx,0x1
 1a8:	c6 85 73 ff ff ff 01 	mov    BYTE PTR [rbp-0x8d],0x1

	int carry = 0;//1表示进位
 1af:	c7 45 f8 00 00 00 00 	mov    DWORD PTR [rbp-0x8],0x0
	int index = 99;//位数指针
 1b6:	c7 45 f4 63 00 00 00 	mov    DWORD PTR [rbp-0xc],0x63

	if(integer <= 0){
 1bd:	83 bd 0c ff ff ff 00 	cmp    DWORD PTR [rbp-0xf4],0x0
 1c4:	7f 13                	jg     1d9 <fabonacci+0xb8>
        result[99] = 0;
 1c6:	48 8b 85 00 ff ff ff 	mov    rax,QWORD PTR [rbp-0x100]
 1cd:	48 83 c0 63          	add    rax,0x63
 1d1:	c6 00 00             	mov    BYTE PTR [rax],0x0
        return result;
 1d4:	e9 52 01 00 00       	jmp    32b <fabonacci+0x20a>
	}

	if(integer == 1){
 1d9:	83 bd 0c ff ff ff 01 	cmp    DWORD PTR [rbp-0xf4],0x1
 1e0:	0f 85 38 01 00 00    	jne    31e <fabonacci+0x1fd>
        result[99] = 1;
 1e6:	48 8b 85 00 ff ff ff 	mov    rax,QWORD PTR [rbp-0x100]
 1ed:	48 83 c0 63          	add    rax,0x63
 1f1:	c6 00 01             	mov    BYTE PTR [rax],0x1
        return result;
 1f4:	e9 32 01 00 00       	jmp    32b <fabonacci+0x20a>

	while(integer >= 2){//迭代次数

        for(;;){//每一次迭代的加法运算

            if(index < 0)break;
 1f9:	83 7d f4 00          	cmp    DWORD PTR [rbp-0xc],0x0
 1fd:	0f 88 b1 00 00 00    	js     2b4 <fabonacci+0x193>
            //if(carry == 0 && tmp_1[index] == 0 && tmp_2[index] == 0)break;
            result[index] = tmp_1[index] + tmp_2[index];
 203:	8b 45 f4             	mov    eax,DWORD PTR [rbp-0xc]
 206:	48 63 d0             	movsxd rdx,eax
 209:	48 8b 85 00 ff ff ff 	mov    rax,QWORD PTR [rbp-0x100]
 210:	48 01 c2             	add    rdx,rax
 213:	8b 45 f4             	mov    eax,DWORD PTR [rbp-0xc]
 216:	48 98                	cdqe   
 218:	0f b6 44 05 80       	movzx  eax,BYTE PTR [rbp+rax*1-0x80]
 21d:	89 c1                	mov    ecx,eax
 21f:	8b 45 f4             	mov    eax,DWORD PTR [rbp-0xc]
 222:	48 98                	cdqe   
 224:	0f b6 84 05 10 ff ff 	movzx  eax,BYTE PTR [rbp+rax*1-0xf0]
 22b:	ff 
 22c:	01 c8                	add    eax,ecx
 22e:	88 02                	mov    BYTE PTR [rdx],al
            if(carry == 1){
 230:	83 7d f8 01          	cmp    DWORD PTR [rbp-0x8],0x1
 234:	75 2f                	jne    265 <fabonacci+0x144>
                carry = 0;
 236:	c7 45 f8 00 00 00 00 	mov    DWORD PTR [rbp-0x8],0x0
                result[index] += 1;
 23d:	8b 45 f4             	mov    eax,DWORD PTR [rbp-0xc]
 240:	48 63 d0             	movsxd rdx,eax
 243:	48 8b 85 00 ff ff ff 	mov    rax,QWORD PTR [rbp-0x100]
 24a:	48 01 d0             	add    rax,rdx
 24d:	8b 55 f4             	mov    edx,DWORD PTR [rbp-0xc]
 250:	48 63 ca             	movsxd rcx,edx
 253:	48 8b 95 00 ff ff ff 	mov    rdx,QWORD PTR [rbp-0x100]
 25a:	48 01 ca             	add    rdx,rcx
 25d:	0f b6 12             	movzx  edx,BYTE PTR [rdx]
 260:	83 c2 01             	add    edx,0x1
 263:	88 10                	mov    BYTE PTR [rax],dl
            }

            //进位处理
            if(result[index] > 9){
 265:	8b 45 f4             	mov    eax,DWORD PTR [rbp-0xc]
 268:	48 63 d0             	movsxd rdx,eax
 26b:	48 8b 85 00 ff ff ff 	mov    rax,QWORD PTR [rbp-0x100]
 272:	48 01 d0             	add    rax,rdx
 275:	0f b6 00             	movzx  eax,BYTE PTR [rax]
 278:	3c 09                	cmp    al,0x9
 27a:	7e 2f                	jle    2ab <fabonacci+0x18a>
                carry = 1;
 27c:	c7 45 f8 01 00 00 00 	mov    DWORD PTR [rbp-0x8],0x1
                result[index] -= 10;
 283:	8b 45 f4             	mov    eax,DWORD PTR [rbp-0xc]
 286:	48 63 d0             	movsxd rdx,eax
 289:	48 8b 85 00 ff ff ff 	mov    rax,QWORD PTR [rbp-0x100]
 290:	48 01 d0             	add    rax,rdx
 293:	8b 55 f4             	mov    edx,DWORD PTR [rbp-0xc]
 296:	48 63 ca             	movsxd rcx,edx
 299:	48 8b 95 00 ff ff ff 	mov    rdx,QWORD PTR [rbp-0x100]
 2a0:	48 01 ca             	add    rdx,rcx
 2a3:	0f b6 12             	movzx  edx,BYTE PTR [rdx]
 2a6:	83 ea 0a             	sub    edx,0xa
 2a9:	88 10                	mov    BYTE PTR [rax],dl
            }

            index--;
 2ab:	83 6d f4 01          	sub    DWORD PTR [rbp-0xc],0x1
            if(index < 0)break;
 2af:	e9 45 ff ff ff       	jmp    1f9 <fabonacci+0xd8>
 2b4:	90                   	nop
        }
        */
        //回到默认状态
        //tmp_1 = tmp_2;
        //tmp_2 = result;
        for(int i = 0; i < 101; i++)tmp_1[i] = tmp_2[i];
 2b5:	c7 45 f0 00 00 00 00 	mov    DWORD PTR [rbp-0x10],0x0
 2bc:	eb 1a                	jmp    2d8 <fabonacci+0x1b7>
 2be:	8b 45 f0             	mov    eax,DWORD PTR [rbp-0x10]
 2c1:	48 98                	cdqe   
 2c3:	0f b6 94 05 10 ff ff 	movzx  edx,BYTE PTR [rbp+rax*1-0xf0]
 2ca:	ff 
 2cb:	8b 45 f0             	mov    eax,DWORD PTR [rbp-0x10]
 2ce:	48 98                	cdqe   
 2d0:	88 54 05 80          	mov    BYTE PTR [rbp+rax*1-0x80],dl
 2d4:	83 45 f0 01          	add    DWORD PTR [rbp-0x10],0x1
 2d8:	83 7d f0 64          	cmp    DWORD PTR [rbp-0x10],0x64
 2dc:	7e e0                	jle    2be <fabonacci+0x19d>
        for(int i = 0; i < 101; i++)tmp_2[i] = result[i];
 2de:	c7 45 ec 00 00 00 00 	mov    DWORD PTR [rbp-0x14],0x0
 2e5:	eb 23                	jmp    30a <fabonacci+0x1e9>
 2e7:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]
 2ea:	48 63 d0             	movsxd rdx,eax
 2ed:	48 8b 85 00 ff ff ff 	mov    rax,QWORD PTR [rbp-0x100]
 2f4:	48 01 d0             	add    rax,rdx
 2f7:	0f b6 10             	movzx  edx,BYTE PTR [rax]
 2fa:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]
 2fd:	48 98                	cdqe   
 2ff:	88 94 05 10 ff ff ff 	mov    BYTE PTR [rbp+rax*1-0xf0],dl
 306:	83 45 ec 01          	add    DWORD PTR [rbp-0x14],0x1
 30a:	83 7d ec 64          	cmp    DWORD PTR [rbp-0x14],0x64
 30e:	7e d7                	jle    2e7 <fabonacci+0x1c6>
        //memcpy(tmp_1,tmp_2,101);
        //memcpy(tmp_2,result,101);//一个int有4个字节

        index = 99;
 310:	c7 45 f4 63 00 00 00 	mov    DWORD PTR [rbp-0xc],0x63
		integer--;//count++;
 317:	83 ad 0c ff ff ff 01 	sub    DWORD PTR [rbp-0xf4],0x1
	while(integer >= 2){//迭代次数
 31e:	83 bd 0c ff ff ff 01 	cmp    DWORD PTR [rbp-0xf4],0x1
 325:	0f 8f ce fe ff ff    	jg     1f9 <fabonacci+0xd8>
	}
}
 32b:	c9                   	leave  
 32c:	c3                   	ret    

000000000000032d <dowith>:

void dowith(char* nums, char* str){
 32d:	55                   	push   rbp
 32e:	48 89 e5             	mov    rbp,rsp
 331:	48 89 7d e8          	mov    QWORD PTR [rbp-0x18],rdi
 335:	48 89 75 e0          	mov    QWORD PTR [rbp-0x20],rsi

    for(int i = 0; i < 101; i++)str[i] = 0;
 339:	c7 45 fc 00 00 00 00 	mov    DWORD PTR [rbp-0x4],0x0
 340:	eb 14                	jmp    356 <dowith+0x29>
 342:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
 345:	48 63 d0             	movsxd rdx,eax
 348:	48 8b 45 e0          	mov    rax,QWORD PTR [rbp-0x20]
 34c:	48 01 d0             	add    rax,rdx
 34f:	c6 00 00             	mov    BYTE PTR [rax],0x0
 352:	83 45 fc 01          	add    DWORD PTR [rbp-0x4],0x1
 356:	83 7d fc 64          	cmp    DWORD PTR [rbp-0x4],0x64
 35a:	7e e6                	jle    342 <dowith+0x15>

    int src_index = 0;//指示第一位
 35c:	c7 45 f8 00 00 00 00 	mov    DWORD PTR [rbp-0x8],0x0
    int des_index = 0;//这个是str【】专用的游标cursor
 363:	c7 45 f4 00 00 00 00 	mov    DWORD PTR [rbp-0xc],0x0

    while(nums[src_index] == 0){
 36a:	eb 13                	jmp    37f <dowith+0x52>
        src_index++;
 36c:	83 45 f8 01          	add    DWORD PTR [rbp-0x8],0x1
        if(src_index == 100){src_index = 99;break;}
 370:	83 7d f8 64          	cmp    DWORD PTR [rbp-0x8],0x64
 374:	75 09                	jne    37f <dowith+0x52>
 376:	c7 45 f8 63 00 00 00 	mov    DWORD PTR [rbp-0x8],0x63
 37d:	eb 14                	jmp    393 <dowith+0x66>
    while(nums[src_index] == 0){
 37f:	8b 45 f8             	mov    eax,DWORD PTR [rbp-0x8]
 382:	48 63 d0             	movsxd rdx,eax
 385:	48 8b 45 e8          	mov    rax,QWORD PTR [rbp-0x18]
 389:	48 01 d0             	add    rax,rdx
 38c:	0f b6 00             	movzx  eax,BYTE PTR [rax]
 38f:	84 c0                	test   al,al
 391:	74 d9                	je     36c <dowith+0x3f>
    }

    while(src_index < 100){
 393:	eb 2f                	jmp    3c4 <dowith+0x97>
        str[des_index++]  = nums[src_index++] + 48; //显示ascii码
 395:	8b 45 f4             	mov    eax,DWORD PTR [rbp-0xc]
 398:	8d 50 01             	lea    edx,[rax+0x1]
 39b:	89 55 f4             	mov    DWORD PTR [rbp-0xc],edx
 39e:	48 63 d0             	movsxd rdx,eax
 3a1:	48 8b 45 e0          	mov    rax,QWORD PTR [rbp-0x20]
 3a5:	48 8d 0c 02          	lea    rcx,[rdx+rax*1]
 3a9:	8b 45 f8             	mov    eax,DWORD PTR [rbp-0x8]
 3ac:	8d 50 01             	lea    edx,[rax+0x1]
 3af:	89 55 f8             	mov    DWORD PTR [rbp-0x8],edx
 3b2:	48 63 d0             	movsxd rdx,eax
 3b5:	48 8b 45 e8          	mov    rax,QWORD PTR [rbp-0x18]
 3b9:	48 01 d0             	add    rax,rdx
 3bc:	0f b6 00             	movzx  eax,BYTE PTR [rax]
 3bf:	83 c0 30             	add    eax,0x30
 3c2:	88 01                	mov    BYTE PTR [rcx],al
    while(src_index < 100){
 3c4:	83 7d f8 63          	cmp    DWORD PTR [rbp-0x8],0x63
 3c8:	7e cb                	jle    395 <dowith+0x68>
    }
}
 3ca:	90                   	nop
 3cb:	5d                   	pop    rbp
 3cc:	c3                   	ret    
