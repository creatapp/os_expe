/*
 *author:王宁
 *date:2018/5/6
*/

/*
如何寻找大于512字节的文件：利用根目录区找到该文件，然后读取FAT项的firstCluster就可以依次寻找接下来的文件区块
*/

/*
怎样建立目录结构？
1、根目录下的文件或文件夹都在根目录区域19开始
2、如果是文件夹，需要在FAT找到
*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define nullptr 0

//数据定义
//注意unsigned,后面左移的时候不再考虑补1
typedef unsigned char b1;
typedef unsigned short b2;
typedef unsigned int b4;

//全局变量
//命令参数
const char* CMD_LS    = "ls";
const char* CMD_CAT   = "cat";
const char* CMD_COUNT = "count";
const char* CMD_EXIT  = "exit";

//寻址参数
int  BytsPerSec;    //每扇区字节数
int  SecPerClus;    //每簇扇区数
int  RsvdSecCnt;    //Boot记录占用的扇区数
int  NumFATs;       //FAT表个数
int  RootEntCnt;    //根目录最大文件数
int  FATSz;         //FAT扇区数

#pragma pack (1) /*指定按1字节对齐*/

//结构体
struct BPB
{//偏移11个字节
    b2  BPB_BytsPerSec;    //每扇区字节数
    b1  BPB_SecPerClus;    //每簇扇区数
    b2  BPB_RsvdSecCnt;    //Boot记录占用的扇区数
    b1  BPB_NumFATs;       //FAT表个数
    b2  BPB_RootEntCnt;    //根目录最大文件数
    b2  BPB_TotSec16;      //对于逻辑卷大小小于等于32MB有效
    b1  BPB_Media;         //介质描述
    b2  BPB_FATSz16;       //FAT扇区数
    b2  BPB_SecPerTrk;     //每个磁道的扇区数，通常63
    b2  BPB_NumHeads;      //heads的数量
    b4  BPB_HiddSec;       //隐藏扇区数量
    b4  BPB_TotSec32;      //如果BPB_FATSz16为0，该值为FAT扇区数
};//BPB至此结束，长度25字节

struct RootEntry
{//根目录条目
    char DIR_Name[11];
    b1   DIR_Attr;         //文件属性
    char reserved[10];
    b2  DIR_WrtTime;
    b2  DIR_WrtDate;
    b2  DIR_FstClus;       //开始簇号
    b4  DIR_FileSize;
};//根目录条目结束，32字节

#pragma pack () /*指定按1字节对齐*/

typedef struct TreeNode
{
    char* fileName;
    bool isDir;
    char* fileContent;//如果是文件就需要把文件内容分配到一个区域，然后指定该指针
    struct TreeNode* children;
    struct TreeNode* sibling;
    struct TreeNode* father;
    int fileNum;//方便count
    int dirNum;
}Node;

/*img目录树*/
//文件树
Node* rootDir;//根目录
Node* findNodeRe;

/*为实现简单队列，使用链表的方式*/
typedef struct Queue
{
    Node* curNode;
    Node* next;
}QueueNode;
QueueNode* queueHead;//用于层次遍历的数组
QueueNode* queueTail;

//使用方法
void getImgInfo(FILE* img);
void ls(FILE* img, char* dir);
void cat(FILE* img, char* file);
void count(FILE* img, char* dir);
void print_asm(char* content);

//find some node
void findNode(Node* node, char* path);
//add node under some node
void addNode(Node* node);
//traverse from some node
void traverse(Node* node, bool isLs);

//这个方法将Fat12文件映射为一棵树中
void getFileTree(FILE* img);
//将文件全部载入进来
void loadFile(FILE* img, int clus, char* content, int size);
void addChildren(FILE* img, int clus, Node* fatherNode,char* fatherPath);
int getFATValue(FILE* img, int clus);

void my_print(char* buf, int size);

