compile_typespec \
	--psgi amethst.psgi \
	--scripts bin
	amethst.spec lib
SERVICE_NAME = AMETHSTService
compile_typespec 
	-impl Bio::KBase::$(SERVICE_NAME)::Impl \
	-service Bio::KBase::$(SERVICE_NAME)::Service \
	-client Bio::KBase::$(SERVICE_NAME)::Client \
	-js $(SERVICE_NAME) \
	-py $(SERVICE_NAME) \
	amethst.spec lib
# https://www.kbase.us/developer-zone/tutorials/developer-tutorials/my-first-service/