# Git Flow Skill

[![License: MIT](https://img.shield.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Git](https://img.shield.io/badge/Git-2.0%2B-red.svg)]https://git-scm.com/)

> **Git Flow 分支模型** — 用纯 Git 实现，无需额外工具

一个帮助你遵循 Git Flow 工作流的 Claude Code 技能。支持自定义分支名称、交互式操作，完全可移植。

---

## 快速开始

### 安装

```bash
# 克隆仓库
git clone https://github.com/hughedward/gitflow-skills.git /tmp/gitflow-skills

# 复制技能到你的 Claude Code 技能目录
mkdir -p ~/.agents/skills
mkdir -p ~/.claude/skills
cp -r /tmp/gitflow-skills/.claude/skills/gitflow ~/.agents/skills
ln -s ~/.agents/skills/gitflow ~/.claude/skills/

# 完成！在 Claude Code 中输入 /gitflow 即可使用
```

### 基本使用

在 Claude Code 中输入：

```
/gitflow
```

技能会引导你完成 Git Flow 的各项操作。

---

## 功能特性

| 功能 | 说明 |
|------|------|
| **纯 Git 实现** | 无需安装 git-flow-avh 等额外工具 |
| **交互式菜单** | 友好的命令行界面，无需记忆复杂命令 |
| **自定义配置** | 支持自定义分支名称（如 `dev` 替代 `develop`） |
| **状态可视化** | 一眼看懂当前 Git Flow 状态 |
| **回归测试** | 内置测试套件，确保脚本可靠性 |

---

## 使用指南

### 初始化仓库

```bash
# 确保 main 分支存在
git checkout main

# 创建 develop 分支
git checkout -b develop

# 推送到远程
git push -u origin main
git push -u origin develop
```

或使用辅助脚本：

```bash
bash ~/.claude/skills/gitflow/scripts/setup_gitflow.sh
```

### 开发新功能

```bash
# 从 develop 创建 feature 分支
git checkout develop
git checkout -b feature/user-auth

# ... 开发代码 ...

# 完成后合并回 develop
git checkout develop
git merge --no-ff feature/user-auth
git branch -d feature/user-auth
```

### 发布版本

```bash
# 从 develop 创建 release 分支
git checkout develop
git checkout -b release/1.0.0

# ... 发布前准备 ...

# 合并到 main 并打标签
git checkout main
git merge --no-ff release/1.0.0
git tag -a 1.0.0 -m "Release version 1.0.0"

# 合并回 develop
git checkout develop
git merge --no-ff release/1.0.0
git branch -d release/1.0.0

# 推送标签
git push origin main
git push origin develop
git push origin 1.0.0
```

### 生产修复

```bash
# 从 main 创建 hotfix 分支
git checkout main
git checkout -b hotfix/1.0.1

# ... 修复 bug ...

# 合并到 main 并打标签
git checkout main
git merge --no-ff hotfix/1.0.1
git tag -a 1.0.1 -m "Hotfix version 1.0.1"

# 合并回 develop
git checkout develop
git merge --no-ff hotfix/1.0.1
git branch -d hotfix/1.0.1
```

---

## 辅助脚本

| 脚本 | 用途 |
|------|------|
| `setup_gitflow.sh` | 初始化 Git Flow 仓库 |
| `gitflow_helper.sh` | 交互式操作菜单 |
| `gitflow_status.sh` | 显示当前 Git Flow 状态 |
| `smoke_test.sh` | 运行回归测试 |

---

## 分支结构

| 分支 | 用途 | 来源 | 合并到 |
|------|------|------|--------|
| `main` / `master` | 生产环境 | - | - |
| `develop` | 开发集成分支 | `main` | - |
| `feature/*` | 新功能开发 | `develop` | `develop` |
| `release/*` | 发布准备 | `develop` | `develop`, `main` |
| `hotfix/*` | 生产紧急修复 | `main` | `develop`, `main` |

---

## Git Flow 原理

Git Flow 是一种分支模型策略，由 [Vincent Driessen](https://nvie.com/posts/a-successful-git-branching-model/) 提出。

**核心理念：** Git Flow 是一套分支管理规范，**不是某个工具**。理解底层的 Git 命令，你就能在任何环境使用，无需依赖额外软件。

```
┌─────────────────────────────────────────────────────────┐
│  Git Flow 理念  →  用原生 git 实现  ✓                    │
│  Git Flow 工具  →  可选，非必须  (optional)              │
└─────────────────────────────────────────────────────────┘
```

---

## 配置

项目根目录的 `.gitflow` 配置文件存储分支命名偏好：

```ini
[gitflow "branch"]
    master = main
    develop = develop
[gitflow "prefix"]
    feature = feature/
    release = release/
    hotfix = hotfix/
```

所有辅助脚本都会自动读取并遵守此配置。

---

## 测试

运行内置测试套件：

```bash
bash ~/.claude/skills/gitflow/scripts/smoke_test.sh
```

预期输出：

```
=== Git Flow Smoke Test ===

Test 1: New repo (init.defaultBranch=main)
✓ PASS: New repo with main default

Test 2: New repo (init.defaultBranch=master)
✓ PASS: New repo with master default (renamed to main)

Test 3: Custom branch names (.gitflow config)
✓ PASS: Custom branch names recognized

=== Summary ===
Passed: 3
Failed: 0
All tests passed!
```

---

## 系统要求

- Git 2.0+
- Bash 4.0+

---

## 常见问题

**Q: 必须安装 git-flow-avh 工具吗？**

A: 不需要。本技能使用纯 Git 命令实现所有功能。

**Q: 可以自定义分支名称吗？**

A: 可以。修改 `.gitflow` 配置文件即可。

**Q: develop 分支不存在怎么办？**

A: 运行 `git checkout main && git checkout -b develop` 创建。

---

## 许可证

[MIT License](LICENSE)

---

## 贡献

欢迎提交 Issue 和 Pull Request！

---

[![Star History Chart](https://api.star-history.com/svg?repos=hughedward/gitflow-skills&type=Date)](https://star-history.com/#hughedward/gitflow-skills&Date)
