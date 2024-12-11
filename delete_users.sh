#!/bin/bash
# 读取exist.txt文件，一行是一个用户名，然后删除该用户！同时删除用户目录！！！
# 定义输入文件
input_file="exist.txt"

# 检查输入文件是否存在
if [[ ! -f "$input_file" ]]; then
    echo "Error: File '$input_file' does not exist."
    exit 1
fi

# 读取输入文件的每一行
while IFS= read -r username || [[ -n "$username" ]]; do
    # 去掉用户名前后的空白字符
    username=$(echo "$username" | tr -d '[:space:]')

    # 检查用户名是否为空
    if [[ -z "$username" ]]; then
        continue
    fi

    # 删除用户
    echo "Deleting user: $username"
    if userdel -r "$username" &>/dev/null; then
        echo "User '$username' deleted successfully."
    else
        echo "Failed to delete user '$username'."
    fi
done < "$input_file"