int main()
{
    //载入img并读取必要信息
    FILE* img = fopen("../d.img","rb");
    getImgInfo(img);
    getFileTree(img);

    //主循环读取各个输入的指令
    for(;;)
    {
        char* cmd = (char*)malloc(6);
        char* command = (char*)malloc(128);
        print_asm("\ncommand here:\n");
        fgets(command,128,stdin);
        int idx = 0;
        int sub_idx = 0;
        while(command[idx] != '\n' && command[idx] != ' ' && idx <= 5)
        {
            cmd[idx] = command[idx];
            idx++;
        }
        cmd[idx] = '\0';

        if(0 == strcmp(cmd,CMD_LS))
        {
            char* dir = (char*)malloc(25);
            while(command[idx] != '\n' && idx < 128 && command[++idx] != '\n')
            {
                dir[sub_idx++] = command[idx];
            }
            dir[sub_idx] = '\0';
            if(sub_idx == 0)
            {
                //root
                dir[0] = '/';
                dir[1] = '\0';
            }
            ls(img,dir);
            free(dir);
        }
        else if(0 == strcmp(cmd,CMD_CAT))
        {
            char* file = (char*)malloc(25);
            while(command[idx] != '\n' && command[++idx] != '\n' && idx < 128)
            {
                file[sub_idx++] = command[idx];
            }
            file[sub_idx] = '\0';
            cat(img,file);
            free(file);
        }
        else if(0 == strcmp(cmd,CMD_COUNT))
        {
            char* dir = (char*)malloc(25);
            while(command[idx] != '\n' && command[++idx] != '\n' && idx < 128)
            {
                dir[sub_idx++] = command[idx];
            }
            dir[sub_idx] = '\0';
            count(img,dir);
            free(dir);
        }
        else if(0 == strcmp(cmd,CMD_EXIT))
        {
            free(cmd);
            return 1;
        }
        else
        {
            print_asm("\nunsupported command.\n");
        }
    }
}

//执行指令
void getImgInfo(FILE* img)
{
    struct BPB bpb;
    struct BPB* bpbptr = &bpb;
    fseek(img,11,SEEK_SET);
    fread(bpbptr,1,25,img);//不考虑读取失败的情况，下同
    //初始化寻址参数
    BytsPerSec = bpbptr->BPB_BytsPerSec;
    SecPerClus = bpbptr->BPB_SecPerClus;
    RsvdSecCnt = bpbptr->BPB_RsvdSecCnt;
    NumFATs    = bpbptr->BPB_NumFATs;
    RootEntCnt = bpbptr->BPB_RootEntCnt;
    if(bpbptr->BPB_FATSz16 != 0)
    {
        FATSz = bpbptr->BPB_FATSz16;
    }
    else
    {
        FATSz = bpbptr->BPB_TotSec32;
    }
}

