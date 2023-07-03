.PHONY: complete test local

export WORKLOAD
export ENVIRONMENT
export USECASE

#test_extended:

test:
	cd tests && go test -v -timeout 60m -run TestApplyNoError/$(USECASE) ./bastion_host_test.go

#test_local:

