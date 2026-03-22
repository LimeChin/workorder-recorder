# Work Order Code Recorder

自动记录 Git 提交代码变更到 Markdown 文档的工具。

## 功能

- Git commit 后自动触发
- AI 生成代码变更摘要
- 按分支/工单组织文档
- 同一需求的多次提交合并到一个文件

## 文件结构

```
workorder-recorder/
├── post-commit       # Git hook 主脚本
├── parse_json.pl     # JSON 解析脚本
├── update_md.pl      # Markdown 更新脚本
├── workorder.bat     # Windows 管理菜单
├── config.example.json
└── README.md
```

## 安装

1. 复制 `config.example.json` 为 `config.json`，填入配置：

```json
{
    "api_key": "your-api-key",
    "api_url": "https://your-api-endpoint",
    "model": "your-model",
    "workorder_file": "C:/Users/YourName/.workorder_config.json",
    "output_dir": "D:/your-output-dir"
}
```

2. 运行 `workorder.bat`：
   - 选择 Git 仓库
   - 设置工单号
   - 安装 Hook

## Commit Message 规范

使用 `模块名：描述` 或 `模块名:描述` 格式：

```
经销宝下单-购物车：修复getDistAddress的BUG
经销宝下单-购物车: add new feature
```

同一模块的提交会写入同一个 MD 文件。

## 输出示例

```
D:/winchannel/xuqiuwendang/
└── feature-branch/
    └── 2026-0175/
        ├── 经销宝下单-购物车.md
        └── 经销宝下单-订单结算.md
```