//这个方法将Fat12文件映射为一棵树中
void getFileTree(FILE* img)
{
    //初始化根结点
    rootDir = (Node*)malloc(sizeof(Node));
    rootDir->children = nullptr;
    rootDir->dirNum = 0;
    rootDir->fileContent = nullptr;
    char* rootName = (char*)malloc(12);
    rootName[0] = '/';
    rootName[1] = '\0';
    rootDir->fileName = rootName;
    rootDir->fileNum = 0;
    rootDir->isDir = true;
    rootDir->sibling = nullptr;
    rootDir->father = nullptr;

    struct RootEntry rootEntry;
    struct RootEntry* rootEntryPtr = &rootEntry;

    int dirBase = (RsvdSecCnt + NumFATs * FATSz) * BytsPerSec;
    for(int i = 0; i < RootEntCnt; i++)
    {
        fseek(img,dirBase,SEEK_SET);
        fread(rootEntryPtr,1,32,img);
        dirBase+=32;

        if(rootEntryPtr->DIR_Name[0] == '\0')continue;//没有文件或者目录就跳过
        //过滤非目标文件
        int boolean = 0;
        for (int j=0;j<11;j++) {
            if (!(((rootEntryPtr->DIR_Name[j] >= 48)&&(rootEntryPtr->DIR_Name[j] <= 57)) ||
                ((rootEntryPtr->DIR_Name[j] >= 65)&&(rootEntryPtr->DIR_Name[j] <= 90)) ||
                    ((rootEntryPtr->DIR_Name[j] >= 97)&&(rootEntryPtr->DIR_Name[j] <= 122)) ||
                        (rootEntryPtr->DIR_Name[j] == ' '))) {
                boolean = 1;    //非英文及数字、空格
                break;
            }
        }
        if (boolean == 1) continue; //非目标文件不输出

        if((rootEntryPtr->DIR_Attr&0x10) == 0)//文件
        {
            char* realName = (char*)malloc(15);//最后一二存放'/0'
            int tempLong = -1;
            for(int k = 0; k < 11; k++)
            {
                if(rootEntryPtr->DIR_Name[k] != ' ')
                {
                    tempLong++;
                    realName[tempLong] = rootEntryPtr->DIR_Name[k];
                }
                else//空格替换成点号
                {
                    tempLong++;
                    realName[tempLong] = '.';
                    while(rootEntryPtr->DIR_Name[k] == ' ')k++;
                    k--;
                }
            }
            tempLong++;
            realName[tempLong] = '\0';

            //此时得到的是根目录下的文件
            Node* newNode;
            newNode = (Node*)malloc(sizeof(Node));
            newNode->children = nullptr;
            newNode->dirNum = 0;
            char* content = (char*)malloc(rootEntryPtr->DIR_FileSize + 1);//最多分配2K
            loadFile(img, rootEntryPtr->DIR_FstClus, content, rootEntryPtr->DIR_FileSize);
            content[rootEntryPtr->DIR_FileSize] = '\0';
            newNode->fileContent = content;
            char* giveName = (char*)malloc(15);
            giveName[0] = '/';
            strcpy(giveName + 1,realName);
            newNode->fileName = giveName;
            newNode->fileNum = 0;
            newNode->isDir = false;
            newNode->sibling = nullptr;
            addNode(newNode);
        }
        else//目录
        {
            char* realName = (char*)malloc(15);//最后一二存放'/0'
            int tempLong = -1;
            for(int k = 0; k < 11; k++)
            {
                if(rootEntryPtr->DIR_Name[k] != ' ')
                {
                    tempLong++;
                    realName[tempLong] = rootEntryPtr->DIR_Name[k];
                }
                else
                {
                    tempLong++;
                    realName[tempLong] = '\0';
                    break;
                }
            }

            //加入根目录下的文件夹
            Node* newNode;
            newNode = (Node*)malloc(sizeof(Node));
            newNode->children = nullptr;
            newNode->dirNum = 0;
            newNode->fileContent = nullptr;
            char* giveName = (char*)malloc(15);
            giveName[0] = '/';
            strcpy(giveName + 1,realName);
            newNode->fileName = giveName;
            newNode->fileNum = 0;
            newNode->isDir = true;
            newNode->sibling = nullptr;
            addNode(newNode);

            addChildren(img,rootEntryPtr->DIR_FstClus,newNode,giveName);
        }

    }
}

//将文件全部载入进来
void loadFile(FILE* img, int clus, char* content,int size)
{
    //假设content是足量的
    int dataBase = BytsPerSec * (RsvdSecCnt + FATSz * NumFATs + (RootEntCnt * 32 + BytsPerSec - 1) / BytsPerSec);//数据区的偏移
    int fatValue = clus;
    int contentIdx = 0;
    while(fatValue < 0xff7)
    {
        if(size <= BytsPerSec * SecPerClus)
        {
            fseek(img,dataBase + (fatValue - 2) * BytsPerSec * SecPerClus, SEEK_SET);
            fread(content + contentIdx,1,size, img);
            return;
        }
         fseek(img,dataBase + (fatValue - 2) * BytsPerSec * SecPerClus, SEEK_SET);
         fread(content + contentIdx,1,BytsPerSec * SecPerClus, img);
         fatValue = getFATValue(img,fatValue);
         contentIdx += BytsPerSec * SecPerClus;
         size -= BytsPerSec * SecPerClus;
    }
}

