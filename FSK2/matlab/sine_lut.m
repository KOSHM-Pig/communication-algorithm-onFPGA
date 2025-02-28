clc;

max = 1024;

theta = (0:max-1) * (2*pi / max) ;

sine_values = round(1023 * sin(theta));

plot(sine_values); %画图

sine_hex = dec2hex(sine_values);


%创建mif文件
fild = fopen('sin_wave_1024x16.mif','wt');
%写入mif文件头
fprintf(fild, '%s\n','WIDTH=16;');           %位宽
fprintf(fild, '%s\n\n','DEPTH=1024;');      %深度
fprintf(fild, '%s\n','ADDRESS_RADIX=UNS;'); %地址格式
fprintf(fild, '%s\n\n','DATA_RADIX=UNS;');  %数据格式
fprintf(fild, '%s\t','CONTENT');            %地址
fprintf(fild, '%s\n','BEGIN');              %开始
for i = 1:max

    fprintf(fild, '\t%g\t',i-1);    %地址编码
    fprintf(fild, '%s\t',':');      %冒号
    fprintf(fild, '%s',sine_hex(i,:));      %数据写入
    fprintf(fild, '%s\n',';');      %分号，换行
end
fprintf(fild, '%s\n','END;');       %结束
fclose(fild);