# 更新记录

## 2.5.0 — 2026-11-27

### 新增

- 新增 M2 / M2 Pro / M2 Max / M2 Ultra 主机识别，`doctor` 与 `doctor --json` 会报告 `chip`、`model`、`is_m2` 和 `host_arch`。
- 新增 `make build-m2`，生成 Apple Silicon 专用的 arm64 二进制；通用构建仍由 `make build` 生成。
- 新增微信 **4.2.1.12（build 270604）** arm64 静默防撤回、留提示防撤回和 8 个自动更新拦截点。
- `signatures.json` 支持按签名代覆盖 `off_cbz`，Swift 签名表与 Python 定位器保持同步。

### 修复与改进

- 修正 `hw.optional.arm64` 的读取方式，按整数 sysctl 处理，避免 Apple Silicon 架构误判。
- 默认远程补丁库切换为本仓库 `main` 分支的 `config.json`。
- README 更新最新支持构建、M2 构建方式和 270604 验证范围。

### 验证

- `swift test`：75 项通过，1 项按设计跳过，0 失败。
- `python3 tools/gen_signatures.py --check`：生成表与 JSON 一致。
- 官网 DMG 仅在临时副本验证：静默与留提示补丁、重复执行、恢复、entitlements 保留及 `codesign --verify --deep --strict`。

### 已知限制

- 270604 仅适配 arm64，尚未提供或验证 x86_64 补丁点。
- 尚未使用真实账号进行聊天撤回端到端测试；实际防撤回行为需在目标账号上确认。