//递归的增加子节点
void addChildren(FILE* img, int clus, Node* fatherNode,char* fatherPath)
{
    //传来的Clus所指向的数据区域是dir_entry,需要32字节地读取
    int dataBase = BytsPerSec * (RsvdSecCnt + FATSz * NumFATs + (RootEntCnt * 32 + BytsPerSec - 1) / BytsPerSec);

    int currentClus = clus;
    int value = 0;
    while (value < 0xff7) {
        value = getFATValue(img, currentClus);
        char* str = (char*)malloc(SecPerClus * BytsPerSec);  //暂存从簇中读出的数据
        char* content = str;

        int startByte = dataBase + (currentClus - 2) * SecPerClus * BytsPerSec;
        fseek(img,startByte,SEEK_SET);
        fread(content,1,SecPerClus * BytsPerSec, img);
        //解析content中的数据,依次处理各个条目,目录下每个条目结构与根目录下的目录结构相同
        int count = SecPerClus * BytsPerSec;  //每簇的字节数
        int loop = 0;
        while (loop < count) {
            if (content[loop] == '\0') {
                loop += 32;
                continue;
            }   //空条目不输出

            //将32字节的信息映射成为root-entry
            struct RootEntry rootEntry;
            struct RootEntry* rootEntryPtr = &rootEntry;
            fseek(img,startByte+loop,SEEK_SET);
            fread(rootEntryPtr,1,32,img);

            if(rootEntryPtr->DIR_Name[0] == '\0')continue;//没有文件或者目录就跳过
                    //过滤非目标文件
            int boolean = 0;
            for (int j=0;j<11;j++) {
                if (!(((rootEntryPtr->DIR_Name[j] >= 48)&&(rootEntryPtr->DIR_Name[j] <= 57)) ||
                    ((rootEntryPtr->DIR_Name[j] >= 65)&&(rootEntryPtr->DIR_Name[j] <= 90)) ||
                        ((rootEntryPtr->DIR_Name[j] >= 97)&&(rootEntryPtr->DIR_Name[j] <= 122)) ||
                            (rootEntryPtr->DIR_Name[j] == ' '))) {
                    boolean = 1;    //非英文及数字、空格
                    break;
                }
            }
            if (boolean == 1)
            {
                loop += 32;
                continue; //非目标文件不输出
            }

            if((rootEntryPtr->DIR_Attr&0x10) == 0)//文件
            {
                int lenPath = strlen(fatherPath);
                char* childFileName = (char*)malloc(128);
                strcpy(childFileName,fatherPath);
                childFileName[lenPath++] = '/';
                childFileName[lenPath] = '\0';
                char*childFileNamePtr = &childFileName[lenPath];
                int tempLong = -1;
                for(int k = 0; k < 11; k++)
                {
                    if(rootEntryPtr->DIR_Name[k] != ' ')
                    {
                        tempLong++;
                        childFileNamePtr[tempLong] = rootEntryPtr->DIR_Name[k];
                    }
                    else//空格替换成点号
                    {
                        tempLong++;
                        childFileNamePtr[tempLong] = '.';
                        while(rootEntryPtr->DIR_Name[k] == ' ')k++;
                        k--;
                    }
                }
                tempLong++;
                childFileNamePtr[tempLong] = '\0';
                //文件
                Node* newNode;
                newNode = (Node*)malloc(sizeof(Node));
                newNode->children = nullptr;
                newNode->dirNum = 0;
                char* content = (char*)malloc(rootEntryPtr->DIR_FileSize + 1);//最多分配2K
                loadFile(img, rootEntryPtr->DIR_FstClus, content, rootEntryPtr->DIR_FileSize + 1);
                content[rootEntryPtr->DIR_FileSize] = '\0';
                newNode->fileContent = content;
                newNode->fileName = childFileName;
                newNode->fileNum = 0;
                newNode->isDir = false;
                newNode->sibling = nullptr;
                addNode(newNode);
            }
            else//目录
            {
                int lenPath = strlen(fatherPath);
                char* childFileName = (char*)malloc(128);
                strcpy(childFileName,fatherPath);
                childFileName[lenPath++] = '/';
                childFileName[lenPath] = '\0';
                char*childFileNamePtr = &childFileName[lenPath];
                int tempLong = -1;
                for(int k = 0; k < 11; k++)
                {
                    if(rootEntryPtr->DIR_Name[k] != ' ')
                    {
                        tempLong++;
                        childFileNamePtr[tempLong] = rootEntryPtr->DIR_Name[k];
                    }
                    else
                    {
                        tempLong++;
                        childFileNamePtr[tempLong] = '\0';
                        break;
                    }
                }
                //文件夹
                Node* newNode;
                newNode = (Node*)malloc(sizeof(Node));
                newNode->children = nullptr;
                newNode->dirNum = 0;
                newNode->fileContent = nullptr;
                newNode->fileName = childFileName;
                newNode->fileNum = 0;
                newNode->isDir = true;
                newNode->sibling = nullptr;
                addNode(newNode);
                addChildren(img,rootEntryPtr->DIR_FstClus,newNode,childFileName);
            }
            loop += 32;
        }
        free(str);
        currentClus = value;
    };
}

