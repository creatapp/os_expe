#include<stdio.h>
//#include<string.h>//使用memcpy

#define NONE "\033[0m"
#define RED "\033[31m"
#define GREEN "\033[32m"
#define BLUE "\033[34m"
#define PURPLE "\033[35m"
#define YELLOW "\033[33m"

//280571172992510140037611932413038677189525
//数字有点长，需要实现大的整数相加，采用char*

char* color[] =  {RED, GREEN, BLUE, PURPLE, YELLOW};

void fabonacci(int, char[101]);
void dowith(char[101], char[101]);

int main(void){
	printf("%s\n","fabonacci, two numbers required:" );

	int a, b;

	int index = 0;

	scanf("%d %d",&a, &b);

	char c[101] = {0};//result

	char re_after[101] = {0};//处理后的数组，可以直接显示

	//int i = a;
	//char* strp = "";

	for(int i = a; i <= b; i++){
		fabonacci(i,c);
        //ltoa(c,strp,10);
		index = (index + 1) > 4 ? 0 : index + 1;

		dowith(c, re_after);

		printf("%s%s%s\n", color[index],re_after,NONE);
	}

}

void fabonacci(int integer, char* result){

    for(int i = 0; i < 101; i++)result[i] = 0;

    char tmp_1[101] = {0};//tmp_1[49] = 0;
	char tmp_2[101] = {0};tmp_2[99] = 1;

	int carry = 0;//1表示进位
	int index = 99;//位数指针

	if(integer <= 0){
        result[99] = 0;
        return result;
	}

	if(integer == 1){
        result[99] = 1;
        return result;
	}

	//int count = 0;//helper

	while(integer >= 2){//迭代次数

        for(;;){//每一次迭代的加法运算

            if(index < 0)break;
            //if(carry == 0 && tmp_1[index] == 0 && tmp_2[index] == 0)break;
            result[index] = tmp_1[index] + tmp_2[index];
            if(carry == 1){
                carry = 0;
                result[index] += 1;
            }

            //进位处理
            if(result[index] > 9){
                carry = 1;
                result[index] -= 10;
            }

            index--;
        }

        /*
        if(count >= 163){//打印错误位置
                char str1[101] = {0};char str2[101] = {0};char str3[101] = {0};
                dowith(tmp_1,str1);dowith(tmp_2,str2);dowith(result, str3);
                printf("str1:    %s\n", str1);
                printf("str2:    %s\n", str2);
                printf("result:    %s\n", str3);
                for(int i = 0 ; i < 101; i ++){str1[i] = 0; str2[i] = 0;}
        }
        */
        //回到默认状态
        //tmp_1 = tmp_2;
        //tmp_2 = result;
        for(int i = 0; i < 101; i++)tmp_1[i] = tmp_2[i];
        for(int i = 0; i < 101; i++)tmp_2[i] = result[i];
        //memcpy(tmp_1,tmp_2,101);
        //memcpy(tmp_2,result,101);//一个int有4个字节

        index = 99;
		integer--;//count++;
	}
}

void dowith(char* nums, char* str){

    for(int i = 0; i < 101; i++)str[i] = 0;

    int src_index = 0;//指示第一位
    int des_index = 0;//这个是str【】专用的游标cursor

    while(nums[src_index] == 0){
        src_index++;
        if(src_index == 100){src_index = 99;break;}
    }

    while(src_index < 100){
        str[des_index++]  = nums[src_index++] + 48; //显示ascii码
    }
}
