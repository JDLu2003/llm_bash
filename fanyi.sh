#!/bin/zsh

# 定义 Ollama 的 API 地址
OLLAMA_API="http://localhost:11434/api/generate"

# 定义模型名称
#OLLAMA_MODEL="deepseek-r1:14b"
OLLAMA_MODEL="gemma3:12b"

# 发送 Prompt（流式访问）
send_prompt() {
    local input_prompt=$1
    local prompt="请你尽量简短地（不超过100字）翻译并解释： $input_prompt 为中文"
    echo "-----发送 Prompt-----"

    # 直接用 curl 获取流式数据，确保实时输出
    curl -s -N -X POST "$OLLAMA_API" \
    -H "Content-Type: application/json" \
    -d "{
        \"model\": \"$OLLAMA_MODEL\",
        \"prompt\": \"$prompt\",
        \"stream\": true
    }" | while IFS= read -r line; do
    # 使用 jq 解析 JSON 并提取 .response 字段
    response=$(echo "$line" | jq -R -r 'fromjson? | .response')
    if [ -n "$response" ]; then
        printf "%s" "$response"
        ## fflush(stdout)  # 强制刷新输出缓冲区
    fi
done
    echo  # 确保最终换行
}

# 主函数
main() {
    if [[ $# -lt 1 ]]; then
        echo "用法: $0 <用户 Prompt>"
        exit 1
    fi

    # 移除第一个参数（即 "ask"），将剩余参数合并为 prompt
    
    local prompt="$*"

    send_prompt "$prompt"
}

# 执行主函数
if [[ "$1" == "kill" ]]; then
    ollama stop "$OLLAMA_MODEL"
    echo "已停止模型: $OLLAMA_MODEL"
else
    main "$@"
fi