int getFATValue(FILE* img, int clus)
{
    int fatBase = RsvdSecCnt * BytsPerSec;
    int fatPos = fatBase + clus / 2 + clus;
    //区分奇偶
    int type = 0;
    if(clus % 2 != 0)
    {
        type = 1;
    }
    b2 candidate;
    b2* candidatePtr = &candidate;
    fseek(img, fatPos, SEEK_SET);
    fread(candidatePtr, 1, 2, img);
    if(type == 0)
    {
        return candidate & 0x0fff;
    }
    else
    {
        return (candidate & 0xfff0) >> 4;
    }
}

void ls(FILE* img, char* dir)
{
    findNodeRe = nullptr;
    findNode(rootDir,dir);
    if(!findNodeRe)
    {
        print_asm("can't find this path\n");
        return;
    }
    traverse(findNodeRe,true);
}

void cat(FILE* img, char* file)
{
    findNodeRe = nullptr;
    findNode(rootDir,file);
    if(findNodeRe)
    {
        if(findNodeRe->isDir)
        {
            //printf("%s is not a file.\n",findNodeRe->fileName);
            print_asm(findNodeRe->fileName);
            print_asm(" is not a file.\n");
            return;
        }
        print_asm(findNodeRe->fileContent);
    }
    else
    {
        print_asm("can't find this file\n");
    }
}

void count(FILE* img, char* dir)
{
    findNodeRe = nullptr;
    findNode(rootDir,dir);
    if(!findNodeRe)
    {
        print_asm("can't find this file.\n");
    }
    traverse(findNodeRe,false);
}

void print_asm(char* content)
{
    my_print(content,strlen(content));
}


/********************树的操作函数实现***********************/

//find some node
void findNode(Node* node, char* path)
{
/*
    //传进来的路径应该是/A/B..的，
    //如果开始没有输入/，则系统自动补充，其它错误就属于输入错误
    char* newPath = (char*)malloc(50 * sizeof(char));
    int i = 0,j = 0;
    if(path[0] != '/')
    {
        newPath[0] = '/';
        i = 1;
    }
    while(path[j] != '\0')
    {
        newPath[i++] = path[j++];
    }
*/
    //开始寻找
    if(node)
    {
        if(0 == strcmp(node->fileName,path))
        {
            findNodeRe = node;
        }
        findNode(node->sibling,path);
        findNode(node->children,path);
    }
}

//add node under some node
void addNode(Node* node)
{
    //需要截取文件名以确定父节点
    char* fatherPath = (char*)malloc(128);
    char* lastFileSepaAddr = strrchr(node->fileName,'/');
    if((node->fileName) == lastFileSepaAddr)
    {
        fatherPath[0] = '/';
        fatherPath[1] = '\0';
    }
    else
    {
        int i = 0;
        while((node->fileName) + i < lastFileSepaAddr)
        {
            fatherPath[i] = node->fileName[i];
            i++;
        }
        fatherPath[i] = '\0';
    }

    findNodeRe = nullptr;
    findNode(rootDir,fatherPath);
    Node* fatherNode = findNodeRe;
    if(fatherNode == nullptr || fatherNode->isDir == false)
    {
        //printf("no such dir");
        free(fatherPath);
        return;
    }

    //更改父节点数据
    //需要更改所有父节点直到根
    Node* tmp = fatherNode;
    node->father = fatherNode;
    if(node->isDir)
    {
        while(tmp != nullptr)
        {
            tmp->dirNum += 1;
            tmp = tmp->father;
        }
    }
    else
    {
        while(tmp != nullptr)
        {
            tmp->fileNum += 1;
            tmp = tmp->father;
        }
    }

    //挂载
    if(fatherNode->children == nullptr)
    {
        fatherNode->children = node;
    }
    else
    {
        Node* sibling = fatherNode->children;
        while(sibling->sibling != nullptr)
        {
            sibling = sibling->sibling;
        }
        sibling->sibling = node;
    }

    //free(fatherPath);
    return;
}

