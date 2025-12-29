# 项目配置
BINARY_NAME := golin
VERSION     := $(shell grep 'Version' global/version.go | cut -d '"' -f 2)
BIN_DIR     := bin
LDFLAGS     := -s -w

# 平台定义
PLATFORMS := windows/amd64 linux/amd64 linux/arm64 darwin/amd64 darwin/arm64

.PHONY: build clean $(PLATFORMS)

# 默认目标：编译所有平台
build: $(PLATFORMS)

# 模式匹配规则：处理所有平台的编译
$(PLATFORMS):
	@$(eval OS := $(word 1,$(subst /, ,$@)))
	@$(eval ARCH := $(word 2,$(subst /, ,$@)))
	@$(eval BIN_OUT := $(BIN_DIR)/$(BINARY_NAME)_$(OS)_$(ARCH)$(if $(filter windows,$(OS)),.exe,))
	@echo "🔀 正在构建: $(OS)/$(ARCH)..."
	@mkdir -p $(BIN_DIR)
	GOOS=$(OS) GOARCH=$(ARCH) go build -ldflags "$(LDFLAGS)" -o $(BIN_OUT) .
	@# 仅对非 Mac 平台执行 UPX
	@if [ "$(OS)" != "darwin" ]; then \
		upx -9 $(BIN_OUT) > /dev/null 2>&1 || echo "⚠️  UPX 跳过 $(BIN_OUT)"; \
	fi

clean:
	@echo "🧹 清理 bin 目录..."
	rm -rf $(BIN_DIR)/*