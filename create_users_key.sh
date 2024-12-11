#!/bin/bash
# 读取 nonexist.txt 文件中的每一行用户名，然后为每个用户创建账户、设置默认密码、生成 SSH 密钥对，并将公钥追加到用户的 authorized_keys 文件中，最后将私钥拷贝到 keys 目录并重命名为 key_用户名。

# 检查是否以root用户运行
if [ "$(id -u)" -ne 0 ]; then
    echo "错误：此脚本必须以root用户运行。"
    exit 1
fi

# 定义输入文件和输出目录
input_file="nonexist.txt"
keys_dir="keys"

# 检查输入文件是否存在
if [[ ! -f "$input_file" ]]; then
    echo "错误：文件 '$input_file' 不存在。"
    exit 1
fi

# 创建keys目录
mkdir -p "$keys_dir"

# 读取输入文件的每一行
while IFS= read -r username || [[ -n "$username" ]]; do
    # 去掉用户名前后的空白字符
    username=$(echo "$username" | tr -d '[:space:]')

    # 检查用户名是否为空
    if [[ -z "$username" ]]; then
        continue
    fi

    # 创建用户
    echo "正在创建用户: $username"
    useradd -m -s /bin/bash "$username"

    # 设置用户密码（默认密码为用户名）
    echo "$username:$username" | chpasswd

    # 创建用户的主目录和.ssh目录
    home_dir="/home/$username"
    mkdir -p "$home_dir/.ssh"
    chown "$username:$username" "$home_dir/.ssh"
    chmod 700 "$home_dir/.ssh"

    # 生成SSH密钥
    echo "正在为 $username 生成SSH密钥..."
    su -c "ssh-keygen -t ed25519 -N '' -f $home_dir/.ssh/id_ed25519" "$username"

    # 将公钥追加到authorized_keys文件中
    cat "$home_dir/.ssh/id_ed25519.pub" >> "$home_dir/.ssh/authorized_keys"
    chmod 600 "$home_dir/.ssh/authorized_keys"
    chown "$username:$username" -R "$home_dir/.ssh"

    # 将私钥保存到keys目录下
    cp "$home_dir/.ssh/id_ed25519" "$keys_dir/key_$username"
    chmod 600 "$keys_dir/key_$username"

    echo "用户 $username 已创建，并为其生成了SSH密钥。"
    echo "密钥已保存到当前目录下的'$keys_dir'文件夹中。"
done < "$input_file"

echo "所有用户创建完成。"