//traverse from some node
void traverse(Node* node, bool isLs)
{
    //先序遍历，打印所有遍历到的节点
    if(!isLs)
    {
        if(node)
        {
            if(node->isDir)
            {
                char* from = (node->fileName);
                char* intCh = (char*)malloc(3);
                //printf("%s: %d file(s) %d dir(s)\n",from,node->fileNum,node->dirNum);
                print_asm(from);
                print_asm(": ");
                sprintf(intCh,"%d",node->fileNum);
                print_asm(intCh);
                print_asm(" file(s) ");
                sprintf(intCh,"%d",node->dirNum);
                print_asm(intCh);
                print_asm(" dir(s)\n");
                //printf('\n');
                traverse_count(node->children,strlen(node->fileName));
            }
            else
            {
                 print_asm(node->fileName);
                 print_asm(" is not a dir.\n");
                 return;
            }
        }
    }
    else
    {
        //先初始化队列
        QueueNode* queueNode = (QueueNode*)malloc(sizeof(QueueNode));
        queueNode->curNode = node;
        queueNode->next = nullptr;
        queueHead = queueNode;
        queueTail = queueNode;

        if(!node->isDir)
        {
            //printf("%s is not a dir",node->fileName);
            print_asm(node->fileName);
            print_asm(" is not a dir.\n");
            return;
        }

        traverse_ls(node);
    }
}

void traverse_ls(Node* node)
{
    //层次遍历
    //每一次递归打印所有子女并且将他们加入队列里
    if(node != nullptr && node->isDir)
    {
        Node* tmp = node->children;
        int pathlen = strlen(node->fileName) <= 1 ? strlen(node->fileName) : strlen(node->fileName) + 1;
        if(pathlen <= 1)
        {
            //printf("%s :\n",node->fileName);
            print_asm(node->fileName);
            print_asm(" :\n");
        }
        else
        {
            //printf("%s/ :\n",node->fileName);
            print_asm(node->fileName);
            print_asm("/ :\n");
        }
        //printf("%s/ :\n",node->fileName);
        while(tmp != nullptr)
        {
            if(tmp->isDir)//文件夹需要换颜色而且继续遍历
            {
                //printf("%s%s%s ","\e[1;33m",tmp->fileName + pathlen,"\e[0m");
                print_asm("\e[1;33m");
                print_asm(tmp->fileName + pathlen);
                print_asm("\e[0m ");
                QueueNode* queueNode = (QueueNode*)malloc(sizeof(QueueNode));
                queueNode->curNode = tmp;
                queueNode->next = nullptr;
                queueTail->next = queueNode;
                queueTail = queueNode;
            }
            else
            {
                //printf("%s ",tmp->fileName + pathlen);
                print_asm(tmp->fileName + pathlen);
                print_asm(" ");
            }
            tmp = tmp->sibling;
        }
        print_asm("\n\n");
        QueueNode* queue = queueHead;
        queueHead = queueHead->next;
        free(queue);

        //队列不为空就开始递归
        if(queueHead != nullptr)
        {
            traverse_ls(queueHead->curNode);
        }
    }
}

void traverse_count(Node* node,int spaceCnt)
{
    //先序遍历
     if(node)
    {
        if(node->isDir)
        {
            char* from = (node->fileName) + spaceCnt;
            char* intCh = (char*)malloc(3);
            for(int i = 0 ;i < spaceCnt; i++)print_asm(" ");
            //printf("%s: %d file(s) %d dir(s)\n",from,node->fileNum,node->dirNum);
            print_asm(from);
            print_asm(": ");
            sprintf(intCh,"%d",node->fileNum);
            print_asm(intCh);
            print_asm(" file(s) ");
            sprintf(intCh,"%d",node->dirNum);
            print_asm(intCh);
            print_asm(" dir(s)\n");
            //printf('\n');
        }
        traverse_count(node->children,strlen(node->fileName));
        traverse_count(node->sibling,spaceCnt);
    }
}
