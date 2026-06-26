#!/bin/bash
# classify_project.sh — авто-классификация типа проекта
# Используется скиллом project-bootstrap для выбора подходящего шаблона.
#
# Usage: bash classify_project.sh [project_dir]
# Output: JSON с полями: type, subtype, complexity, variant, model_profile

set -euo pipefail

PROJECT_DIR="${1:-.}"

# Счётчики сигналов
OPS_SIGNALS=0
CODE_SIGNALS=0
CONTENT_SIGNALS=0
AGENT_SIGNALS=0

# --- OPS-сигналы ---
if compgen -G "$PROJECT_DIR/Dockerfile" > /dev/null || \
   compgen -G "$PROJECT_DIR/docker-compose*.yml" > /dev/null || \
   compgen -G "$PROJECT_DIR/docker-compose*.yaml" > /dev/null; then
    OPS_SIGNALS=$((OPS_SIGNALS + 3))
fi

if [ -f "$PROJECT_DIR/.ssh/config" ] || compgen -G "$PROJECT_DIR/*.env" > /dev/null; then
    OPS_SIGNALS=$((OPS_SIGNALS + 2))
fi

if grep -rqE "(ssh|scp|docker|nginx|mysql|postgres|backup|cron|systemd)" \
   "$PROJECT_DIR" --include="*.md" --include="*.sh" --include="*.yml" --include="*.yaml" 2>/dev/null; then
    OPS_SIGNALS=$((OPS_SIGNALS + 1))
fi

