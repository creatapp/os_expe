# 实验二

本次参考了该篇博客的读取BPB、rootEntry以及寻找Fat和计算数据区的代码--很多直接使用 :< 

博客地址：[csdn](https://blog.csdn.net/yxc135/article/details/8769086)

## 我的部分

1. 将FAT12文件读取以后构造成一棵二叉树

2. 修复博客里读取FAT entry的错误

3. 支持读取512字节以上的文件

4. 支持要求的`ls`,`cat`,`count`,`exit`等的操作

5. 支持文件夹的嵌套读取

6. 链接汇编asm的打印函数

7. makefile

8. 进一步增加注释
