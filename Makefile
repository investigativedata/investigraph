SRC_DIR := docs
BUILD_DIR := site
CLOG_DIR := changelogs
CLOG_FILE := CHANGELOG.md
REPOS := investigraph-etl runpandarun ftmq
BRANCH := develop
CHANGELOGS := $(REPOS:%=$(SRC_DIR)/$(CLOG_DIR)/%.md)

all: clean $(BUILD_DIR)

$(BUILD_DIR): $(CHANGELOGS)
	mkdocs build -c -d $(BUILD_DIR)

$(SRC_DIR)/$(CLOG_DIR):
	mkdir -p $(SRC_DIR)/$(CLOG_DIR)


$(SRC_DIR)/$(CLOG_DIR)/investigraph-etl.md: GITHUB=investigativedata
$(SRC_DIR)/$(CLOG_DIR)/ftmq.md: GITHUB=investigativedata
$(SRC_DIR)/$(CLOG_DIR)/runpandarun.md: GITHUB=simonwoerpel
$(SRC_DIR)/$(CLOG_DIR)/%.md: $(SRC_DIR)/$(CLOG_DIR)
	wget -O $@ https://raw.githubusercontent.com/$(GITHUB)/$*/$(BRANCH)/$(CLOG_FILE)

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(SRC_DIR)/$(CLOG_DIR)

.PHONY: serve
serve: clean $(CHANGELOGS)
	mkdocs serve

