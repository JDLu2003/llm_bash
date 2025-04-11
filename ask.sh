#!/bin/zsh

# 定义 Python 程序的路径，硬编码为 ask.py
PYTHON_SCRIPT="/Users/jdlu/Project/local_llm/ask.py"
PYTHON_EXEC="/Users/jdlu/Project/local_llm/local_llm/bin/python3"

# 检查环境变量 QWENKEY 是否设置
if [[ -z "$QWENKEY" ]]; then
    echo "环境变量 QWENKEY 未设置，请设置后再运行脚本。"
    exit 1
fi

# 检查 Python 程序是否存在
if [[ ! -f "$PYTHON_SCRIPT" ]]; then
    echo "Python 程序 $PYTHON_SCRIPT 不存在。"
    exit 1
fi

# 主函数
main() {
    local prompt

    # 如果参数数量为0，通过输入IO获取用户输入
    if [[ $# -lt 1 ]]; then
        echo "请输入您的 Prompt:"
        read -r prompt
        "$PYTHON_EXEC" "$PYTHON_SCRIPT" "$prompt"
    else
        # 检查第一个参数是否为 "kill"
        if [[ "$1" == "kill" ]]; then
            "$PYTHON_EXEC" "$PYTHON_SCRIPT" "kill"
        else
            # 将所有参数合并为 prompt
            prompt="$*"
            "$PYTHON_EXEC" "$PYTHON_SCRIPT" "$prompt"
        fi
    fi
}

# 执行主函数
main "$@"