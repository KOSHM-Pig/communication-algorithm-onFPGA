close all;          %关闭文件操作
%clear all;         %清理工作区
clc;                %清除命令行

%创建一个文件
%coe 所有的系数都乘以1024
%所有变大的系数都存在一个文件里

fid = fopen('num','w'); 

num_coe = coe .* 512;  %系数放大，.*所有的系数都会乘1024
num_int = round(num_coe);%四舍五入


%printf
for i = 1 :32
    fprintf(fid,'%d\r\n',num_int(i));
end

fclose(fid);

