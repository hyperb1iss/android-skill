# Android Skill Plugin - Development Makefile
# ─────────────────────────────────────────────

.PHONY: all lint format check clean help

# Colors (SilkCircuit palette)
PURPLE := \033[38;2;225;53;255m
CYAN := \033[38;2;128;255;234m
GREEN := \033[38;2;80;250;123m
YELLOW := \033[38;2;241;250;140m
RED := \033[38;2;255;99;99m
RESET := \033[0m

#─────────────────────────────────────────────
# Default target
#─────────────────────────────────────────────
all: check
	@echo "$(GREEN)✓ All checks passed$(RESET)"

#─────────────────────────────────────────────
# Linting & Validation
#─────────────────────────────────────────────
lint: lint-json lint-yaml lint-md
	@echo "$(GREEN)✓ All lints passed$(RESET)"

lint-json:
	@echo "$(CYAN)→ Linting JSON files...$(RESET)"
	@find . -name "*.json" -type f -not -path "./research/*" | xargs -I {} sh -c 'jq empty {} 2>/dev/null || (echo "$(RED)✗ Invalid JSON: {}$(RESET)" && exit 1)'
	@echo "$(GREEN)  ✓ JSON valid$(RESET)"

lint-yaml:
	@echo "$(CYAN)→ Linting YAML files...$(RESET)"
	@if command -v yamllint >/dev/null 2>&1; then \
		find . -name "*.yml" -o -name "*.yaml" | xargs yamllint -d relaxed 2>/dev/null || true; \
	else \
		echo "$(YELLOW)  ⚠ yamllint not installed, skipping$(RESET)"; \
	fi
	@echo "$(GREEN)  ✓ YAML checked$(RESET)"

lint-md:
	@echo "$(CYAN)→ Linting Markdown files...$(RESET)"
	@if command -v markdownlint >/dev/null 2>&1; then \
		find . -name "*.md" -type f -not -path "./research/*" | xargs markdownlint --config .markdownlint.json 2>/dev/null || true; \
	else \
		echo "$(YELLOW)  ⚠ markdownlint not installed, skipping$(RESET)"; \
	fi
	@echo "$(GREEN)  ✓ Markdown checked$(RESET)"

#─────────────────────────────────────────────
# Formatting
#─────────────────────────────────────────────
format: format-md format-json
	@echo "$(GREEN)✓ Formatting complete$(RESET)"

format-md:
	@echo "$(CYAN)→ Formatting Markdown files...$(RESET)"
	@npx prettier --write "skills/**/*.md" "agents/**/*.md" "commands/**/*.md" --prose-wrap preserve 2>/dev/null || echo "$(YELLOW)  ⚠ prettier failed$(RESET)"
	@echo "$(GREEN)  ✓ Markdown formatted$(RESET)"

format-json:
	@echo "$(CYAN)→ Formatting JSON files...$(RESET)"
	@npx prettier --write "**/*.json" --ignore-path .gitignore 2>/dev/null || echo "$(YELLOW)  ⚠ prettier failed$(RESET)"
	@echo "$(GREEN)  ✓ JSON formatted$(RESET)"

format-check:
	@echo "$(CYAN)→ Checking format...$(RESET)"
	@npx prettier --check "skills/**/*.md" "agents/**/*.md" "**/*.json" 2>/dev/null || (echo "$(RED)✗ Files need formatting$(RESET)" && exit 1)
	@echo "$(GREEN)  ✓ Format OK$(RESET)"

#─────────────────────────────────────────────
# Validation
#─────────────────────────────────────────────
check: validate-structure validate-frontmatter
	@echo "$(GREEN)✓ Plugin structure valid$(RESET)"

validate-structure:
	@echo "$(CYAN)→ Validating plugin structure...$(RESET)"
	@test -f .claude-plugin/plugin.json || (echo "$(RED)✗ Missing plugin.json$(RESET)" && exit 1)
	@echo "$(GREEN)  ✓ plugin.json exists$(RESET)"
	@test -d skills || (echo "$(RED)✗ Missing skills directory$(RESET)" && exit 1)
	@echo "$(GREEN)  ✓ skills/ exists$(RESET)"
	@for skill in skills/*/; do \
		test -f "$$skill/SKILL.md" || (echo "$(RED)✗ Missing SKILL.md in $$skill$(RESET)" && exit 1); \
	done
	@echo "$(GREEN)  ✓ All skills have SKILL.md$(RESET)"

validate-frontmatter:
	@echo "$(CYAN)→ Validating frontmatter...$(RESET)"
	@for f in skills/*/SKILL.md; do \
		if [ -f "$$f" ]; then \
			head -1 "$$f" | grep -q "^---$$" || (echo "$(RED)✗ Missing frontmatter in $$f$(RESET)" && exit 1); \
		fi \
	done
	@for f in agents/*.md; do \
		if [ -f "$$f" ]; then \
			head -1 "$$f" | grep -q "^---$$" || (echo "$(RED)✗ Missing frontmatter in $$f$(RESET)" && exit 1); \
		fi \
	done
	@echo "$(GREEN)  ✓ Frontmatter valid$(RESET)"

#─────────────────────────────────────────────
# Stats
#─────────────────────────────────────────────
stats:
	@echo "$(PURPLE)📊 Plugin Statistics$(RESET)"
	@echo "$(CYAN)─────────────────────────────────────$(RESET)"
	@echo "$(CYAN)Skills:$(RESET)"
	@for skill in skills/*/; do \
		name=$$(basename $$skill); \
		lines=$$(wc -l < "$$skill/SKILL.md" 2>/dev/null || echo 0); \
		echo "  $(GREEN)$$name$(RESET): $$lines lines"; \
	done
	@echo "$(CYAN)Agents:$(RESET)"
	@for agent in agents/*.md; do \
		if [ -f "$$agent" ]; then \
			name=$$(basename $$agent .md); \
			lines=$$(wc -l < "$$agent"); \
			echo "  $(GREEN)$$name$(RESET): $$lines lines"; \
		fi \
	done
	@echo "$(CYAN)Total lines:$(RESET)"
	@find skills agents -name "*.md" -type f | xargs wc -l 2>/dev/null | tail -1

#─────────────────────────────────────────────
# Plugin Testing
#─────────────────────────────────────────────
test-local:
	@echo "$(PURPLE)→ Testing plugin locally...$(RESET)"
	@echo "$(CYAN)  Run: claude --plugin-dir $(shell pwd)$(RESET)"

#─────────────────────────────────────────────
# Cleanup
#─────────────────────────────────────────────
clean:
	@echo "$(CYAN)→ Cleaning up...$(RESET)"
	@find . -name ".DS_Store" -delete 2>/dev/null || true
	@find . -name "*.bak" -delete 2>/dev/null || true
	@find . -name "*~" -delete 2>/dev/null || true
	@echo "$(GREEN)✓ Cleaned$(RESET)"

#─────────────────────────────────────────────
# Help
#─────────────────────────────────────────────
help:
	@echo ""
	@echo "$(PURPLE)Android Skill Plugin$(RESET)"
	@echo "$(CYAN)─────────────────────────────────────$(RESET)"
	@echo ""
	@echo "$(CYAN)Usage:$(RESET)"
	@echo "  make [target]"
	@echo ""
	@echo "$(CYAN)Targets:$(RESET)"
	@echo "  $(GREEN)all$(RESET)              Run all checks (default)"
	@echo "  $(GREEN)lint$(RESET)             Run all linters"
	@echo "  $(GREEN)format$(RESET)           Format all files with prettier"
	@echo "  $(GREEN)format-check$(RESET)     Check if files are formatted"
	@echo "  $(GREEN)check$(RESET)            Validate plugin structure"
	@echo "  $(GREEN)stats$(RESET)            Show plugin statistics"
	@echo "  $(GREEN)test-local$(RESET)       Show command to test locally"
	@echo "  $(GREEN)clean$(RESET)            Remove temp files"
	@echo "  $(GREEN)help$(RESET)             Show this help"
	@echo ""
