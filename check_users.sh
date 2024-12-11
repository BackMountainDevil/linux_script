#!/bin/bash
# 读取check.txt文件，一行是一个用户名，判断系统是否存在该用户，如果存在，将用户名写入exist.txt，不存在则写入到nonexist.txt
# 定义输入文件和输出文件
input_file="check.txt"
exist_file="exist.txt"
nonexist_file="nonexist.txt"

# 清空输出文件（如果存在）
> "$exist_file"
> "$nonexist_file"

# 读取输入文件的每一行
while IFS= read -r username || [[ -n "$username" ]]; do
    # 去掉用户名前后的空白字符
    username=$(echo "$username" | tr -d '[:space:]')

    # 检查用户是否存在
    if id "$username" &>/dev/null; then
        echo "$username" >> "$exist_file"
    else
        echo "$username" >> "$nonexist_file"
    fi
done < "$input_file"