# --- CODE-сигналы ---
CODE_EXTENSIONS="py js ts jsx tsx go rs java rb php c h cpp swift kt scala"
for ext in $CODE_EXTENSIONS; do
    count=$(find "$PROJECT_DIR" -maxdepth 3 -name "*.$ext" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$count" -gt 3 ]; then
        CODE_SIGNALS=$((CODE_SIGNALS + 2))
        break
    fi
done

if [ -f "$PROJECT_DIR/package.json" ] || [ -f "$PROJECT_DIR/pyproject.toml" ] || \
   [ -f "$PROJECT_DIR/Cargo.toml" ] || [ -f "$PROJECT_DIR/go.mod" ] || \
   [ -f "$PROJECT_DIR/Makefile" ] || [ -f "$PROJECT_DIR/CMakeLists.txt" ]; then
    CODE_SIGNALS=$((CODE_SIGNALS + 3))
fi

if [ -d "$PROJECT_DIR/.git" ] || compgen -G "$PROJECT_DIR/.github/workflows/*" > /dev/null; then
    CODE_SIGNALS=$((CODE_SIGNALS + 1))
fi

if [ -d "$PROJECT_DIR/tests" ] || [ -d "$PROJECT_DIR/test" ] || [ -d "$PROJECT_DIR/spec" ]; then
    CODE_SIGNALS=$((CODE_SIGNALS + 1))
fi

# --- CONTENT-сигналы ---
CONTENT_EXTS="md txt org pdf docx xlsx csv json yaml yml"
for ext in $CONTENT_EXTS; do
    count=$(find "$PROJECT_DIR" -maxdepth 3 -name "*.$ext" ! -name "*.py" ! -name "*.js" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$count" -gt 10 ]; then
        CONTENT_SIGNALS=$((CONTENT_SIGNALS + 3))
        break
    fi
done

if [ -d "$PROJECT_DIR/briefs" ] || [ -d "$PROJECT_DIR/articles" ] || \
   [ -d "$PROJECT_DIR/content" ] || [ -d "$PROJECT_DIR/data" ] || \
   [ -d "$PROJECT_DIR/profile" ] || [ -d "$PROJECT_DIR/interview" ] || \
   [ -f "$PROJECT_DIR/profile.md" ]; then
    CONTENT_SIGNALS=$((CONTENT_SIGNALS + 3))
fi

# --- AGENT-сигналы ---
if compgen -G "$PROJECT_DIR/skills/*/SKILL.md" > /dev/null || \
   [ -f "$PROJECT_DIR/SKILL.md" ] || [ -d "$PROJECT_DIR/.agents/skills" ]; then
    AGENT_SIGNALS=$((AGENT_SIGNALS + 4))
fi

if compgen -G "$PROJECT_DIR/.opencode/agents/*.md" > /dev/null || \
   compgen -G "$PROJECT_DIR/.agents/agents/*.md" > /dev/null; then
    AGENT_SIGNALS=$((AGENT_SIGNALS + 3))
fi

# Bugfix v2: dropped -q — must produce stdout for pipe chain
if grep -rlE "(AGENTS\.md|SESSION_HANDOFF|subagent|skill|prompt)" \
   "$PROJECT_DIR" --include="*.md" 2>/dev/null | head -1 | grep -q .; then
    AGENT_SIGNALS=$((AGENT_SIGNALS + 2))
fi

# --- Определение типа ---
# Правило приоритета для гибридов: ops > code > agent > content
determine_type() {
    if [ "$OPS_SIGNALS" -ge 4 ]; then
        if [ "$CODE_SIGNALS" -ge 4 ]; then
            echo "ops-code"
        elif [ "$AGENT_SIGNALS" -ge 3 ]; then
            echo "ops-agent"
        else
            echo "ops"
        fi
    elif [ "$CODE_SIGNALS" -ge 4 ]; then
        if [ "$CONTENT_SIGNALS" -ge 4 ]; then
            echo "code-content"
        elif [ "$AGENT_SIGNALS" -ge 4 ]; then
            echo "code-agent"
        else
            echo "code"
        fi
    elif [ "$AGENT_SIGNALS" -ge 5 ]; then
        echo "agent"
    elif [ "$CONTENT_SIGNALS" -ge 4 ]; then
        echo "content"
    else
        echo "undetermined"
    fi
}

PROJECT_TYPE=$(determine_type)

# --- Определение сложности ---
# TRIVIAL: <3 файлов, нет AGENTS.md
# MODERATE: 3-20 файлов, есть структура
# UNCERTAIN: >20 файлов или нестандартная структура
FILE_COUNT=$(find "$PROJECT_DIR" -maxdepth 3 -type f 2>/dev/null | wc -l | tr -d ' ')
if [ "$FILE_COUNT" -lt 3 ] && [ ! -f "$PROJECT_DIR/AGENTS.md" ]; then
    COMPLEXITY="TRIVIAL"
elif [ "$FILE_COUNT" -le 20 ] || [ -f "$PROJECT_DIR/AGENTS.md" ]; then
    COMPLEXITY="MODERATE"
else
    COMPLEXITY="UNCERTAIN"
fi

# --- Определение варианта шаблона ---
case "$PROJECT_TYPE" in
    ops|ops-code|ops-agent)
        VARIANT="variant-e-full"
        ;;
    code|code-content|code-agent)
        VARIANT="variant-e-grace"
        ;;
    agent)
        VARIANT="variant-e-model"
        ;;
    content)
        VARIANT="lightweight"
        ;;
    *)
        VARIANT="base"
        ;;
esac

# --- Определение модельного профиля ---
# По умолчанию — universal, если не указано иное
MODEL_PROFILE="universal"
if grep -rqE "(deepseek|v4-pro|v4-flash)" "$PROJECT_DIR" --include="*.md" --include="*.json" 2>/dev/null; then
    MODEL_PROFILE="deepseek"
elif grep -rqE "(glm|zhipu|chatglm)" "$PROJECT_DIR" --include="*.md" --include="*.json" 2>/dev/null; then
    MODEL_PROFILE="glm"
fi

# --- Вывод ---
cat <<EOF
{
  "project_dir": "$PROJECT_DIR",
  "type": "$PROJECT_TYPE",
  "complexity": "$COMPLEXITY",
  "variant": "$VARIANT",
  "model_profile": "$MODEL_PROFILE",
  "signals": {
    "ops": $OPS_SIGNALS,
    "code": $CODE_SIGNALS,
    "content": $CONTENT_SIGNALS,
    "agent": $AGENT_SIGNALS
  },
  "file_count": $FILE_COUNT
}
EOF
