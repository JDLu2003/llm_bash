#!/bin/zsh

# 定义 Ollama 的 API 地址
OLLAMA_API="http://localhost:11434/api/generate"

# 定义模型名称
OLLAMA_MODEL="gemma3:12b"

# 发送 Prompt（流式访问）
send_prompt() {
    local input_prompt=$1
    local prompt="中文回答：这个单词： $input_prompt的英文同义词是什么"
    echo "-----发送 Prompt-----\n"

    # 构造 JSON 使用 jq
    json_data=$(jq -n --arg p "$prompt" '{
        "stream": true,
        "model": "qwen-plus",
        "messages": [
            {
                "role": "system",
                "content": "You are a helpful assistant."
            },
            {
                "role": "user",
                "content": $p
            }
        ]
    }')

    # 直接用 curl 获取流式数据，确保实时输出
    curl -s -N -X POST https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions \
    -H "Authorization: Bearer $QWENKEY" \
    -H "Content-Type: application/json" \
    -d "$json_data" | while IFS= read -r line; do
        # 检查是否以 "data: " 开头
        if [[ "$line" == data:* ]]; then
            # 去掉 "data: " 前缀
            json="${line#data: }"

            # 检查是否为 "[DONE]"
            if [[ "$json" == "[DONE]" ]]; then
                break
            fi

            # 使用 jq 解析 JSON 并提取 .choices[0].delta.content
            content=$(echo "$json" | jq -r '.choices[0].delta.content? // empty' 2>/dev/null)

            # 如果 content 不为空，则输出
            if [ -n "$content" ]; then
                printf "%s" "$content"
                ## fflush(stdout)  # 强制刷新输出缓冲区
            fi
        fi
    done
    echo  # 确保最终换行
    echo
}

# 主函数
main() {
    local prompt

    # 如果参数数量为0，通过输入IO获取用户输入
    if [[ $# -lt 1 ]]; then
        echo "请输入您的 Prompt:"
        read -r prompt
    else
        # 将所有参数合并为 prompt
        prompt="$*"
    fi

    send_prompt "$prompt"

    while true
    do
        echo -n "input word: "
        read -r prompt
        send_prompt "$prompt"
    done

}

# 执行主函数
if [[ "$1" == "kill" ]]; then
    ollama stop "$OLLAMA_MODEL"
    echo "已停止模型: $OLLAMA_MODEL"
else
    main "$@"
fi