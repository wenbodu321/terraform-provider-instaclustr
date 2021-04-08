
BIN_NAME="terraform-provider-instaclustr"

VERSION=v1.9.4
NOVVERSION=1.9.4
INSTALL_FOLDER=$(HOME)/.terraform.d/plugins/example.com/instaclustr/instaclustr/$(NOVVERSION)/darwin_amd64

.PHONY: install clean all build test testacc testtarget release_version
release_version:
	@echo $(VERSION)

all: build

clean:
	rm $(BIN_NAME)_$(VERSION)
	rm -fr vendor

build:
	go build $(FLAGS) -o bin/$(BIN_NAME)_$(VERSION) main.go

test:
	cd test && go test -v -timeout 120m -count=1

testacc:
ifndef IC_USERNAME
	@echo "IC_USERNAME for provisioning API must be set for acceptance tests"
	@exit 1
endif
ifndef IC_API_KEY
	@echo "IC_API_KEY for provisioning API must be set for acceptance tests"
	@exit 1
endif
ifndef KMS_ARN
	@echo "KMS_ARN for provisioning API must be set for acceptance tests"
	@exit 1
endif
ifndef IC_PROV_ACC_NAME
	@echo "IC_PROV_ACC_NAME for provisioning API must be set for acceptance tests"
	@exit 1
endif
ifndef IC_PROV_VPC_ID
	@echo "IC_PROV_VPC_ID for provisioning API must be set for acceptance tests"
	@exit 1
endif
	cd test && TF_ACC=1 go test -v -timeout 120m -count=1

testtarget:
ifndef TARGET
	@echo "TARGET for test name must be set for running specific tests"
	@exit 1
endif

ifeq (,$(findstring Test, $(TARGET)))
	@echo "The target is not a test"
	@exit 1
endif

ifneq (,$(findstring Acc, $(TARGET)))
ifndef IC_USERNAME
	@echo "IC_USERNAME for provisioning API must be set for acceptance tests"
	@exit 1
endif
ifndef IC_API_KEY
	@echo "IC_API_KEY for provisioning API must be set for acceptance tests"
	@exit 1
endif
endif

ifneq (,$(findstring Key, $TARGET))
ifndef KMS_ARN
	@echo "KMS_ARN must be set for encryption key tests"
	@exit 1
endif
endif

ifneq (,$(findstring CustomVPC, $TARGET))
ifndef IC_PROV_ACC_NAME
	@echo "IC_PROV_ACC_NAME must be set for custom VPC tests"
	@exit 1
endif
ifndef IC_PROV_VPC_ID
	@echo "IC_PROV_VPC_ID must be set for custom VPC tests"
	@exit 1
endif
endif

	cd test && TF_ACC=1 go test -v -run ${TARGET}

install:
	@if [ ! -d $(INSTALL_FOLDER) ]; then \
		echo "$(INSTALL_FOLDER) doesn't exist, creating..."; \
		mkdir -p $(INSTALL_FOLDER); \
	fi
	cp ./bin/$(BIN_NAME)_$(VERSION) $(INSTALL_FOLDER)
