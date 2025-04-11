import requests
import json
import sys
import os
import subprocess

# 定义常量（尽管 API 和模型名称在脚本中被覆盖，但保留以示意图）
OLLAMA_API = "http://localhost:11434/api/generate"
OLLAMA_MODEL = "gemma3:12b"

def send_prompt(input_prompt):
    """发送 prompt 到 DashScope API 并处理流式响应"""
    # 构造 prompt
    prompt = f"请你以普通文本格式（不使用markdown）充满表情地回答或解释： {input_prompt}"
    print("\n🤖Deepseek-V3 🐳:\n")

    # 构造 JSON 数据
    json_data = {
        "stream": True,
        "model": "deepseek-v3",
        "messages": [
            {
                "role": "system",
                "content": "You are a helpful assistant majoring in Computer Science and a English Teacher.User flatform is macOS.Please answer briefly"
            },
            {
                "role": "user",
                "content": prompt
            }
        ]
    }

    # 设置请求头，包括 Authorization
    headers = {
        "Authorization": f"Bearer {os.environ.get('QWENKEY')}",
        "Content-Type": "application/json"
    }

    # 发送 POST 请求，启用流式响应
    response = requests.post(
        "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions",
        headers=headers,
        json=json_data,
        stream=True
    )

    # 处理流式响应
    for line in response.iter_lines():
        if line:
            # 解码为 UTF-8
            line = line.decode('utf-8')
            if line.startswith('data: '):
                json_str = line[6:]  # 去掉 "data: " 前缀
                if json_str == '[DONE]':
                    break
                try:
                    # 解析 JSON 并提取 content
                    data = json.loads(json_str)
                    content = data.get('choices', [{}])[0].get('delta', {}).get('content', '')
                    if content:
                        print(content, end='', flush=True)  # 实时输出
                except json.JSONDecodeError:
                    pass  # 忽略解析错误
    print()  # 确保最终换行
    print()

def main():
    """主函数，处理命令行参数并调用 send_prompt"""
    if len(sys.argv) > 1 and sys.argv[1] == "kill":
        # 停止模型
        subprocess.run(["ollama", "stop", OLLAMA_MODEL])
        print(f"已停止模型: {OLLAMA_MODEL}")
    else:
        # 获取 prompt
        if len(sys.argv) < 2:
            print("请输入您的 Prompt:")
            prompt = input()
        else:
            prompt = ' '.join(sys.argv[1:])  # 合并命令行参数
        send_prompt(prompt)

if __name__ == "__main__":
    main()
